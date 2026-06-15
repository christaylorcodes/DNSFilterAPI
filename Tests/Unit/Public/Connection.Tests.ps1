BeforeAll {
    # Find and import TestHelper (works at any directory depth under Tests/)
    $testDir = $PSScriptRoot
    while ($testDir -and !(Test-Path (Join-Path $testDir 'TestHelpers/TestHelper.psm1'))) {
        $testDir = Split-Path -Parent $testDir
    }
    Import-Module (Join-Path $testDir 'TestHelpers/TestHelper.psm1') -Force
    $script:Module = Initialize-TestModule
}

Describe 'Connect-DNSFilter' -Tag 'Unit', 'Public' {
    BeforeEach {
        Mock -CommandName Invoke-WebRequest -ModuleName 'DNSFilterAPI' -MockWith { }
    }

    It 'Authenticates against /v1/authenticate with POST' {
        Connect-DNSFilter -APIKey 'test-key' | Out-Null
        Should -Invoke Invoke-WebRequest -ModuleName 'DNSFilterAPI' -Times 1 -Exactly -ParameterFilter {
            $Uri -like '*/v1/authenticate' -and $Method -eq 'Post'
        }
    }

    It 'Returns a session hashtable with the default BaseURI' {
        $session = Connect-DNSFilter -APIKey 'test-key'
        $session | Should -BeOfType [hashtable]
        $session.BaseURI | Should -Be 'https://api.dnsfilter.com'
        $session.WebSession | Should -Not -BeNullOrEmpty
    }

    It 'Normalizes a custom BaseURI and forces https' {
        $session = Connect-DNSFilter -APIKey 'test-key' -BaseURI 'http://custom.example.com'
        $session.BaseURI | Should -Be 'https://custom.example.com'
    }

    It 'Throws and clears the session when authentication fails' {
        Mock -CommandName Invoke-WebRequest -ModuleName 'DNSFilterAPI' -MockWith { throw 'unauthorized' }
        { Connect-DNSFilter -APIKey 'bad-key' } | Should -Throw '*Failed to connect to DNSFilter API*'
        (Get-DNSFilterSession).SessionExists | Should -BeFalse
    }
}

Describe 'Get-DNSFilterSession' -Tag 'Unit', 'Public' {
    BeforeAll {
        Mock -CommandName Invoke-WebRequest -ModuleName 'DNSFilterAPI' -MockWith { }
        Connect-DNSFilter -APIKey 'test-key' | Out-Null
    }

    It 'Reports BaseURI and SessionExists without exposing credentials' {
        $info = Get-DNSFilterSession
        $info | Should -BeOfType [PSCustomObject]
        $info.PSObject.Properties.Name | Should -Contain 'BaseURI'
        $info.PSObject.Properties.Name | Should -Contain 'SessionExists'
        $info.SessionExists | Should -BeTrue
        $info.PSObject.Properties.Name | Should -Not -Contain 'WebSession'
    }
}

AfterAll {
    if ($script:Module) {
        Remove-Module -Name $script:Module.Name -Force -ErrorAction SilentlyContinue
    }
    Remove-Module -Name 'TestHelper' -Force -ErrorAction SilentlyContinue
}
