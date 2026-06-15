BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Get-DNSFilterIPAddress' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/ip_addresses by default' {
        Get-DNSFilterIPAddress
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/ip_addresses'
        }
    }

    It 'Requests a specific entry by ID' {
        Get-DNSFilterIPAddress -ID 123
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/ip_addresses/123'
        }
    }
}

Describe 'New-DNSFilterIPAddress' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'POSTs an address entry to /v1/ip_addresses' {
        New-DNSFilterIPAddress -OrganizationId 123 -NetworkId 456 -IPAddress '203.0.113.10' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/ip_addresses' -and
            $Method -eq 'Post' -and
            $Body.ip_address.organization_id -eq 123 -and
            $Body.ip_address.network_id -eq 456 -and
            $Body.ip_address.address -eq '203.0.113.10'
        }
    }

    It 'POSTs a dynamic hostname entry when -Hostname is used' {
        New-DNSFilterIPAddress -OrganizationId 123 -NetworkId 456 -Hostname 'office.dyndns.org' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Body.ip_address.dynamic_hostname -eq 'office.dyndns.org'
        }
    }
}

Describe 'Update-DNSFilterIPAddress' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'PATCHes /v1/ip_addresses/<id>' {
        Update-DNSFilterIPAddress -ID 123 -IPAddress '203.0.113.20' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/ip_addresses/123' -and
            $Method -eq 'Patch' -and
            $Body.ip_address.address -eq '203.0.113.20'
        }
    }
}

Describe 'Remove-DNSFilterIPAddress' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'DELETEs /v1/ip_addresses/<id>' {
        Remove-DNSFilterIPAddress -ID 123 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/ip_addresses/123' -and $Method -eq 'Delete'
        }
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
