
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning applications for disabled app roles..." -ForegroundColor Cyan

# Get applications with AppRoles
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description,AppRoles

$Results = @()

foreach ($App in $Applications) {

     if (-not $App.AppRoles) {
        continue
     }

    $DisabledRoles = $App.AppRoles | Where-Object { $_.IsEnabled -eq $false }

    if ($DisabledRoles.Count -gt 0) {

        # Console output (minimal)
        Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Yellow

        foreach ($Role in $DisabledRoles) {

            $Results += [PSCustomObject]@{
                ApplicationName = $App.DisplayName
                ApplicationId   = $App.Id
                ClientId        = $App.AppId
                CreatedDate     = $App.CreatedDateTime
                Description     = $App.Description
                RoleDisplayName = $Role.DisplayName
                RoleValue       = $Role.Value
                RoleId          = $Role.Id
                RoleStatus      = "Disabled"
        }
    }
    }
 }

# Export results
$ExportPath = "C:\Path\Applications_Disabled_AppRoles_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan