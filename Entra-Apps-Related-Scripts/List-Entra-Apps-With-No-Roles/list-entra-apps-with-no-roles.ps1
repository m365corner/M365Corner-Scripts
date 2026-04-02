
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning applications for missing app roles..." -ForegroundColor Cyan

# Get all applications with AppRoles property
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description,AppRoles

$Results = @()

    foreach ($App in $Applications) {
        # Check if AppRoles exist
        if (-not $App.AppRoles -or $App.AppRoles.Count -eq 0) {

            # Console output (minimal)
            Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Yellow

            # Export object (detailed)
                $Results += [PSCustomObject]@{
                    ApplicationName = $App.DisplayName
                    ApplicationId   = $App.Id
                    ClientId        = $App.AppId
                    CreatedDate     = $App.CreatedDateTime
                    Description     = $App.Description
                    AppRoleStatus   = "No App Roles Defined"
                }
            }
        }

# Export results
$ExportPath = "C:\Path\Applications_Without_AppRoles_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan