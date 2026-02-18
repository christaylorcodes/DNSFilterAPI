function Set-DNSFilterLocalDomain {
    <#
    .SYNOPSIS
        Sets local domains for a DNSFilter network.

    .DESCRIPTION
        Replaces or appends local domains on a network. Use -Append to add to the
        existing list instead of replacing it.

    .PARAMETER NetworkId
        The network ID to configure.

    .PARAMETER LocalDomains
        Array of local domain names to set.

    .PARAMETER Append
        Append to existing domains instead of replacing them.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Set-DNSFilterLocalDomain -NetworkId 123 -LocalDomains 'corp.local', 'internal.lan'

    .EXAMPLE
        Set-DNSFilterLocalDomain -NetworkId 123 -LocalDomains 'new.local' -Append

    .OUTPUTS
        PSCustomObject. The updated network object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$NetworkId,

        [Parameter(Mandatory)]
        [string[]]$LocalDomains,

        [switch]$Append,

        [hashtable]$Session
    )

    $Endpoint = Join-Url '/v1/networks' $NetworkId

    if ($PSCmdlet.ShouldProcess("Network $NetworkId", 'Set local domains')) {
        if ($Append) {
            $Existing = Get-DNSFilterNetwork -ID $NetworkId -Session $Session
            $LocalDomains = @($LocalDomains) + @($Existing.attributes.local_domains) | Sort-Object -Unique
        }

        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Patch -Body @{
            network = @{
                local_domains = $LocalDomains
            }
        } -Session $Session
    }
}
