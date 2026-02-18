function Get-DNSFilterNetwork {
    <#
    .SYNOPSIS
        Retrieves DNSFilter networks.

    .DESCRIPTION
        Returns networks for the authenticated user, all networks, a specific network by ID,
        or networks filtered by organization.

    .PARAMETER ID
        The ID of a specific network to retrieve.

    .PARAMETER All
        Return all networks.

    .PARAMETER OrganizationId
        Filter networks by organization ID.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterNetwork

    .EXAMPLE
        Get-DNSFilterNetwork -ID 123

    .EXAMPLE
        Get-DNSFilterNetwork -All

    .EXAMPLE
        Get-DNSFilterNetwork -OrganizationId 456

    .OUTPUTS
        PSCustomObject. Network objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ID')]
        [int]$ID,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Organization')]
        [int]$OrganizationId,

        [hashtable]$Session
    )

    $Endpoint = '/v1/networks'
    if ($All) { $Endpoint = Join-Url $Endpoint 'all' }
    if ($PSBoundParameters.ContainsKey('ID')) { $Endpoint = Join-Url $Endpoint $ID }

    $Results = Invoke-DNSFilterRequest -Endpoint $Endpoint -Session $Session

    if ($PSBoundParameters.ContainsKey('OrganizationId')) {
        $Results | Where-Object { $_.relationships.organization.data.id -eq $OrganizationId }
    } else {
        $Results
    }
}
