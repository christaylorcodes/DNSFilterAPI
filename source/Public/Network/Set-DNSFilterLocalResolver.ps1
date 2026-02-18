function Set-DNSFilterLocalResolver {
    <#
    .SYNOPSIS
        Sets local resolvers for a DNSFilter network.

    .DESCRIPTION
        Replaces or appends local resolvers on a network. Use -Append to add to the
        existing list instead of replacing it.

    .PARAMETER NetworkId
        The network ID to configure.

    .PARAMETER LocalResolvers
        Array of local resolver addresses to set.

    .PARAMETER Append
        Append to existing resolvers instead of replacing them.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Set-DNSFilterLocalResolver -NetworkId 123 -LocalResolvers '192.168.1.1', '192.168.1.2'

    .EXAMPLE
        Set-DNSFilterLocalResolver -NetworkId 123 -LocalResolvers '10.0.0.1' -Append

    .OUTPUTS
        PSCustomObject. The updated network object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$NetworkId,

        [Parameter(Mandatory)]
        [string[]]$LocalResolvers,

        [switch]$Append,

        [hashtable]$Session
    )

    $Endpoint = Join-Url '/v1/networks' $NetworkId

    if ($PSCmdlet.ShouldProcess("Network $NetworkId", 'Set local resolvers')) {
        if ($Append) {
            $Existing = Get-DNSFilterNetwork -ID $NetworkId -Session $Session
            $LocalResolvers = @($LocalResolvers) + @($Existing.attributes.local_resolvers) | Sort-Object -Unique
        }

        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Patch -Body @{
            network = @{
                local_resolvers = $LocalResolvers
            }
        } -Session $Session
    }
}
