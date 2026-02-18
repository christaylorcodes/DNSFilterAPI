function Remove-DNSFilterIPAddress {
    <#
    .SYNOPSIS
        Deletes a DNSFilter IP address entry.

    .PARAMETER ID
        The ID of the IP address entry to delete.

    .EXAMPLE
        Remove-DNSFilterIPAddress -ID 123

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

    if ($PSCmdlet.ShouldProcess("IP Address $ID", 'Delete IP address')) {
        Invoke-DNSFilterRequest -Endpoint (Join-Url '/v1/ip_addresses' $ID) -Method Delete -Session $Session
    }
}
