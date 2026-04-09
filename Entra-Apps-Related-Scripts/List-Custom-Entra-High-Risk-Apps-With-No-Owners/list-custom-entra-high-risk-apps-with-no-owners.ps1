# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Scanning HIGH-RISK custom apps with NO owners..." -ForegroundColor Cyan

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

    # -------------------------
    # Step 1: Only Custom Apps
    # -------------------------
    if ($App.ApplicationTemplateId) {
        continue
    }

    # -------------------------
    # Step 2: Check Owners
    # -------------------------
    $Owners = Get-MgApplicationOwner -ApplicationId $App.Id

    if ($Owners) {
        continue
    }

    # -------------------------
    # Step 3: Check Permissions
    # -------------------------
    $MatchedPermissions = @()

    foreach ($Resource in $App.RequiredResourceAccess) {

        foreach ($Access in $Resource.ResourceAccess) {

            $PermissionId = $Access.Id

            $ServicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$($Resource.ResourceAppId)'" -Property AppRoles,Oauth2PermissionScopes

            $PermissionName = ($ServicePrincipal.AppRoles + $ServicePrincipal.Oauth2PermissionScopes | Where-Object {$_.Id -eq $PermissionId}).Value

            if ($HighRiskPermissions -contains $PermissionName) {
                $MatchedPermissions += $PermissionName
            }
        }
    }

    if ($MatchedPermissions.Count -gt 0) {

        # -------------------------
        # Console Output (Minimal)
        # -------------------------
        Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Red

        # -------------------------
        # Export Object (Detailed)
        # -------------------------
        $Results += [PSCustomObject]@{
            ApplicationName      = $App.DisplayName
            ApplicationId        = $App.Id
            ClientId             = $App.AppId
            CreatedDate          = $App.CreatedDateTime
            Description          = $App.Description
            AppType              = "Custom (Non-Template)"
            OwnerStatus          = "No Owner Assigned"
            HighRiskPermissions  = ($MatchedPermissions -join ", ")
            RiskLevel            = "Critical"
        }
    }
}

# Export results
$ExportPath = "C:\Path\CustomApps_HighRisk_NoOwners_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Critical risk report exported to $ExportPath" -ForegroundColor Cyan