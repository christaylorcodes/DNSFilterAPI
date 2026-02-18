function Update-DNSFilterPolicy {
    <#
    .SYNOPSIS
        Updates an existing DNSFilter policy.

    .PARAMETER ID
        The ID of the policy to update.

    .PARAMETER Name
        Updated policy name.

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
        YouTube restriction level.

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

    .PARAMETER AllowApplications
        Array of application names to allow.

    .PARAMETER BlockApplications
        Array of application names to block.

    .EXAMPLE
        Update-DNSFilterPolicy -ID 123 -Name 'Updated Policy'

    .EXAMPLE
        Update-DNSFilterPolicy -ID 123 -GoogleSafeSearch $true -YouTubeRestricted $true

    .OUTPUTS
        PSCustomObject. The updated policy object.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [int]$ID,

        [string]$Name,
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
        [string[]]$AllowApplications,
        [string[]]$BlockApplications,

        [hashtable]$Session
    )

    $Policy = @{}

    $ParamMap = @{
        Name                   = 'name'
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
        AllowApplications      = 'allow_applications'
        BlockApplications      = 'block_applications'
    }

    foreach ($Param in $ParamMap.GetEnumerator()) {
        if ($PSBoundParameters.ContainsKey($Param.Key)) {
            $Policy[$Param.Value] = $PSBoundParameters[$Param.Key]
        }
    }

    $Endpoint = Join-Url '/v1/policies' $ID

    if ($PSCmdlet.ShouldProcess("Policy $ID", 'Update policy')) {
        Invoke-DNSFilterRequest -Endpoint $Endpoint -Method Patch -Body @{
            policy = $Policy
        } -Session $Session
    }
}
