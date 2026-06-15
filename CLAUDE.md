# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PowerShell module (v1.0.0) wrapping the DNSFilter REST API. Targets PowerShell 5.1+. Built, tested, linted, and published via a Sampler/ModuleBuilder + Invoke-Build pipeline; see `todo.md` for the roadmap.

## Commands

```powershell
# First time: resolve build dependencies into output/RequiredModules
./build.ps1 -ResolveDependency -Tasks noop

# Build the module into output/, run tests, or lint
./build.ps1 -Tasks build
./build.ps1 -Tasks test
./build.ps1 -Tasks format   # auto-format source
./build.ps1 -Tasks lint     # check formatting + PSScriptAnalyzer

# All-in-one local pre-push validation (build + analyze + test)
./Tests/test-local.ps1
```

CI/CD (`.github/workflows/ci.yml`) runs the same build → test → lint → analyze steps and
publishes to the PowerShell Gallery when a `v*.*.*` tag is pushed — the tag **must match** the
manifest `ModuleVersion`. Tests require PowerShell 7+, so run the build under `pwsh`.

## Architecture

### Module Loading

`source/DNSFilterAPI.psm1` dot-sources everything in order:
1. `prefix.ps1` — forces TLS 1.2
2. `Private/*.ps1` — internal helpers
3. `Public/*/*.ps1` — exported functions (one file per function, grouped by resource subfolder)

Exported functions are explicitly listed in `source/DNSFilterAPI.psd1` (`FunctionsToExport`). At build time ModuleBuilder concatenates `prefix.ps1`, the function files, and `suffix.ps1` into a single module under `output/`; tests and published releases load that built module (not the source files directly).

### Request Pipeline

All API calls flow through a single private function:

`Invoke-DNSFilterRequest` (Endpoint, Method, Body, QueryParameters, Session) →
resolves session (explicit `-Session` or fallback to `$script:DNSFilterSession`) → builds URI via `Join-Url` → serializes body to JSON → calls `Invoke-RestMethod` → returns `.data` if present, else raw response.

Session state (`BaseURI`, `WebSession` with Bearer token in persistent headers) is stored in the script-scoped `$script:DNSFilterSession` variable, set by `Connect-DNSFilter`.

### Thread Safety

Every public function accepts an optional `-Session` hashtable parameter. For single-threaded use, the module-scoped session works automatically. For `ForEach-Object -Parallel`, capture the session and pass it explicitly:

```powershell
$session = Connect-DNSFilter -APIKey $Key
$orgIds | ForEach-Object -Parallel {
    Get-DNSFilterNetwork -OrganizationId $_ -Session $using:session
}
```

### Function Patterns

**Get functions** use parameter sets: `Default` (user's resources), `ID` (by ID), `All` (include deleted). Some accept `-OrganizationId` for filtering. Use `$PSBoundParameters.ContainsKey()` (not truthiness checks) for optional int parameters to avoid ID=0 bugs.

**New/Update functions** map PascalCase parameters to snake_case API fields via a `$ParamMap` hashtable, iterate `$PSBoundParameters`, and wrap the payload under the resource key (e.g., `@{ network = $Network }`).

**Destructive functions** (New, Update, Remove, Set) declare `[CmdletBinding(SupportsShouldProcess)]` for `-WhatIf`/`-Confirm` support; Remove functions add `ConfirmImpact = 'High'`.

## Code Style (PSScriptAnalyzer)

Settings live in `.PSScriptAnalyzerSettings.psd1` (shared strict ruleset). Run `./build.ps1 -Tasks format` to auto-fix most style issues before committing.

- 4-space indentation, open brace on same line (`PSPlaceOpenBrace`)
- Assignment statements **are** aligned (`PSAlignAssignmentStatement`)
- Max line length 120 (`PSAvoidLongLines`); use single quotes for constant strings (`PSAvoidUsingDoubleQuotesForConstantString`)
- Pipeline indentation increases for the first pipeline component
- Function nouns are singular (e.g. `Get-DNSFilterIPAddress`)

## Adding a New Function

1. Create `source/Public/<ResourceCategory>/<Verb>-DNSFilter<Resource>.ps1`
2. Follow the ParamMap + ShouldProcess pattern from existing functions
3. Include `[hashtable]$Session` parameter and pass `-Session $Session` to `Invoke-DNSFilterRequest`
4. Use `$PSBoundParameters.ContainsKey()` for optional int parameters, never `if ($Variable)`
5. Use `Patch` (not `Put`) for Update functions to avoid overwriting unspecified fields
6. Add the function name to `FunctionsToExport` in `source/DNSFilterAPI.psd1`
7. API base path convention: `/v1/<resource_name_snake_case>`
8. Close braces before `else`/`elseif` go on the same line: `} else {` (PSPlaceCloseBrace rule)
9. Add request-mocked Pester tests under `Tests/Unit/Public/<Resource>.Tests.ps1`, mocking `Invoke-DNSFilterRequest` with `-ModuleName DNSFilterAPI` and asserting the Endpoint/Method/Body mapping
