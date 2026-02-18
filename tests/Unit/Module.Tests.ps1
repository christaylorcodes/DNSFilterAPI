<#
.SYNOPSIS
    Unit tests for DNSFilterAPI module - no API connection required.

.DESCRIPTION
    Tests module loading, function exports, parameter validation, and help quality.
    Uses dynamic discovery to automatically test all exported functions.

.NOTES
    Version:        0.1.0
    Author:         Chris Taylor
#>

# BeforeDiscovery runs before test discovery - used for -ForEach data
BeforeDiscovery {
    $ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $OutputModule = Get-ChildItem -Path "$ProjectRoot/output/DNSFilterAPI/*/DNSFilterAPI.psd1" -ErrorAction SilentlyContinue |
        Sort-Object { [version](Split-Path (Split-Path $_.FullName -Parent) -Leaf) } -Descending |
        Select-Object -First 1

    if (-not $OutputModule) {
        throw "Module not built. Run '.\build.ps1 -Tasks build' first."
    }

    Import-Module $OutputModule.FullName -Force -ErrorAction Stop

    # Discover all exported functions for -ForEach tests
    $script:AllFunctions = @(Get-Command -Module DNSFilterAPI -CommandType Function)

    # Destructive functions (should support ShouldProcess)
    $script:DestructiveFunctions = @($script:AllFunctions | Where-Object {
        $_.Name -match '^(New-|Update-|Remove-|Set-)DNSFilter'
    })

    # Get functions with parameter sets (Default, ID, All pattern)
    $script:GetFunctionsWithParamSets = @($script:AllFunctions | Where-Object {
        $_.Name -match '^Get-DNSFilter' -and
        $_.ParameterSets.Count -gt 1
    })
}

BeforeAll {
    # Import module for test execution
    $ProjectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
    $OutputModule = Get-ChildItem -Path "$ProjectRoot/output/DNSFilterAPI/*/DNSFilterAPI.psd1" -ErrorAction SilentlyContinue |
        Sort-Object { [version](Split-Path (Split-Path $_.FullName -Parent) -Leaf) } -Descending |
        Select-Object -First 1

    Import-Module $OutputModule.FullName -Force -ErrorAction Stop
}

#region Module Loading Tests

Describe 'Module: DNSFilterAPI' {
    Context 'Module Loading' {
        It 'Module is loaded' {
            Get-Module -Name DNSFilterAPI | Should -Not -BeNullOrEmpty
        }

        It 'Module has correct name' {
            (Get-Module -Name DNSFilterAPI).Name | Should -Be 'DNSFilterAPI'
        }

        It 'Module version is 0.1.0 or higher' {
            $version = (Get-Module -Name DNSFilterAPI).Version
            $version | Should -BeGreaterOrEqual ([version]'0.1.0')
        }

        It 'Requires PowerShell 5.0 or higher' {
            $module = Get-Module -Name DNSFilterAPI
            $module.PowerShellVersion | Should -BeGreaterOrEqual ([version]'5.0')
        }

        It 'Exports at least 20 functions' {
            $FunctionCount = (Get-Command -Module DNSFilterAPI -CommandType Function).Count
            $FunctionCount | Should -BeGreaterOrEqual 20
        }

        It 'Does not export any aliases' {
            $module = Get-Module -Name DNSFilterAPI
            $module.ExportedAliases.Count | Should -Be 0
        }
    }
}

#endregion

#region Generic Function Tests (Apply to ALL functions)

Describe 'All Exported Functions' {
    Context 'Function Standards' {
        It '<_.Name> uses CmdletBinding' -ForEach $script:AllFunctions {
            $_.CmdletBinding | Should -Be $true -Because "All functions should use [CmdletBinding()]"
        }

        It '<_.Name> has help synopsis' -ForEach $script:AllFunctions {
            $Help = Get-Help $_.Name -ErrorAction SilentlyContinue
            $Help.Synopsis | Should -Not -BeNullOrEmpty
            $Help.Synopsis | Should -Not -Match "^\s*$($_.Name)\s*$" -Because "Synopsis should not just be the function name"
        }

        It '<_.Name> has OutputType attribute' -ForEach $script:AllFunctions {
            $_.OutputType.Count | Should -BeGreaterThan 0 -Because "All functions should declare [OutputType()]"
        }
    }

    Context 'Session Parameter' {
        It '<_.Name> has Session parameter' -ForEach $script:AllFunctions {
            if ($_.Name -eq 'Get-DNSFilterSession') {
                # Get-DNSFilterSession doesn't need a Session parameter
                Set-ItResult -Skipped -Because "Get-DNSFilterSession reads module-scoped session"
            } elseif ($_.Name -eq 'Connect-DNSFilter') {
                # Connect-DNSFilter creates the session, doesn't consume it
                Set-ItResult -Skipped -Because "Connect-DNSFilter creates the session"
            } else {
                $_.Parameters.Keys | Should -Contain 'Session' -Because "All API functions should accept -Session for thread safety"
            }
        }
    }

    Context 'Destructive Functions' {
        It '<_.Name> supports WhatIf/Confirm' -ForEach $script:DestructiveFunctions {
            $_.Parameters.Keys | Should -Contain 'WhatIf' -Because "Destructive functions should support -WhatIf"
            $_.Parameters.Keys | Should -Contain 'Confirm' -Because "Destructive functions should support -Confirm"
        }
    }
}

