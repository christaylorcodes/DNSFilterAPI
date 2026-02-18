function Get-DNSFilterPolicy {
    <#
    .SYNOPSIS
        Retrieves DNSFilter policies.

    .DESCRIPTION
        Returns policies for the authenticated user, all policies, or a specific policy by ID.
        Use -IncludeGlobal to include global policies in results.

    .PARAMETER ID
        The ID of a specific policy to retrieve.

    .PARAMETER All
        Return all policies.

    .PARAMETER IncludeGlobal
        Include global policies in results.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Get-DNSFilterPolicy

    .EXAMPLE
        Get-DNSFilterPolicy -ID 123

    .EXAMPLE
        Get-DNSFilterPolicy -IncludeGlobal

    .OUTPUTS
        PSCustomObject. Policy objects.
    #>
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'ID')]
        [int]$ID,

        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [switch]$IncludeGlobal,

        [hashtable]$Session
    )

    $Endpoint = '/v1/policies'
    if ($All) { $Endpoint = Join-Url $Endpoint 'all' }
    if ($PSBoundParameters.ContainsKey('ID')) { $Endpoint = Join-Url $Endpoint $ID }

    $Query = @{}
    if ($IncludeGlobal) { $Query.include_global_policies = 'true' }

    Invoke-DNSFilterRequest -Endpoint $Endpoint -QueryParameters $Query -Session $Session
}
