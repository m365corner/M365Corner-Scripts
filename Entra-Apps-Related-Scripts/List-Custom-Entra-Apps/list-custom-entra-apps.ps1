
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning for custom (non-template) Entra ID applications..." -ForegroundColor Cyan

# Get applications with template property
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description,ApplicationTemplateId

$Results = @()

foreach ($App in $Applications) {

    # Identify non-template apps
    if (-not $App.ApplicationTemplateId) {

        # Console output (minimal)
        Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Yellow

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            ApplicationName       = $App.DisplayName
            ApplicationId         = $App.Id
            ClientId              = $App.AppId
            CreatedDate           = $App.CreatedDateTime
            Description           = $App.Description
            ApplicationTemplateId = "N/A"
            AppType               = "Custom (Non-Template)"
        }
    }
}

# Export results
$ExportPath = "C:\Path\Custom_Applications_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan