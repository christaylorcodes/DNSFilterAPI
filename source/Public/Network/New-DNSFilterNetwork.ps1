function New-DNSFilterNetwork {
    <#
    .SYNOPSIS
        Creates a new DNSFilter network.

    .PARAMETER Name
        The name of the network.

    .PARAMETER OrganizationId
        The organization ID this network belongs to.

    .PARAMETER PolicyId
        The policy ID to assign to the network.

    .PARAMETER ScheduledPolicyId
        The scheduled policy ID to assign.

    .PARAMETER BlockPageId
        The block page ID to assign.

    .PARAMETER ExternalId
        An external identifier for the network.

    .EXAMPLE
        New-DNSFilterNetwork -Name 'Main Office' -OrganizationId 123

    .EXAMPLE
        New-DNSFilterNetwork -Name 'Branch Office' -OrganizationId 123 -PolicyId 456

    .OUTPUTS
        PSCustomObject. The created network object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$OrganizationId,

        [int]$PolicyId,
        [int]$ScheduledPolicyId,
        [int]$BlockPageId,
        [string]$ExternalId,

        [hashtable]$Session
    )

    $ParamMap = @{
        Name              = 'name'
        OrganizationId    = 'organization_id'
        PolicyId          = 'policy_id'
        ScheduledPolicyId = 'scheduled_policy_id'
        BlockPageId       = 'block_page_id'
        ExternalId        = 'external_id'
    }

    $Network = @{}
    foreach ($Param in $ParamMap.GetEnumerator()) {
        if ($PSBoundParameters.ContainsKey($Param.Key)) {
            $Network[$Param.Value] = $PSBoundParameters[$Param.Key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create network')) {
        Invoke-DNSFilterRequest -Endpoint '/v1/networks' -Method Post -Body @{
            network = $Network
        } -Session $Session
    }
}
