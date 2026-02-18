<#
    .SYNOPSIS
        PowerShell module for interacting with the DNSFilter API.

    .DESCRIPTION
        This module provides functions to manage DNSFilter organizations, networks,
        policies, IP addresses, user agents, and more via the DNSFilter REST API.

        Requires PowerShell 5.0 or higher.

    .NOTES
        Module:  DNSFilterAPI
        Author:  Chris Taylor
        Version: 0.1.0
#>

# Run prefix initialization
. "$PSScriptRoot\prefix.ps1"

# Import private functions
$Private = Get-ChildItem "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
foreach ($File in $Private) {
    try { . $File.FullName }
    catch { Write-Error "Failed to import private function $($File.Name): $_" }
}

# Import public functions
$Public = Get-ChildItem "$PSScriptRoot\Public\*\*.ps1" -ErrorAction SilentlyContinue
foreach ($File in $Public) {
    try { . $File.FullName }
    catch { Write-Error "Failed to import public function $($File.Name): $_" }
}
