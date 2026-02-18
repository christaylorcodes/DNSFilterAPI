function New-DNSFilterIPAddress {
    <#
    .SYNOPSIS
        Creates a new DNSFilter IP address entry.

    .PARAMETER OrganizationId
        The organization ID for this IP address.

    .PARAMETER NetworkId
        The network ID to associate this IP address with.

    .PARAMETER IPAddress
        The IP address to register. Mutually exclusive with Hostname.

    .PARAMETER Hostname
        A dynamic hostname to register. Mutually exclusive with IPAddress.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        New-DNSFilterIPAddress -OrganizationId 123 -NetworkId 456 -IPAddress '203.0.113.10'

    .EXAMPLE
        New-DNSFilterIPAddress -OrganizationId 123 -NetworkId 456 -Hostname 'office.example.dyndns.org'

    .OUTPUTS
        PSCustomObject. The created IP address object.
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'IPAddress')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$OrganizationId,

        [Parameter(Mandatory)]
        [int]$NetworkId,

        [Parameter(Mandatory, ParameterSetName = 'IPAddress')]
        [ipaddress]$IPAddress,

        [Parameter(Mandatory, ParameterSetName = 'Hostname')]
        [string]$Hostname,

        [hashtable]$Session
    )

    $IpEntry = @{
        organization_id = $OrganizationId
        network_id      = $NetworkId
    }
    if ($PSBoundParameters.ContainsKey('IPAddress')) { $IpEntry.address = $IPAddress.ToString() }
    if ($PSBoundParameters.ContainsKey('Hostname')) { $IpEntry.dynamic_hostname = $Hostname }

    $DisplayName = if ($PSBoundParameters.ContainsKey('IPAddress')) { $IPAddress.ToString() } else { $Hostname }

    if ($PSCmdlet.ShouldProcess($DisplayName, 'Create IP address')) {
        Invoke-DNSFilterRequest -Endpoint '/v1/ip_addresses' -Method Post -Body @{
            ip_address = $IpEntry
        } -Session $Session
    }
}
