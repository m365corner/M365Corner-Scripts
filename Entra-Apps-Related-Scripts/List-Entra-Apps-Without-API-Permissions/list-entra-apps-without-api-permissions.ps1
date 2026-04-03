
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Fetching Entra ID Applications..." -ForegroundColor Cyan

# Get all applications with API permission property
$Applications = Get-MgApplication -All -Property Id,DisplayName,CreatedDateTime,Description,RequiredResourceAccess

$Results = @()

foreach ($App in $Applications) {

    # Check if API permissions exist
    if (-not $App.RequiredResourceAccess) {

        Write-Host "$($App.DisplayName) → No API permissions assigned" -ForegroundColor Yellow

        $Results += [PSCustomObject]@{
            ApplicationName  = $App.DisplayName
            ApplicationId    = $App.Id
            CreatedDate      = $App.CreatedDateTime
            Description      = $App.Description
            PermissionStatus = "No API Permissions Assigned"
        }
    }
}

# Export results
$ExportPath = "D:\Applications_Without_API_Permissions.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
                                