# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Build system using Sampler/ModuleBuilder with Invoke-Build
- Pester 5 unit tests for module loading, exports, and function standards
- PSScriptAnalyzer integration via build tasks (format, lint)
- GitHub Actions CI/CD pipeline (build, test, lint, analyze, publish)
- PR validation workflow (changelog and version checks)

## [0.1.0] - 2025-01-01

### Added

- Organizations: Get, New, Update, Remove
- Networks: Get, New, Update, Remove, Secret Key, Local Domains, Local Resolvers
- Policies: Get, New, Update, Remove
- IP Addresses: Get, New, Update, Remove
- User Agents: Get, Remove
- Applications: Get
- Billing: Get
- Invoices: Get
- Session management with thread-safe `-Session` parameter pattern
- TLS 1.2 enforcement via prefix.ps1
