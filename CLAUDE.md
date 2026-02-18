# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PowerShell module (v0.1.0) wrapping the DNSFilter REST API. Targets PowerShell 5.0+. No build system or test framework yet — see `todo.md` for the full roadmap.

## Commands

```powershell
# Lint with PSScriptAnalyzer (settings in PSScriptAnalyzerSettings.psd1)
Invoke-ScriptAnalyzer -Path ./source -Recurse -Settings ./PSScriptAnalyzerSettings.psd1

# Import the module locally for testing
Import-Module ./source/DNSFilterAPI.psd1 -Force
```

No build, test, or CI pipeline exists yet.

## Architecture

### Module Loading

`source/DNSFilterAPI.psm1` dot-sources everything in order:
1. `prefix.ps1` — forces TLS 1.2
2. `Private/*.ps1` — internal helpers
3. `Public/*/*.ps1` — exported functions (one file per function, grouped by resource subfolder)

Exported functions are explicitly listed in `source/DNSFilterAPI.psd1` (`FunctionsToExport`).

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

**Destructive functions** (New, Update, Remove) declare `[CmdletBinding(SupportsShouldProcess)]` for `-WhatIf`/`-Confirm` support.

## Code Style (PSScriptAnalyzer)

- 4-space indentation, open brace on same line, no assignment alignment
- `PSUseSingularNouns` rule is excluded (resource names like `Get-DNSFilterIPAddresses` are allowed)
- Pipeline indentation increases for first pipeline component

## Adding a New Function

1. Create `source/Public/<ResourceCategory>/<Verb>-DNSFilter<Resource>.ps1`
2. Follow the ParamMap + ShouldProcess pattern from existing functions
3. Include `[hashtable]$Session` parameter and pass `-Session $Session` to `Invoke-DNSFilterRequest`
4. Use `$PSBoundParameters.ContainsKey()` for optional int parameters, never `if ($Variable)`
5. Use `Patch` (not `Put`) for Update functions to avoid overwriting unspecified fields
6. Add the function name to `FunctionsToExport` in `source/DNSFilterAPI.psd1`
7. API base path convention: `/v1/<resource_name_snake_case>`
8. Close braces before `else`/`elseif` go on the same line: `} else {` (PSPlaceCloseBrace rule)
