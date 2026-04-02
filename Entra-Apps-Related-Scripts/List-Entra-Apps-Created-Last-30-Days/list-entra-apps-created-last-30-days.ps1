
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Fetching recently created Entra ID applications (Last 30 Days)..." -ForegroundColor Cyan

# Define date threshold (last 30 days)
$ThresholdDate = (Get-Date).AddDays(-30)

# Get all applications with required properties
$Applications = Get-MgApplication -All -Property Id,DisplayName,CreatedDateTime,Description,AppId

$Results = @()

foreach ($App in $Applications) {

    if ($App.CreatedDateTime -ge $ThresholdDate) {

        # Console output (minimal)
        Write-Host "$($App.DisplayName) | $($App.AppId) | $($App.CreatedDateTime)" -ForegroundColor Yellow

        # Detailed export object
        $Results += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationId   = $App.Id
            AppClientId     = $App.AppId
            CreatedDate     = $App.CreatedDateTime
            Description     = $App.Description
        }
    }
}

# Export results
$ExportPath = "C:\Path\Recently_Created_Applications_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
                                