function New-DNSFilterNetworkSecret {
    <#
    .SYNOPSIS
        Generates a new secret key for a DNSFilter network.

    .PARAMETER ID
        The network ID to generate a secret key for.

    .EXAMPLE
        New-DNSFilterNetworkSecret -ID 123

    .OUTPUTS
        PSCustomObject. The generated secret key.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$ID,

        [hashtable]$Session
    )

    $Endpoint = Join-Url (Join-Url '/v1/networks' $ID) 'secret_key'

    if ($PSCmdlet.ShouldProcess("Network $ID", 'Generate secret key')) {
        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Post -Session $Session
    }
}
