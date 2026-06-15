BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:ModuleInfo = Initialize-TestModule
    $script:ProjectRoot = Get-ProjectRoot
    $script:AllFunctions = @(Get-Command -Module $script:ModuleInfo.Name -CommandType Function)
}

Describe 'DNSFilterAPI Module' -Tag 'Unit', 'Module' {

    Context 'Module Import' {
        It 'Should import without errors' {
            $script:ModuleInfo | Should -Not -BeNullOrEmpty
        }

        It 'Should be loaded in the current session' {
            Get-Module -Name $script:ModuleInfo.Name | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Module Manifest' {
        BeforeAll {
            $script:ManifestPath = Get-ModuleManifestPath
            $script:Manifest = Test-ModuleManifest -Path $script:ManifestPath -ErrorAction Stop
        }

        It 'Should have a valid manifest' {
            $script:Manifest | Should -Not -BeNullOrEmpty
        }

        It 'Should be version 1.0.0 or higher' {
            $script:Manifest.Version | Should -BeGreaterOrEqual ([version]'1.0.0')
        }

        It 'Should require PowerShell 5.0 or higher' {
            $script:Manifest.PowerShellVersion | Should -BeGreaterOrEqual ([version]'5.0')
        }

        It 'Should have a description' {
            $script:Manifest.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should have an author' {
            $script:Manifest.Author | Should -Not -BeNullOrEmpty
        }

        It 'Should support PSEdition Core' {
            $script:Manifest.CompatiblePSEditions | Should -Contain 'Core'
        }

        It 'Should declare a LicenseUri' {
            $script:Manifest.PrivateData.PSData.LicenseUri | Should -Not -BeNullOrEmpty
        }

        It 'Should declare a ProjectUri' {
            $script:Manifest.PrivateData.PSData.ProjectUri | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Exported Functions' {
        BeforeAll {
            $publicPath = Join-Path $script:ProjectRoot 'source' 'Public'
            # Public functions are organized into category subfolders -> recurse
            $script:PublicFunctions = Get-ChildItem -Path $publicPath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
            $script:ExportedCommands = $script:ModuleInfo.ExportedCommands.Keys
        }

        It 'Should export at least 20 functions' {
            $script:ExportedCommands.Count | Should -BeGreaterOrEqual 20
        }

        It 'Should export a function for each Public/**/*.ps1 file' {
            foreach ($file in $script:PublicFunctions) {
                $script:ExportedCommands | Should -Contain $file.BaseName
            }
        }

        It 'Should not export any private functions' {
            $privatePath = Join-Path $script:ProjectRoot 'source' 'Private'
            $privateFunctions = Get-ChildItem -Path $privatePath -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue
            foreach ($file in $privateFunctions) {
                $script:ExportedCommands | Should -Not -Contain $file.BaseName
            }
        }

        It 'Should use only approved verbs' {
            $approvedVerbs = Get-Verb | Select-Object -ExpandProperty Verb
            foreach ($cmd in $script:ExportedCommands) {
                $verb = ($cmd -split '-')[0]
                $verb | Should -BeIn $approvedVerbs -Because "$cmd should use an approved verb"
            }
        }

        It 'Should not export any aliases' {
            $script:ModuleInfo.ExportedAliases.Count | Should -Be 0
        }
    }

    Context 'Function Standards' {
        It 'Every function uses CmdletBinding' {
            foreach ($fn in $script:AllFunctions) {
                $fn.CmdletBinding | Should -BeTrue -Because "$($fn.Name) should use [CmdletBinding()]"
            }
        }

        It 'Every function declares an OutputType' {
            foreach ($fn in $script:AllFunctions) {
                $fn.OutputType.Count | Should -BeGreaterThan 0 -Because "$($fn.Name) should declare [OutputType()]"
            }
        }

        It 'Every function has a help synopsis' {
            foreach ($fn in $script:AllFunctions) {
                $help = Get-Help $fn.Name -ErrorAction SilentlyContinue
                $help.Synopsis | Should -Not -BeNullOrEmpty -Because "$($fn.Name) should have a .SYNOPSIS"
                $help.Synopsis | Should -Not -Match "^\s*$($fn.Name)\s*$" -Because "$($fn.Name) synopsis should not just be the name"
            }
        }
    }

    Context 'Session Parameter' {
        It 'Every API function accepts -Session' {
            $exempt = @('Connect-DNSFilter', 'Get-DNSFilterSession')
            foreach ($fn in ($script:AllFunctions | Where-Object { $_.Name -notin $exempt })) {
                $fn.Parameters.Keys | Should -Contain 'Session' -Because "$($fn.Name) should accept -Session for thread safety"
            }
        }
    }

    Context 'Destructive Functions' {
        It 'Every state-changing function supports -WhatIf and -Confirm' {
            $destructive = $script:AllFunctions | Where-Object { $_.Name -match '^(New|Update|Remove|Set)-DNSFilter' }
            foreach ($fn in $destructive) {
                $fn.Parameters.Keys | Should -Contain 'WhatIf' -Because "$($fn.Name) should support -WhatIf"
                $fn.Parameters.Keys | Should -Contain 'Confirm' -Because "$($fn.Name) should support -Confirm"
            }
        }

        It 'Every Remove function has high ConfirmImpact and a mandatory ID' {
            $removeFunctions = $script:AllFunctions | Where-Object { $_.Name -match '^Remove-DNSFilter' }
            foreach ($fn in $removeFunctions) {
                $binding = $fn.ScriptBlock.Attributes |
                    Where-Object { $_ -is [System.Management.Automation.CmdletBindingAttribute] }
                $binding.ConfirmImpact | Should -Be 'High' -Because "$($fn.Name) deletes data"

                $mandatory = $fn.Parameters['ID'].Attributes | Where-Object { $_.Mandatory -eq $true }
                $mandatory | Should -Not -BeNullOrEmpty -Because "$($fn.Name) should require -ID"
            }
        }
    }
}

AfterAll {
    if ($script:ModuleInfo) {
        Remove-Module -Name $script:ModuleInfo.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
