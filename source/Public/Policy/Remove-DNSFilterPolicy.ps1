function Remove-DNSFilterPolicy {
    <#
    .SYNOPSIS
        Deletes a DNSFilter policy.

    .PARAMETER ID
        The ID of the policy to delete.

    .EXAMPLE
        Remove-DNSFilterPolicy -ID 123

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

    if ($PSCmdlet.ShouldProcess("Policy $ID", 'Delete policy')) {
        Invoke-DNSFilterRequest -Endpoint (Join-Url '/v1/policies' $ID) -Method Delete -Session $Session
    }
}
