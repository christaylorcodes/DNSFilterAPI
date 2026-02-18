function Remove-DNSFilterOrganization {
    <#
    .SYNOPSIS
        Deletes a DNSFilter organization (MSP customer).

    .PARAMETER ID
        The ID of the organization to delete.

    .EXAMPLE
        Remove-DNSFilterOrganization -ID 123

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

    if ($PSCmdlet.ShouldProcess("Organization $ID", 'Delete organization')) {
        Invoke-DNSFilterRequest -Endpoint (Join-Url '/v1/organizations' $ID) -Method Delete -Session $Session
    }
}
