<h1 align="center">
  <br>
  <img src="./Media/Logo.png" alt="DNSFilterAPI logo" width="500">
  <br>
  DNSFilterAPI
  <br>
</h1>

<h4 align="center">

PowerShell module for the DNSFilter REST API.

</h4>

<div align="center">

[![CI](https://github.com/christaylorcodes/DNSFilterAPI/actions/workflows/ci.yml/badge.svg)](https://github.com/christaylorcodes/DNSFilterAPI/actions/workflows/ci.yml)
[![PS Gallery](https://img.shields.io/powershellgallery/v/DNSFilterAPI?label=PS%20Gallery&logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/DNSFilterAPI)
[![Downloads](https://img.shields.io/powershellgallery/dt/DNSFilterAPI?label=Downloads&logo=powershell&logoColor=white)](https://www.powershellgallery.com/packages/DNSFilterAPI)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Donate](https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&style=flat)](https://github.com/christaylorcodes/GitHub-Template/blob/main/DONATE.md)

</div>
<p align="center">
    <a href="#functions">Functions</a> •
    <a href="#examples">Examples</a> •
    <a href="#install">Install</a> •
    <a href="#contributing">Contributing</a> •
    <a href="https://github.com/christaylorcodes/DNSFilterAPI/issues/new?template=bug_report.md">Submit a Bug</a> •
    <a href="https://github.com/christaylorcodes/DNSFilterAPI/issues/new?template=feature_request.md">Request a Feature</a>
</p>

<!-- Summary -->

DNSFilterAPI wraps the [DNSFilter](https://www.dnsfilter.com/) REST API in idiomatic PowerShell.
It lets MSPs and admins manage organizations, networks, policies, IP addresses, and user agents
from the command line or in automation — with built-in support for thread-safe parallel execution.

<!-- Summary -->

## Install

The module targets **PowerShell 5.1+** (Windows PowerShell and PowerShell 7+).

```powershell
Install-Module DNSFilterAPI -Repository PSGallery
```

> If you have issues accessing the PowerShell Gallery, see this [repair script](https://github.com/christaylorcodes/Initialize-PSGallery).

## Examples

```powershell
# Authenticate (your API key comes from the DNSFilter dashboard)
Connect-DNSFilter -APIKey '<your-api-key>'

# List your networks, or fetch one by ID
Get-DNSFilterNetwork
Get-DNSFilterNetwork -ID 123

# Create an organization and a network under it
$org = New-DNSFilterOrganization -Name 'Contoso Ltd'
New-DNSFilterNetwork -Name 'HQ' -OrganizationId $org.id

# Update a policy (uses PATCH, so unspecified fields are left untouched)
Update-DNSFilterPolicy -ID 456 -GoogleSafeSearch $true -YouTubeRestricted $true
```

### Thread-safe parallel usage

Every function accepts an optional `-Session`. Capture the session from `Connect-DNSFilter`
and pass it into `ForEach-Object -Parallel` runspaces:

```powershell
$session = Connect-DNSFilter -APIKey '<your-api-key>'

Get-DNSFilterOrganization -All | ForEach-Object -Parallel {
    Get-DNSFilterNetwork -OrganizationId $_.id -Session $using:session
}
```

## Functions

| Resource | Functions |
| -------- | --------- |
| **Connection** | `Connect-DNSFilter`, `Get-DNSFilterSession` |
| **Organizations** | `Get-DNSFilterOrganization`, `New-DNSFilterOrganization`, `Update-DNSFilterOrganization`, `Remove-DNSFilterOrganization` |
| **Networks** | `Get-DNSFilterNetwork`, `New-DNSFilterNetwork`, `Update-DNSFilterNetwork`, `Remove-DNSFilterNetwork`, `New-DNSFilterNetworkSecret`, `Set-DNSFilterLocalDomain`, `Set-DNSFilterLocalResolver` |
| **Policies** | `Get-DNSFilterPolicy`, `New-DNSFilterPolicy`, `Update-DNSFilterPolicy`, `Remove-DNSFilterPolicy` |
| **IP Addresses** | `Get-DNSFilterIPAddress`, `New-DNSFilterIPAddress`, `Update-DNSFilterIPAddress`, `Remove-DNSFilterIPAddress` |
| **User Agents** | `Get-DNSFilterUserAgent`, `Remove-DNSFilterUserAgent` |
| **Applications** | `Get-DNSFilterApplication` |
| **Billing & Invoices** | `Get-DNSFilterBilling`, `Get-DNSFilterInvoice` |

Every function ships with comment-based help — run `Get-Help <FunctionName> -Full` for parameters and examples.

## Contributing

If this project helps you, please give it a star — it helps others find it and tells me which
projects to invest in. Contributions of all kinds are welcome; see the
[contributing guide](.github/CONTRIBUTING.md) to get started, and run `./Tests/test-local.ps1`
before opening a pull request.

## Donating

It takes time to maintain this project. If it saves you time and you'd like to give back,
[donations are appreciated](https://github.com/christaylorcodes/GitHub-Template/blob/main/DONATE.md)
and let me spend more time on features and fixes.
