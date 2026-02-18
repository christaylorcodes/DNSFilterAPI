function Join-Url {
    <#
    .SYNOPSIS
        Joins URL path segments, handling trailing/leading slashes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$ChildPath
    )

    "$($Path.TrimEnd('/'))/$($ChildPath.TrimStart('/'))"
}
