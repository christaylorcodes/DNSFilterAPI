function Get-DNSFilterApplication {
    <#
    .SYNOPSIS
        Retrieves DNSFilter applications.

    .DESCRIPTION
        Returns active applications, all applications (including deleted), or a specific application by ID.

    .PARAMETER ID
        The ID of a specific application to retrieve.

    .PARAMETER All
        Return all applications including deleted ones.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterApplication

    .EXAMPLE
        Get-DNSFilterApplication -ID 123

    .EXAMPLE
        Get-DNSFilterApplication -All

    .OUTPUTS
        PSCustomObject. Application objects.
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

    $Endpoint = '/v1/applications'
    if ($All) { $Endpoint = Join-Url $Endpoint 'all' }
    if ($PSBoundParameters.ContainsKey('ID')) { $Endpoint = Join-Url $Endpoint $ID }

    Invoke-DNSFilterRequest -Endpoint $Endpoint -Session $Session
}
