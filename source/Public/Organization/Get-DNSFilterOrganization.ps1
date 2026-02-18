function Get-DNSFilterOrganization {
    <#
    .SYNOPSIS
        Retrieves DNSFilter organizations.

    .DESCRIPTION
        Returns organizations for the authenticated user, all organizations, or a specific organization by ID.

    .PARAMETER ID
        The ID of a specific organization to retrieve.

    .PARAMETER All
        Return all organizations.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterOrganization

    .EXAMPLE
        Get-DNSFilterOrganization -ID 123

    .EXAMPLE
        Get-DNSFilterOrganization -All

    .OUTPUTS
        PSCustomObject. Organization objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ID')]
        [int]$ID,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [hashtable]$Session
    )

    $Endpoint = '/v1/organizations'
    if ($All) { $Endpoint = Join-Url $Endpoint 'all' }
    if ($PSBoundParameters.ContainsKey('ID')) { $Endpoint = Join-Url $Endpoint $ID }

    Invoke-DNSFilterRequest -Endpoint $Endpoint -Session $Session
}
