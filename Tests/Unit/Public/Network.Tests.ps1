BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Get-DNSFilterNetwork' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/networks by default' {
        Get-DNSFilterNetwork
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks'
        }
    }

    It 'Requests a specific network by ID' {
        Get-DNSFilterNetwork -ID 123
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/123'
        }
    }

    It 'Requests /v1/networks/all with -All' {
        Get-DNSFilterNetwork -All
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/all'
        }
    }
}

Describe 'New-DNSFilterNetwork' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'POSTs to /v1/networks with a mapped network body' {
        New-DNSFilterNetwork -Name 'Main Office' -OrganizationId 123 -PolicyId 456 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks' -and
            $Method -eq 'Post' -and
            $Body.network.name -eq 'Main Office' -and
            $Body.network.organization_id -eq 123 -and
            $Body.network.policy_id -eq 456
        }
    }

    It 'Does not call the API when -WhatIf is used' {
        New-DNSFilterNetwork -Name 'Main Office' -OrganizationId 123 -WhatIf
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 0 -Exactly
    }
}

Describe 'Update-DNSFilterNetwork' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'PATCHes /v1/networks/<id> (never PUT)' {
        Update-DNSFilterNetwork -ID 123 -Name 'Renamed' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/123' -and
            $Method -eq 'Patch' -and
            $Body.network.name -eq 'Renamed'
        }
    }

    It 'Only includes bound parameters in the body' {
        Update-DNSFilterNetwork -ID 123 -PolicyId 789 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Body.network.policy_id -eq 789 -and -not $Body.network.ContainsKey('name')
        }
    }
}

Describe 'Remove-DNSFilterNetwork' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'DELETEs /v1/networks/<id>' {
        Remove-DNSFilterNetwork -ID 123 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/123' -and $Method -eq 'Delete'
        }
    }
}

Describe 'New-DNSFilterNetworkSecret' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'POSTs to /v1/networks/<id>/secret_key' {
        New-DNSFilterNetworkSecret -ID 123 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/123/secret_key' -and $Method -eq 'Post'
        }
    }
}

Describe 'Set-DNSFilterLocalDomain' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'PATCHes the network with local_domains' {
        Set-DNSFilterLocalDomain -NetworkId 123 -LocalDomains 'corp.local', 'internal.lan' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/123' -and
            $Method -eq 'Patch' -and
            $Body.network.local_domains -contains 'corp.local' -and
            $Body.network.local_domains -contains 'internal.lan'
        }
    }
}

Describe 'Set-DNSFilterLocalResolver' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'PATCHes the network with local_resolvers' {
        Set-DNSFilterLocalResolver -NetworkId 123 -LocalResolvers '192.168.1.1' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/networks/123' -and
            $Method -eq 'Patch' -and
            $Body.network.local_resolvers -contains '192.168.1.1'
        }
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
