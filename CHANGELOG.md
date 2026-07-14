# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- `Get-DNSFilterUserAgent` and `Remove-DNSFilterUserAgent`: `-ID` was typed `[int]`, but the DNSFilter
  API returns user agent IDs as GUID strings (unlike organization/network IDs, which are numeric).
  This caused every `Remove-DNSFilterUserAgent -ID $Agent.id` call to fail parameter binding before
  reaching the API. `-ID` is now `[string]` on both functions.

## [1.0.0] - 2026-06-15

### Added

- Organizations: Get, New, Update, Remove
- Networks: Get, New, Update, Remove, Secret Key, Local Domains, Local Resolvers
- Policies: Get, New, Update, Remove
- IP Addresses: Get, New, Update, Remove
- User Agents: Get, Remove
- Applications: Get
- Billing: Get
- Invoices: Get
- Session management with a thread-safe `-Session` parameter pattern for `ForEach-Object -Parallel`
- TLS 1.2 enforcement via `prefix.ps1`
- Build system using Sampler/ModuleBuilder with Invoke-Build
- Request-mocked Pester 5 unit tests per resource, plus module loading and function-standard tests
- PSScriptAnalyzer integration via build tasks (format, lint) using the shared strict ruleset
- GitHub Actions CI/CD pipeline (build, test, lint, analyze, publish on tag)
- PR validation workflow (changelog and version checks)
- Documentation and repo health files: README, MIT LICENSE, and GitHub community files
  (CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, issue and pull request templates)
