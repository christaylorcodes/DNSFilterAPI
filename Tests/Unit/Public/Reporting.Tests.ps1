BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Get-DNSFilterApplication' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/applications by default' {
        Get-DNSFilterApplication
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/applications'
        }
    }

    It 'Requests /v1/applications/all with -All' {
        Get-DNSFilterApplication -All
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/applications/all'
        }
    }
}

Describe 'Get-DNSFilterBilling' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/billing with the organization_id query parameter' {
        Get-DNSFilterBilling -OrganizationId 12345
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/billing' -and $QueryParameters.organization_id -eq 12345
        }
    }
}

Describe 'Get-DNSFilterInvoice' -Tag 'Unit', 'Public' {
    BeforeEach { Mock -CommandName Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' }

    It 'Requests /v1/invoices by default with no query parameters' {
        Get-DNSFilterInvoice
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Endpoint -eq '/v1/invoices' -and $null -eq $QueryParameters
        }
    }

    It 'Filters invoices by organization_id when supplied' {
        Get-DNSFilterInvoice -OrganizationId 12345
        Should -Invoke Invoke-DNSFilterRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $QueryParameters.organization_id -eq 12345
        }
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
