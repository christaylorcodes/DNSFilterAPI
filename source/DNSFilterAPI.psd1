@{
    RootModule           = 'DNSFilterAPI.psm1'
    ModuleVersion        = '0.1.0'
    GUID                 = 'be25126d-f69e-420b-88e2-239e49446312'

    Author               = 'Chris Taylor'
    CompanyName          = 'ChrisTaylorCodes'
    Copyright            = '(c) Chris Taylor. All rights reserved.'

    Description          = 'PowerShell module for interacting with the DNSFilter REST API. Provides functions to manage organizations, networks, policies, IP addresses, user agents, and more.'

    PowerShellVersion    = '5.0'

    FunctionsToExport    = @(
        # Connection
        'Connect-DNSFilter'
        'Get-DNSFilterSession'

        # Application
        'Get-DNSFilterApplication'

        # Billing
        'Get-DNSFilterBilling'

        # Invoice
        'Get-DNSFilterInvoice'

        # IPAddress
        'Get-DNSFilterIPAddress'
        'New-DNSFilterIPAddress'
        'Remove-DNSFilterIPAddress'
        'Update-DNSFilterIPAddress'

        # Network
        'Get-DNSFilterNetwork'
        'New-DNSFilterNetwork'
        'New-DNSFilterNetworkSecret'
        'Remove-DNSFilterNetwork'
        'Set-DNSFilterLocalDomain'
        'Set-DNSFilterLocalResolver'
        'Update-DNSFilterNetwork'

        # Organization
        'Get-DNSFilterOrganization'
        'New-DNSFilterOrganization'
        'Remove-DNSFilterOrganization'
        'Update-DNSFilterOrganization'

        # Policy
        'Get-DNSFilterPolicy'
        'New-DNSFilterPolicy'
        'Remove-DNSFilterPolicy'
        'Update-DNSFilterPolicy'

        # UserAgent
        'Get-DNSFilterUserAgent'
        'Remove-DNSFilterUserAgent'
    )

    CmdletsToExport      = @()
    VariablesToExport     = @()
    AliasesToExport       = @()

    PrivateData          = @{
        PSData = @{
            Tags         = @('DNSFilter', 'DNS', 'Security', 'API', 'ChrisTaylorCodes')
            ProjectUri   = 'https://github.com/christaylorcodes/DNSFilterAPI'
            LicenseUri   = 'https://github.com/christaylorcodes/DNSFilterAPI/blob/main/LICENSE'
            ReleaseNotes = @'
## Version 0.1.0

### Initial Release
- Organizations: Get, New, Update, Remove
- Networks: Get, New, Update, Remove, Secret Key, Local Domains, Local Resolvers
- Policies: Get, New, Update, Remove
- IP Addresses: Get, New, Update, Remove
- User Agents: Get, Remove
- Applications: Get
- Billing: Get
- Invoices: Get
'@
        }
    }
}
