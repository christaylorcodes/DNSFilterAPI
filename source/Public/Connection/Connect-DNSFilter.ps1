function Connect-DNSFilter {
    <#
    .SYNOPSIS
        Authenticates to the DNSFilter API and stores the session.

    .DESCRIPTION
        Establishes a session with the DNSFilter API using a Bearer API key.
        The session is stored for use by all other module functions.

        Returns the session hashtable so it can be captured and passed via -Session
        to other functions for use in parallel runspaces (ForEach-Object -Parallel).

    .PARAMETER APIKey
        The DNSFilter API key for authentication.

    .PARAMETER BaseURI
        The base URI of the DNSFilter API. Defaults to 'api.dnsfilter.com'.

    .EXAMPLE
        Connect-DNSFilter -APIKey 'your-api-key-here'

    .EXAMPLE
        $session = Connect-DNSFilter -APIKey $Key
        1..10 | ForEach-Object -Parallel {
            Get-DNSFilterNetwork -Session $using:session
        }

    .OUTPUTS
        Hashtable. The session object (also stored in module scope).
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$APIKey,

        [ValidateNotNullOrEmpty()]
        [string]$BaseURI = 'api.dnsfilter.com'
    )

    # Strip any protocol prefix and enforce https
    $CleanURI = $BaseURI -replace '^https?://', ''
    $script:DNSFilterSession = @{
        BaseURI    = "https://$CleanURI"
        WebSession = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    }

    # Set persistent headers on the session so every subsequent request carries them
    $script:DNSFilterSession.WebSession.Headers.Add('Authorization', "Bearer $APIKey")
    $script:DNSFilterSession.WebSession.Headers.Add('Accept', 'application/json')

    $AuthParams = @{
        Uri             = Join-Url $script:DNSFilterSession.BaseURI '/v1/authenticate'
        Method          = 'Post'
        WebSession      = $script:DNSFilterSession.WebSession
        UseBasicParsing = $true
    }

    try {
        $null = Invoke-WebRequest @AuthParams
        Write-Verbose "Successfully connected to DNSFilter API at $($script:DNSFilterSession.BaseURI)"
    } catch {
        $script:DNSFilterSession = @{ BaseURI = $null; WebSession = $null }
        throw "Failed to connect to DNSFilter API: $($_.Exception.Message)"
    }

    $script:DNSFilterSession
}
