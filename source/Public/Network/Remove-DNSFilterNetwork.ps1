function Remove-DNSFilterNetwork {
    <#
    .SYNOPSIS
        Deletes a DNSFilter network.

    .PARAMETER ID
        The ID of the network to delete.

    .EXAMPLE
        Remove-DNSFilterNetwork -ID 123

    .OUTPUTS
        PSCustomObject. Deletion result.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$ID,

        [hashtable]$Session
    )

    if ($PSCmdlet.ShouldProcess("Network $ID", 'Delete network')) {
        Invoke-DNSFilterRequest -Endpoint (Join-Url '/v1/networks' $ID) -Method Delete -Session $Session
    }
}
