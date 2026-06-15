BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Get-DNSFilterOrganization' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/organizations by default' {
        Get-DNSFilterOrganization
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/organizations'
        }
    }

    It 'Requests a specific organization by ID' {
        Get-DNSFilterOrganization -ID 123
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/organizations/123'
        }
    }

    It 'Requests /v1/organizations/all with -All' {
        Get-DNSFilterOrganization -All
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/organizations/all'
        }
    }
}

Describe 'New-DNSFilterOrganization' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'POSTs to /v1/organizations with a mapped organization body' {
        New-DNSFilterOrganization -Name 'Contoso Ltd' -ExternalId 'CRM-123' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/organizations' -and
            $Method -eq 'Post' -and
            $Body.organization.name -eq 'Contoso Ltd' -and
            $Body.organization.external_id -eq 'CRM-123'
        }
    }
}

Describe 'Update-DNSFilterOrganization' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'PATCHes /v1/organizations/<id>' {
        Update-DNSFilterOrganization -ID 123 -Name 'Contoso LLC' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/organizations/123' -and
            $Method -eq 'Patch' -and
            $Body.organization.name -eq 'Contoso LLC'
        }
    }
}

Describe 'Remove-DNSFilterOrganization' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'DELETEs /v1/organizations/<id>' {
        Remove-DNSFilterOrganization -ID 123 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/organizations/123' -and $Method -eq 'Delete'
        }
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
