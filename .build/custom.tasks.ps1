# Custom build tasks for DNSFilterAPI module

task Format_Source_Code {
    $SourcePath = Join-Path $BuildRoot 'source'
    $SettingsFile = Join-Path $BuildRoot 'PSScriptAnalyzerSettings.psd1'

    if (-not (Test-Path $SourcePath)) {
        Write-Build Yellow "Source path not found: $SourcePath"
        return
    }

    if (-not (Test-Path $SettingsFile)) {
        Write-Build Yellow "Settings file not found: $SettingsFile"
        return
    }

    Write-Build Cyan "Formatting PowerShell files in: $SourcePath"

    $files = Get-ChildItem -Path $SourcePath -Recurse -Filter '*.ps1'
    $formattedCount = 0

    foreach ($file in $files) {
        $original = Get-Content -Path $file.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($original)) { continue }

        try {
            $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $SettingsFile -ErrorAction Stop

            # Only write if we got valid formatted content and it differs from original
            if (-not [string]::IsNullOrWhiteSpace($formatted) -and $formatted -ne $original) {
                Set-Content -Path $file.FullName -Value $formatted -NoNewline -Encoding UTF8
                Write-Build DarkGray "  Formatted: $($file.Name)"
                $formattedCount++
            }
        }
        catch {
            Write-Build Yellow "  Skipped (format error): $($file.Name) - $($_.Exception.Message)"
        }
    }

    if ($formattedCount -gt 0) {
        Write-Build Green "Formatted $formattedCount file(s)"
    }
    else {
        Write-Build Green "All files already properly formatted"
    }
}

task Check_Source_Formatting {
    $SourcePath = Join-Path $BuildRoot 'source'
    $SettingsFile = Join-Path $BuildRoot 'PSScriptAnalyzerSettings.psd1'

    if (-not (Test-Path $SourcePath)) {
        Write-Build Yellow "Source path not found: $SourcePath"
        return
    }

    if (-not (Test-Path $SettingsFile)) {
        Write-Build Yellow "Settings file not found: $SettingsFile"
        return
    }

    Write-Build Cyan "Checking formatting of PowerShell files in: $SourcePath"

    $files = Get-ChildItem -Path $SourcePath -Recurse -Filter '*.ps1'
    $unformattedFiles = @()

    foreach ($file in $files) {
        $original = Get-Content -Path $file.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($original)) { continue }

        try {
            $formatted = Invoke-Formatter -ScriptDefinition $original -Settings $SettingsFile -ErrorAction Stop

            # Only flag as needing formatting if we got valid output and it differs
            if (-not [string]::IsNullOrWhiteSpace($formatted) -and $formatted -ne $original) {
                $unformattedFiles += $file.Name
                Write-Build Yellow "  Needs formatting: $($file.Name)"
            }
        }
        catch {
            Write-Build Yellow "  Skipped (format error): $($file.Name) - $($_.Exception.Message)"
        }
    }

    if ($unformattedFiles.Count -gt 0) {
        throw "Found $($unformattedFiles.Count) file(s) with formatting issues. Run '.\build.ps1 -Tasks format' to fix."
    }
    else {
        Write-Build Green "All files properly formatted"
    }
}

task Invoke_PSScriptAnalyzer {
    $SourcePath = Join-Path $BuildRoot 'source'
    $SettingsFile = Join-Path $BuildRoot 'PSScriptAnalyzerSettings.psd1'

    if (-not (Test-Path $SourcePath)) {
        Write-Build Yellow "Source path not found: $SourcePath"
        return
    }

    Write-Build Cyan "Running PSScriptAnalyzer on: $SourcePath"

    $AnalyzerParams = @{
        Path        = $SourcePath
        Recurse     = $true
        ErrorAction = 'SilentlyContinue'
    }

    if (Test-Path $SettingsFile) {
        Write-Build Cyan "Using settings file: $SettingsFile"
        $AnalyzerParams['Settings'] = $SettingsFile
    }

    $Results = Invoke-ScriptAnalyzer @AnalyzerParams

    if ($Results) {
        Write-Build Yellow "`nPSScriptAnalyzer found $($Results.Count) issue(s):`n"

        $Results | ForEach-Object {
            $Color = switch ($_.Severity) {
                'Error' { 'Red' }
                'Warning' { 'Yellow' }
                'Information' { 'Cyan' }
                default { 'White' }
            }
            Write-Build $Color "$($_.Severity): $($_.ScriptName):$($_.Line) - $($_.RuleName)"
            Write-Build White "  $($_.Message)"
        }

        $Errors = $Results | Where-Object { $_.Severity -eq 'Error' }
        if ($Errors) {
            throw "PSScriptAnalyzer found $($Errors.Count) error(s). Build failed."
        }

        Write-Build Yellow "`nPSScriptAnalyzer completed with warnings."
    }
    else {
        Write-Build Green "PSScriptAnalyzer: No issues found!"
    }
}

task Generate_Markdown_Help {
    $OutputPath = Join-Path $BuildRoot 'docs'
    $ModulePath = Get-ChildItem -Path "$BuildRoot/output/DNSFilterAPI/*/DNSFilterAPI.psd1" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $ModulePath) {
        Write-Build Yellow "Module not built yet. Run 'build' task first."
        return
    }

    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }

    # Import the built module
    Import-Module $ModulePath.FullName -Force

    # Generate or update markdown help
    $ExistingDocs = Get-ChildItem -Path $OutputPath -Filter '*.md' -ErrorAction SilentlyContinue

    if ($ExistingDocs) {
        Write-Build Cyan "Updating existing markdown help files..."
        Update-MarkdownHelp -Path $OutputPath -Force
    }
    else {
        Write-Build Cyan "Generating markdown help files..."
        New-MarkdownHelp -Module DNSFilterAPI -OutputFolder $OutputPath -Force -NoMetadata
    }

    Write-Build Green "Markdown help files generated in: $OutputPath"
}

task Generate_MAML_Help {
    $DocsPath = Join-Path $BuildRoot 'docs'
    $ModuleOutputPath = Get-ChildItem -Path "$BuildRoot/output/DNSFilterAPI/*" -Directory |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1

    if (-not $ModuleOutputPath) {
        Write-Build Yellow "Module not built yet. Run 'build' task first."
        return
    }

    if (-not (Test-Path $DocsPath)) {
        Write-Build Yellow "No markdown docs found. Run 'Generate_Markdown_Help' first."
        return
    }

    $MamlPath = Join-Path $ModuleOutputPath.FullName 'en-US'
    if (-not (Test-Path $MamlPath)) {
        New-Item -Path $MamlPath -ItemType Directory -Force | Out-Null
    }

    Write-Build Cyan "Generating MAML help from markdown..."
    New-ExternalHelp -Path $DocsPath -OutputPath $MamlPath -Force

    Write-Build Green "MAML help generated in: $MamlPath"
}
