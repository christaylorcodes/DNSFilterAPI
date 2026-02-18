function Get-DNSFilterBilling {
    <#
    .SYNOPSIS
        Retrieves billing information for an organization.

    .PARAMETER OrganizationId
        The organization ID to get billing for.

    .EXAMPLE
        Get-DNSFilterBilling -OrganizationId 12345

    .OUTPUTS
        PSCustomObject. Billing information.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$OrganizationId,

        [hashtable]$Session
    )

    Invoke-DNSFilterRequest -Endpoint '/v1/billing' -QueryParameters @{
        organization_id = $OrganizationId
    } -Session $Session
}