#endregion

#region Core Function Tests

Describe 'Core Functions' {
    Context 'Connect-DNSFilter' {
        BeforeAll {
            $script:ConnectCmd = Get-Command -Name Connect-DNSFilter
        }

        It 'Has mandatory APIKey parameter' {
            $script:ConnectCmd.Parameters['APIKey'].Attributes |
                Where-Object { $_.Mandatory -eq $true } |
                Should -Not -BeNullOrEmpty
        }

        It 'APIKey parameter is string type' {
            $script:ConnectCmd.Parameters['APIKey'].ParameterType.Name | Should -Be 'String'
        }

        It 'Has optional BaseURI parameter with default' {
            $script:ConnectCmd.Parameters['BaseURI'] | Should -Not -BeNullOrEmpty
            # BaseURI should not be mandatory
            $mandatoryAttr = $script:ConnectCmd.Parameters['BaseURI'].Attributes |
                Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.Mandatory -eq $true }
            $mandatoryAttr | Should -BeNullOrEmpty
        }

        It 'Has OutputType of hashtable' {
            $script:ConnectCmd.OutputType.Type.Name | Should -Contain 'Hashtable'
        }
    }

    Context 'Get-DNSFilterSession' {
        It 'Has OutputType declared' {
            $cmd = Get-Command -Name Get-DNSFilterSession
            $cmd.OutputType.Count | Should -BeGreaterThan 0
        }
    }
}

#endregion

#region Get Function Parameter Set Tests

Describe 'Get Functions with Parameter Sets' {
    Context '<_.Name> parameter sets' -ForEach $script:GetFunctionsWithParamSets {
        It 'Has Default parameter set' {
            $_.ParameterSets.Name | Should -Contain 'Default'
        }

        It 'Has ID parameter in ID parameter set' {
            $idParam = $_.Parameters['ID']
            if ($idParam) {
                $idParamSet = $idParam.Attributes |
                    Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] -and $_.ParameterSetName -eq 'ID' }
                $idParamSet | Should -Not -BeNullOrEmpty
            } else {
                Set-ItResult -Skipped -Because "Function does not use ID parameter"
            }
        }
    }
}

#endregion

#region Remove Function Tests

Describe 'Remove Functions' {
    BeforeDiscovery {
        $script:RemoveFunctions = @(Get-Command -Module DNSFilterAPI -CommandType Function | Where-Object {
            $_.Name -match '^Remove-DNSFilter'
        })
    }

    Context '<_.Name>' -ForEach $script:RemoveFunctions {
        It 'Has ConfirmImpact High' {
            $CmdletBinding = $_.ScriptBlock.Attributes |
                Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
            $CmdletBinding.ConfirmImpact | Should -Be 'High'
        }

        It 'Has mandatory ID parameter' {
            $_.Parameters['ID'].Attributes |
                Where-Object { $_.Mandatory -eq $true } |
                Should -Not -BeNullOrEmpty
        }
    }
}

#endregion

#region Private Function Tests

Describe 'Private Helper Functions' {
    Context 'Invoke-DNSFilterRequest' {
        It 'Is available within module scope' {
            $result = & (Get-Module DNSFilterAPI) { Get-Command Invoke-DNSFilterRequest -ErrorAction SilentlyContinue }
            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Join-Url' {
        It 'Is available within module scope' {
            $result = & (Get-Module DNSFilterAPI) { Get-Command Join-Url -ErrorAction SilentlyContinue }
            $result | Should -Not -BeNullOrEmpty
        }

        It 'Joins URL segments correctly' {
            $result = & (Get-Module DNSFilterAPI) { Join-Url 'https://api.example.com' '/v1/test' }
            $result | Should -Be 'https://api.example.com/v1/test'
        }

        It 'Handles trailing and leading slashes' {
            $result = & (Get-Module DNSFilterAPI) { Join-Url 'https://api.example.com/' '/v1/test' }
            $result | Should -Be 'https://api.example.com/v1/test'
        }
    }
}

#endregion

AfterAll {
    Remove-Module -Name DNSFilterAPI -Force -ErrorAction SilentlyContinue
}
