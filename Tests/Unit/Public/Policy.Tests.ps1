BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Get-DNSFilterPolicy' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/policies by default' {
        Get-DNSFilterPolicy
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/policies'
        }
    }

    It 'Requests a specific policy by ID' {
        Get-DNSFilterPolicy -ID 123
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/policies/123'
        }
    }

    It 'Adds the include_global_policies query parameter with -IncludeGlobal' {
        Get-DNSFilterPolicy -IncludeGlobal
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $QueryParameters.include_global_policies -eq 'true'
        }
    }
}

Describe 'New-DNSFilterPolicy' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'POSTs to /v1/policies with name and organization_id, mapping switches to snake_case' {
        New-DNSFilterPolicy -Name 'Strict' -OrganizationId 123 -GoogleSafeSearch $true -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/policies' -and
            $Method -eq 'Post' -and
            $Body.policy.name -eq 'Strict' -and
            $Body.policy.organization_id -eq 123 -and
            $Body.policy.google_safesearch -eq $true
        }
    }
}

Describe 'Update-DNSFilterPolicy' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'PATCHes /v1/policies/<id>' {
        Update-DNSFilterPolicy -ID 123 -Name 'Updated' -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/policies/123' -and
            $Method -eq 'Patch' -and
            $Body.policy.name -eq 'Updated'
        }
    }
}

Describe 'Remove-DNSFilterPolicy' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'DELETEs /v1/policies/<id>' {
        Remove-DNSFilterPolicy -ID 123 -Confirm:$false
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/policies/123' -and $Method -eq 'Delete'
        }
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
