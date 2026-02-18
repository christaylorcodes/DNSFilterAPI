function Remove-DNSFilterUserAgent {
    <#
    .SYNOPSIS
        Removes a DNSFilter user agent.

    .PARAMETER ID
        The ID of the user agent to remove.

    .EXAMPLE
        Remove-DNSFilterUserAgent -ID 123

    .EXAMPLE
        Get-DNSFilterUserAgent -OrganizationId 456 | ForEach-Object { Remove-DNSFilterUserAgent -ID $_.id }

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

    if ($PSCmdlet.ShouldProcess("User Agent $ID", 'Remove user agent')) {
        Invoke-DNSFilterRequest -Endpoint (Join-Url '/v1/user_agents' $ID) -Method Delete -Session $Session
    }
}
