function Get-DNSFilterUserAgent {
    <#
    .SYNOPSIS
        Retrieves DNSFilter user agents.

    .PARAMETER ID
        The ID of a specific user agent to retrieve.

    .PARAMETER All
        Return all user agents.

    .PARAMETER OrganizationId
        Filter user agents by organization ID.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterUserAgent

    .EXAMPLE
        Get-DNSFilterUserAgent -ID 123

    .EXAMPLE
        Get-DNSFilterUserAgent -OrganizationId 456

    .OUTPUTS
        PSCustomObject. User agent objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ID')]
        [int]$ID,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [int]$OrganizationId,

        [hashtable]$Session
    )

    $Endpoint = '/v1/user_agents'
    if ($All) { $Endpoint = Join-Url $Endpoint 'all' }
    if ($PSBoundParameters.ContainsKey('ID')) { $Endpoint = Join-Url $Endpoint $ID }

    $Query = @{}
    if ($PSBoundParameters.ContainsKey('OrganizationId')) { $Query.organization_ids = $OrganizationId }

    Invoke-DNSFilterRequest -Endpoint $Endpoint -QueryParameters $Query -Session $Session
}
