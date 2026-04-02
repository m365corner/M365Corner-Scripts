
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning applications for high-risk API permissions..." -ForegroundColor Cyan

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

# Get all applications
$Applications = Get-MgApplication -All -Property Id,DisplayName,RequiredResourceAccess

$Results = @()

foreach ($App in $Applications) {

    $MatchedPermissions = @()

    foreach ($Resource in $App.RequiredResourceAccess) {

        foreach ($Access in $Resource.ResourceAccess) {

            # Resolve permission name
            $PermissionId = $Access.Id

            # Get permission details from service principal
            $ServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$($Resource.ResourceAppId)'" -Property AppRoles,Oauth2PermissionScopes

            $PermissionName = ($ServicePrincipal.AppRoles + $ServicePrincipal.Oauth2PermissionScopes | Where-Object {$_.Id -eq $PermissionId}).Value

            if ($HighRiskPermissions -contains $PermissionName) {

                $MatchedPermissions += $PermissionName
            }
        }
    }

    if ($MatchedPermissions.Count -gt 0) {

        Write-Host "$($App.DisplayName) contains high-risk API permissions" -ForegroundColor Red

        $Results += [PSCustomObject]@{
            ApplicationName      = $App.DisplayName
            ApplicationId        = $App.Id
            HighRiskPermissions  = ($MatchedPermissions -join ", ")
        }
    }
}

# Export report
$ExportPath = "D:\HighRisk_Application_Permissions_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
                                