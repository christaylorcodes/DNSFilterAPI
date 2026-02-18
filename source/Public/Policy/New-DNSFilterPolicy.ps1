function New-DNSFilterPolicy {
    <#
    .SYNOPSIS
        Creates a new DNSFilter policy.

    .PARAMETER Name
        The name of the policy.

    .PARAMETER OrganizationId
        The organization ID this policy belongs to.

    .PARAMETER AllowUnknownDomains
        Whether to allow unknown/uncategorized domains.

    .PARAMETER GoogleSafeSearch
        Enable Google SafeSearch enforcement.

    .PARAMETER BingSafeSearch
        Enable Bing SafeSearch enforcement.

    .PARAMETER DuckDuckGoSafeSearch
        Enable DuckDuckGo SafeSearch enforcement.

    .PARAMETER YouTubeRestricted
        Enable YouTube restricted mode.

    .PARAMETER YouTubeRestrictedLevel
        YouTube restriction level (e.g., 'moderate', 'strict').

    .PARAMETER Interstitial
        Enable interstitial warning pages.

    .PARAMETER PolicyIpId
        The policy IP ID.

    .PARAMETER WhitelistDomains
        Array of domains to allow.

    .PARAMETER BlacklistDomains
        Array of domains to block.

    .PARAMETER BlacklistCategories
        Array of category IDs to block.

    .PARAMETER IsGlobalPolicy
        Whether this is a global policy.

    .PARAMETER AllowApplications
        Array of application names to allow.

    .PARAMETER BlockApplications
        Array of application names to block.

    .EXAMPLE
        New-DNSFilterPolicy -Name 'Standard Policy' -OrganizationId 123

    .EXAMPLE
        New-DNSFilterPolicy -Name 'Strict Policy' -OrganizationId 123 -GoogleSafeSearch $true -YouTubeRestricted $true

    .OUTPUTS
        PSCustomObject. The created policy object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [int]$OrganizationId,

        [bool]$AllowUnknownDomains,
        [bool]$GoogleSafeSearch,
        [bool]$BingSafeSearch,
        [bool]$DuckDuckGoSafeSearch,
        [bool]$YouTubeRestricted,
        [string]$YouTubeRestrictedLevel,
        [bool]$Interstitial,
        [int]$PolicyIpId,
        [string[]]$WhitelistDomains,
        [string[]]$BlacklistDomains,
        [int[]]$BlacklistCategories,
        [bool]$IsGlobalPolicy,
        [string[]]$AllowApplications,
        [string[]]$BlockApplications,

        [hashtable]$Session
    )

    $Policy = @{
        name            = $Name
        organization_id = $OrganizationId
    }

    $ParamMap = @{
        AllowUnknownDomains    = 'allow_unknown_domains'
        GoogleSafeSearch       = 'google_safesearch'
        BingSafeSearch         = 'bing_safe_search'
        DuckDuckGoSafeSearch   = 'duck_duck_go_safe_search'
        YouTubeRestricted      = 'youtube_restricted'
        YouTubeRestrictedLevel = 'youtube_restricted_level'
        Interstitial           = 'interstitial'
        PolicyIpId             = 'policy_ip_id'
        WhitelistDomains       = 'whitelist_domains'
        BlacklistDomains       = 'blacklist_domains'
        BlacklistCategories    = 'blacklist_categories'
        IsGlobalPolicy         = 'is_global_policy'
        AllowApplications      = 'allow_applications'
        BlockApplications      = 'block_applications'
    }

    foreach ($Param in $ParamMap.GetEnumerator()) {
        if ($PSBoundParameters.ContainsKey($Param.Key)) {
            $Policy[$Param.Value] = $PSBoundParameters[$Param.Key]
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create policy')) {
        Invoke-DNSFilterRequest -Endpoint '/v1/policies' -Method Post -Body @{
            policy = $Policy
        } -Session $Session
    }
}
