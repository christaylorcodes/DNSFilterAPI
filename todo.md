# DNSFilterAPI Module - TODO

## Project Scaffolding

- [ ] Add `README.md` with quick start, function list, examples
- [ ] Add `LICENSE` (MIT)
- [ ] Add `CONTRIBUTING.md` with build/test instructions
- [x] Add `CHANGELOG.md`
- [ ] Add `.github/` templates (issue, PR)

## Build System

- [x] Add `build.ps1` bootstrap script (Invoke-Build)
- [x] Add `build.yaml` (Sampler/ModuleBuilder configuration)
- [x] Add `.build/custom.tasks.ps1` for PSScriptAnalyzer, docs generation
- [x] Add `Resolve-Dependency.psd1`
- [x] Add `source/prefix.ps1` / `source/suffix.ps1` for ModuleBuilder
- [x] Configure `output/` directory for built module artifacts
- [x] Wire up explicit `FunctionsToExport` list generation in built manifest (no wildcards)

## Testing

- [x] Add `tests/Unit/Module.Tests.ps1` (module loads, exports correct functions, no missing help)
- [ ] Add unit tests per resource category with mocked `Invoke-DNSFilterRequest`
- [ ] Add `tests/Integration/` for live API tests (tagged, skipped by default)
- [ ] Add code coverage target (80%+)

## Documentation

- [ ] Generate PlatyPS markdown help (`docs/` folder)
- [ ] Generate MAML help from markdown
- [ ] Add usage examples for common MSP workflows (bulk org creation, policy assignment, network setup)

## API Coverage - Full CRUD for Existing Resources

- [ ] `Update-DNSFilterUserAgent` (PUT `/v1/user_agents/{id}`)
- [ ] `Get-DNSFilterInvoice -Current` (GET `/v1/invoices/current`)
- [ ] `New-DNSFilterBilling` (POST `/v1/billing` - register payment method)

## API Coverage - New Resource Types

### Block Pages
- [ ] `Get-DNSFilterBlockPage` (GET `/v1/block_pages`, `/all`, `/{id}`)
- [ ] `New-DNSFilterBlockPage` (POST `/v1/block_pages`)
- [ ] `Update-DNSFilterBlockPage` (PUT `/v1/block_pages/{id}`)
- [ ] `Remove-DNSFilterBlockPage` (DELETE `/v1/block_pages/{id}`)

### Categories
- [ ] `Get-DNSFilterCategory` (GET `/v1/categories`, `/all`, `/{id}`)

### Domains
- [ ] `Get-DNSFilterDomainLookup` (GET `/v1/domains/user_lookup`)
- [ ] `Get-DNSFilterDomainBulkLookup` (GET `/v1/domains/bulk_lookup`)
- [ ] `Submit-DNSFilterDomainCategory` (POST `/v1/domains/suggest_categories`)
- [ ] `Submit-DNSFilterDomainThreat` (POST `/v1/domains/suggest_threat`)

### MAC Addresses
- [ ] `Get-DNSFilterMACAddress` (GET `/v1/mac_addresses`, `/all`, `/{id}`)
- [ ] `New-DNSFilterMACAddress` (POST `/v1/mac_addresses`)
- [ ] `Update-DNSFilterMACAddress` (PUT `/v1/mac_addresses/{id}`)
- [ ] `Remove-DNSFilterMACAddress` (DELETE `/v1/mac_addresses/{id}`)

### Scheduled Policies
- [ ] `Get-DNSFilterScheduledPolicy` (GET `/v1/scheduled_policies`, `/all`, `/{id}`)
- [ ] `New-DNSFilterScheduledPolicy` (POST `/v1/scheduled_policies`)
- [ ] `Update-DNSFilterScheduledPolicy` (PUT `/v1/scheduled_policies/{id}`)
- [ ] `Remove-DNSFilterScheduledPolicy` (DELETE `/v1/scheduled_policies/{id}`)

### Traffic Reports
- [ ] `Get-DNSFilterTrafficReport` (GET `/v1/traffic_reports/total_requests`)
- [ ] `Get-DNSFilterTrafficReportByOrganization` (GET `/v1/traffic_reports/total_requests_organizations`)
- [ ] `Get-DNSFilterTrafficReportByAgent` (GET `/v1/traffic_reports/total_requests_agents`)

