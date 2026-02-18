function Get-DNSFilterSession {
    <#
    .SYNOPSIS
        Returns the current DNSFilter API session information.

    .DESCRIPTION
        Returns the base URI and whether a session object has been initialized.
        Does not expose the session cookie or credentials.

        Note: SessionExists reflects whether Connect-DNSFilter has been called,
        not whether the session token is still valid on the server.

    .EXAMPLE
        Get-DNSFilterSession

    .OUTPUTS
        PSCustomObject. Session information with BaseURI and SessionExists status.
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    [PSCustomObject]@{
        BaseURI       = $script:DNSFilterSession.BaseURI
        SessionExists = [bool]$script:DNSFilterSession.WebSession
    }
}
