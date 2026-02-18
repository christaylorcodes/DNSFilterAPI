function Update-DNSFilterOrganization {
    <#
    .SYNOPSIS
        Updates an existing DNSFilter organization.

    .PARAMETER ID
        The ID of the organization to update.

    .PARAMETER Name
        New name for the organization.

    .PARAMETER BillingContactName
        Updated billing contact name.

    .PARAMETER BillingContactPhone
        Updated billing contact phone number.

    .PARAMETER BillingContactEmail
        Updated billing contact email address.

    .PARAMETER Address
        Updated organization address.

    .PARAMETER ManagedByMSPId
        Updated MSP ID that manages this organization.

    .PARAMETER UniqueId
        Updated unique identifier.

    .PARAMETER ExternalId
        Updated external identifier.

    .PARAMETER Session
        Optional session object from Connect-DNSFilter for thread-safe usage.

    .EXAMPLE
        Update-DNSFilterOrganization -ID 123 -Name 'Contoso LLC'

    .OUTPUTS
        PSCustomObject. The updated organization object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$ID,

        [string]$Name,
        [string]$BillingContactName,
        [string]$BillingContactPhone,
        [string]$BillingContactEmail,
        [string]$Address,
        [int]$ManagedByMSPId,
        [string]$UniqueId,
        [string]$ExternalId,

        [hashtable]$Session
    )

    $ParamMap = @{
        Name                = 'name'
        BillingContactName  = 'billing_contact_name'
        BillingContactPhone = 'billing_contact_phone'
        BillingContactEmail = 'billing_contact_email'
        Address             = 'address'
        ManagedByMSPId      = 'managed_by_msp_id'
        UniqueId            = 'unique_id'
        ExternalId          = 'external_id'
    }

    $Org = @{}
    foreach ($Param in $ParamMap.GetEnumerator()) {
        if ($PSBoundParameters.ContainsKey($Param.Key)) {
            $Org[$Param.Value] = $PSBoundParameters[$Param.Key]
        }
    }

    $Endpoint = Join-Url '/v1/organizations' $ID

    if ($PSCmdlet.ShouldProcess("Organization $ID", 'Update organization')) {
        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Patch -Body @{
            organization = $Org
        } -Session $Session
    }
}
