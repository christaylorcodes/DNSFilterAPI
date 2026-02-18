function Invoke-DNSFilterRequest {
    <#
    .SYNOPSIS
        Makes an HTTP request to the DNSFilter API.

    .DESCRIPTION
        Internal helper function that handles session validation, URI construction,
        JSON serialization, and error handling for all DNSFilter API calls.

        Accepts an optional -Session parameter for thread safety. When omitted,
        falls back to the module-scoped $script:DNSFilterSession.

    .NOTES
        This is a private function and should not be called directly.
        Requires Connect-DNSFilter to be called first.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [ValidateSet('Get', 'Post', 'Put', 'Delete', 'Patch')]
        [string]$Method = 'Get',

        [hashtable]$Body,

        [hashtable]$QueryParameters,

        [hashtable]$Session
    )

    # Resolve session: explicit parameter wins, then fall back to module scope
    $ResolvedSession = if ($Session) { $Session } else { $script:DNSFilterSession }

    if (-not $ResolvedSession.WebSession) {
        throw 'No active DNSFilter session. Run Connect-DNSFilter first.'
    }

    # Build URI
    $Uri = Join-Url $ResolvedSession.BaseURI $Endpoint

    # Append query parameters
    if ($QueryParameters -and $QueryParameters.Count -gt 0) {
        $QueryParts = foreach ($Key in $QueryParameters.Keys) {
            $Value = $QueryParameters[$Key]
            if ($null -eq $Value) { continue }
            '{0}={1}' -f [uri]::EscapeDataString($Key), [uri]::EscapeDataString($Value)
        }
        $Separator = if ($Uri.Contains('?')) { '&' } else { '?' }
        $Uri = $Uri + $Separator + ($QueryParts -join '&')
    }

    $RequestParams = @{
        Uri             = $Uri
        Method          = $Method
        WebSession      = $ResolvedSession.WebSession
        UseBasicParsing = $true
    }

    if ($Body) {
        $RequestParams.Body = $Body | ConvertTo-Json -Depth 10
        $RequestParams.ContentType = 'application/json'
        Write-Verbose "Request body: $($RequestParams.Body)"
    }

    Write-Verbose "Invoking DNSFilter API: $Method $Uri"

    try {
        $Response = Invoke-RestMethod @RequestParams
    } catch {
        $WebException = $_
        $ErrorMessage = $WebException.Exception.Message
        if ($WebException.ErrorDetails.Message) {
            try {
                $ApiError = $WebException.ErrorDetails.Message | ConvertFrom-Json
                if ($ApiError.errors) {
                    $ErrorMessage = ($ApiError.errors | ForEach-Object { $_.detail }) -join '; '
                }
            } catch {
                $ErrorMessage = $WebException.ErrorDetails.Message
            }
        }
        throw "DNSFilter API request failed ($Method $Endpoint): $ErrorMessage"
    }

    if ($null -ne $Response.data) {
        return $Response.data
    }
    return $Response
}
