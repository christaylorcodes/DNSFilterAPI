function Update-DNSFilterNetwork {
    <#
    .SYNOPSIS
        Updates an existing DNSFilter network.

    .PARAMETER ID
        The ID of the network to update.

    .PARAMETER Name
        Updated network name.

    .PARAMETER OrganizationId
        Updated organization ID.

    .PARAMETER PolicyId
        Updated policy ID.

    .PARAMETER ScheduledPolicyId
        Updated scheduled policy ID.

    .PARAMETER BlockPageId
        Updated block page ID.

    .EXAMPLE
        Update-DNSFilterNetwork -ID 123 -Name 'Updated Office' -PolicyId 789

    .OUTPUTS
        PSCustomObject. The updated network object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$ID,

        [string]$Name,
        [int]$OrganizationId,
        [int]$PolicyId,
        [int]$ScheduledPolicyId,
        [int]$BlockPageId,

        [hashtable]$Session
    )

    $ParamMap = @{
        Name              = 'name'
        OrganizationId    = 'organization_id'
        PolicyId          = 'policy_id'
        ScheduledPolicyId = 'scheduled_policy_id'
        BlockPageId       = 'block_page_id'
    }

    $Network = @{}
    foreach ($Param in $ParamMap.GetEnumerator()) {
        if ($PSBoundParameters.ContainsKey($Param.Key)) {
            $Network[$Param.Value] = $PSBoundParameters[$Param.Key]
        }
    }

    $Endpoint = Join-Url '/v1/networks' $ID

    if ($PSCmdlet.ShouldProcess("Network $ID", 'Update network')) {
        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Patch -Body @{
            network = $Network
        } -Session $Session
    }
}
