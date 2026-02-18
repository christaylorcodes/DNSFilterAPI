function Update-DNSFilterIPAddress {
    <#
    .SYNOPSIS
        Updates an existing DNSFilter IP address entry.

    .PARAMETER ID
        The ID of the IP address entry to update.

    .PARAMETER IPAddress
        Updated IP address.

    .PARAMETER Hostname
        Updated dynamic hostname.

    .PARAMETER NetworkId
        Updated network ID.

    .EXAMPLE
        Update-DNSFilterIPAddress -ID 123 -IPAddress '203.0.113.20'

    .EXAMPLE
        Update-DNSFilterIPAddress -ID 123 -Hostname 'new-office.dyndns.org'

    .OUTPUTS
        PSCustomObject. The updated IP address object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$ID,

        [ipaddress]$IPAddress,
        [string]$Hostname,
        [int]$NetworkId,

        [hashtable]$Session
    )

    $IpEntry = @{}
    if ($PSBoundParameters.ContainsKey('IPAddress')) { $IpEntry.address = $IPAddress.ToString() }
    if ($PSBoundParameters.ContainsKey('Hostname')) { $IpEntry.dynamic_hostname = $Hostname }
    if ($PSBoundParameters.ContainsKey('NetworkId')) { $IpEntry.network_id = $NetworkId }

    $Endpoint = Join-Url '/v1/ip_addresses' $ID

    if ($PSCmdlet.ShouldProcess("IP Address $ID", 'Update IP address')) {
        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Patch -Body @{
            ip_address = $IpEntry
        } -Session $Session
    }
}
