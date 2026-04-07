
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning for template-based Entra ID applications..." -ForegroundColor Cyan

# Get applications with template property
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description,ApplicationTemplateId

$Results = @()

foreach ($App in $Applications) {

    # Check if application is template-based
    if ($App.ApplicationTemplateId) {

        # Console output (minimal)
        Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Yellow

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            ApplicationName       = $App.DisplayName
            ApplicationId         = $App.Id
            ClientId              = $App.AppId
            CreatedDate           = $App.CreatedDateTime
            Description           = $App.Description
            ApplicationTemplateId = $App.ApplicationTemplateId
            AppType               = "Template-Based"
        }
    }
}

# Export results
$ExportPath = "D:\Template_Based_Applications_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan