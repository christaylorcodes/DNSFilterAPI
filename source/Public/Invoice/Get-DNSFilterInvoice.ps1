function Get-DNSFilterInvoice {
    <#
    .SYNOPSIS
        Retrieves DNSFilter invoices.

    .DESCRIPTION
        Returns invoices, optionally filtered by organization ID.

    .PARAMETER OrganizationId
        Filter invoices by organization ID.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterInvoice

    .EXAMPLE
        Get-DNSFilterInvoice -OrganizationId 12345

    .OUTPUTS
        PSCustomObject. Invoice objects.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [int]$OrganizationId,

        [hashtable]$Session
    )

    $RequestParams = @{ Endpoint = '/v1/invoices'; Session = $Session }
    if ($PSBoundParameters.ContainsKey('OrganizationId')) {
        $RequestParams.QueryParameters = @{ organization_id = $OrganizationId }
    }

    Invoke-DNSFilterRequest @RequestParams
}
