BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Get-DNSFilterUserAgent' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/user_agents by default' {
        Get-DNSFilterUserAgent
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/user_agents'
        }
    }

    It 'Requests a specific user agent by ID' {
        Get-DNSFilterUserAgent -ID '210bbb7e-a08d-4d8c-8de8-9d47d6968f7e'
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/user_agents/210bbb7e-a08d-4d8c-8de8-9d47d6968f7e'
        }
    }

    It 'Filters by organization via the organization_ids query parameter' {
        Get-DNSFilterUserAgent -OrganizationId 456
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/user_agents' -and $QueryParameters.organization_ids -eq 456
        }
    }
}

Describe 'Remove-DNSFilterUserAgent' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'DELETEs /v1/user_agents/<id>' {
        Remove-DNSFilterUserAgent -ID '210bbb7e-a08d-4d8c-8de8-9d47d6968f7e' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/user_agents/210bbb7e-a08d-4d8c-8de8-9d47d6968f7e' -and $Method -eq 'Delete'
        }
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
