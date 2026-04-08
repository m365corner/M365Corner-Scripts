
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning custom applications with high-risk permissions..." -ForegroundColor Cyan

# Define high-risk permissions
$HighRiskPermissions = @(
"Directory.ReadWrite.All",
"User.ReadWrite.All",
"Application.ReadWrite.All",
"RoleManagement.ReadWrite.Directory",
"Group.ReadWrite.All",
"Mail.ReadWrite",
"Files.ReadWrite.All"
)

# Get applications
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description,ApplicationTemplateId,RequiredResourceAccess

$Results = @()

foreach ($App in $Applications) {

    # Only process custom (non-template) apps
    if ($App.ApplicationTemplateId) {
        continue
    }

    $MatchedPermissions = @()

    foreach ($Resource in $App.RequiredResourceAccess) {

        foreach ($Access in $Resource.ResourceAccess) {

            $PermissionId = $Access.Id

            # Resolve permission name
            $ServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$($Resource.ResourceAppId)'" -Property AppRoles,Oauth2PermissionScopes

            $PermissionName = ($ServicePrincipal.AppRoles + $ServicePrincipal.Oauth2PermissionScopes | Where-Object {$_.Id -eq $PermissionId}).Value

            if ($HighRiskPermissions -contains $PermissionName) {
                $MatchedPermissions += $PermissionName
            }
        }
    }

    if ($MatchedPermissions.Count -gt 0) {

        # Console output (minimal)
        Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Red

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            ApplicationName     = $App.DisplayName
            ApplicationId       = $App.Id
            ClientId            = $App.AppId
            CreatedDate         = $App.CreatedDateTime
            Description         = $App.Description
            AppType             = "Custom (Non-Template)"
            HighRiskPermissions = ($MatchedPermissions -join ", ")
            RiskLevel           = "High"
        }
    }
}

# Export results
$ExportPath = "D:\CustomApps_HighRiskPermissions_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan