
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning Service Principals with HIGH-RISK permissions..." -ForegroundColor Cyan

# Define high-risk permissions
$HighRiskPermissions = @(
    "Directory.ReadWrite.All",
    "User.ReadWrite.All",
    "Application.ReadWrite.All",
    "RoleManagement.ReadWrite.Directory",
    "Group.ReadWrite.All",
    "AppRoleAssignment.ReadWrite.All",
    "Directory.Read.All",
    "User.Read.All",
    "Group.Read.All"
)

# Get all service principals
$ServicePrincipals = Get-MgServicePrincipal -All -Property Id,DisplayName,AppId

$Results = @()

foreach ($SP in $ServicePrincipals) {

    # Get assigned app role permissions
    $Assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $SP.Id -All -ErrorAction SilentlyContinue

    $MatchedPermissions = @()

    foreach ($Assignment in $Assignments) {

        # Resolve resource service principal
        $ResourceSP = Get-MgServicePrincipal -ServicePrincipalId $Assignment.ResourceId -Property AppRoles

        # Match AppRoleId to actual permission name
        $Role = $ResourceSP.AppRoles | Where-Object { $_.Id -eq $Assignment.AppRoleId }

        if ($Role -and $HighRiskPermissions -contains $Role.Value) {
            $MatchedPermissions += $Role.Value
        }
    }

    if ($MatchedPermissions.Count -gt 0) {

        # Console output (minimal)
        Write-Host "$($SP.DisplayName) | $($SP.AppId)" -ForegroundColor Red

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            DisplayName         = $SP.DisplayName
            ServicePrincipalId  = $SP.Id
            AppId               = $SP.AppId
            HighRiskPermissions = ($MatchedPermissions -join ", ")
            RiskLevel           = "High"
        }
    }
}

# Export results
$ExportPath = "C:\SP_HighRiskPermissions_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