### Policy Domain/Category/App Management
- [ ] `Add-DNSFilterPolicyBlacklistDomain` (POST `/v1/policies/{id}/add_blacklist_domain`)
- [ ] `Remove-DNSFilterPolicyBlacklistDomain` (POST `/v1/policies/{id}/remove_blacklist_domain`)
- [ ] `Add-DNSFilterPolicyWhitelistDomain` (POST `/v1/policies/{id}/add_whitelist_domain`)
- [ ] `Remove-DNSFilterPolicyWhitelistDomain` (POST `/v1/policies/{id}/remove_whitelist_domain`)
- [ ] `Add-DNSFilterPolicyBlacklistCategory` (POST `/v1/policies/{id}/add_blacklist_category`)
- [ ] `Remove-DNSFilterPolicyBlacklistCategory` (POST `/v1/policies/{id}/remove_blacklist_category`)
- [ ] `Add-DNSFilterPolicyAllowedApplication` (POST `/v1/policies/{id}/add_allowed_application`)
- [ ] `Remove-DNSFilterPolicyAllowedApplication` (POST `/v1/policies/{id}/remove_allowed_application`)
- [ ] `Add-DNSFilterPolicyBlockedApplication` (POST `/v1/policies/{id}/add_blocked_application`)
- [ ] `Remove-DNSFilterPolicyBlockedApplication` (POST `/v1/policies/{id}/remove_blocked_application`)

### Organization Users
- [ ] `Get-DNSFilterOrganizationUser` (GET `/v1/organizations/{org_id}/users/`, `/{id}`)
- [ ] `Add-DNSFilterOrganizationUser` (POST `/v1/organizations/{org_id}/users`)
- [ ] `Update-DNSFilterOrganizationUser` (PUT `/v1/organizations/{org_id}/users/{id}`)
- [ ] `Remove-DNSFilterOrganizationUser` (DELETE `/v1/organizations/{org_id}/users/{id}`)

### Agent Local Users
- [ ] `Get-DNSFilterAgentLocalUser` (GET `/v1/agent_local_users`, `/all`, `/{id}`)
- [ ] `Update-DNSFilterAgentLocalUser` (PUT `/v1/agent_local_users/{id}`)

### Network Subnets
- [ ] `Get-DNSFilterNetworkSubnet` (GET `/v1/networks/{id}/subnets`, `/{subnet_id}`)
- [ ] `New-DNSFilterNetworkSubnet` (POST `/v1/networks/{id}/subnets`)
- [ ] `Update-DNSFilterNetworkSubnet` (PUT `/v1/networks/{id}/subnets/{subnet_id}`)
- [ ] `Remove-DNSFilterNetworkSubnet` (DELETE `/v1/networks/{id}/subnets/{subnet_id}`)

### Network LAN IPs
- [ ] `Get-DNSFilterNetworkLanIP` (GET `/v1/networks/{id}/lan_ips`, `/{lan_ip_id}`)
- [ ] `Update-DNSFilterNetworkLanIP` (PUT `/v1/networks/{id}/lan_ips/{lan_ip_id}`)

### Networks (additional)
- [ ] `Get-DNSFilterNetworkMSP` (GET `/v1/networks/msp`, `/msp/all`)
- [ ] `Find-DNSFilterNetwork` (GET `/v1/networks/lookup`)
- [ ] `Remove-DNSFilterNetworkSecret` (DELETE `/v1/networks/{id}/secret_key`)
- [ ] `Update-DNSFilterNetworkSecret` (PATCH `/v1/networks/{id}/secret_key`)

### IP Addresses (additional)
- [ ] `Test-DNSFilterIPAddress` (GET `/v1/ip_addresses/verify`)
- [ ] `Get-DNSFilterMyIP` (GET `/v1/ip_addresses/myip`)

### Organizations (additional)
- [ ] `Stop-DNSFilterOrganization` (POST `/v1/organizations/{id}/cancel`)
- [ ] `Set-DNSFilterOrganizationMSP` (POST `/v1/organizations/promote_to_msp/`)

### Policy IPs
- [ ] `Get-DNSFilterPolicyIP` (GET `/v1/policy_ips`, `/{id}`)

### Collection Users
- [ ] `Get-DNSFilterCollectionUser` (GET `/v1/collections/{id}/users/`, `/{user_id}`)
- [ ] `Add-DNSFilterCollectionUser` (POST `/v1/collections/{id}/users/`)
- [ ] `Remove-DNSFilterCollectionUser` (DELETE `/v1/collections/{id}/users/{user_id}`)

## Publishing

- [ ] Run `Promote-Project.ps1` readiness scan
- [ ] Create GitHub repo at `christaylorcodes/DNSFilterAPI`
- [ ] Publish v1.0.0 to PowerShell Gallery
