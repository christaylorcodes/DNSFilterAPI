function New-DNSFilterOrganization {
    <#
    .SYNOPSIS
        Creates a new DNSFilter organization.

    .PARAMETER Name
        The name of the organization.

    .PARAMETER BillingContactName
        Billing contact name.

    .PARAMETER BillingContactPhone
        Billing contact phone number.

    .PARAMETER BillingContactEmail
        Billing contact email address.

    .PARAMETER Address
        Organization address.

    .PARAMETER ManagedByMSPId
        The MSP ID that manages this organization.

    .PARAMETER UniqueId
        A unique identifier for the organization.

    .PARAMETER ExternalId
        An external identifier for the organization.

    .EXAMPLE
        New-DNSFilterOrganization -Name 'Contoso Ltd'

    .EXAMPLE
        New-DNSFilterOrganization -Name 'Contoso Ltd' -ManagedByMSPId 456 -ExternalId 'CRM-123'

    .OUTPUTS
        PSCustomObject. The created organization object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
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

    if ($PSCmdlet.ShouldProcess($Name, 'Create organization')) {
        Invoke-DNSFilterRequest -Endpoint '/v1/organizations' -Method Post -Body @{
            organization = $Org
        } -Session $Session
    }
}
