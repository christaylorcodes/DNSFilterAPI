function Get-DNSFilterIPAddress {
    <#
    .SYNOPSIS
        Retrieves DNSFilter IP addresses.

    .PARAMETER ID
        The ID of a specific IP address to retrieve.

    .PARAMETER All
        Return all IP addresses.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterIPAddress

    .EXAMPLE
        Get-DNSFilterIPAddress -ID 123

    .EXAMPLE
        Get-DNSFilterIPAddress -All

    .OUTPUTS
        PSCustomObject. IP address objects.
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

    $Endpoint = '/v1/ip_addresses'
    if ($All) { $Endpoint = Join-Url $Endpoint 'all' }
    if ($PSBoundParameters.ContainsKey('ID')) { $Endpoint = Join-Url $Endpoint $ID }

    Invoke-DNSFilterRequest -Endpoint $Endpoint -Session $Session
}
