
Connect-MgGraph -Scopes AuditLog.Read.All, Application.Read.All

Write-Host "Fetching applications created by specific user..." -ForegroundColor Cyan

# Define target user
$TargetUser = "pradeepg@w4l0s.onmicrosoft.com"

# Define date range (optional - last 30 days)
$StartDate = (Get-Date).AddDays(-30)

# Fetch audit logs for application creation
$AuditLogs = Get-MgAuditLogDirectoryAudit -Filter "activityDisplayName eq 'Add application'" -All

$Results = @()

foreach ($Log in $AuditLogs) {

    # Check if initiated by target user
    $InitiatedBy = $Log.InitiatedBy.User.UserPrincipalName

    if ($InitiatedBy -eq $TargetUser -and $Log.ActivityDateTime -ge $StartDate) {

        # Extract application details
        $AppName = ($Log.TargetResources | Where-Object {$_.Type -eq "Application"}).DisplayName
        $AppId   = ($Log.TargetResources | Where-Object {$_.Type -eq "Application"}).Id

        # Console output (minimal)
        Write-Host "$AppName | $AppId | $($Log.ActivityDateTime)" -ForegroundColor Yellow

        $Results += [PSCustomObject]@{
            ApplicationName = $AppName
            ApplicationId   = $AppId
            CreatedBy       = $InitiatedBy
            CreatedDate     = $Log.ActivityDateTime
            Activity        = $Log.ActivityDisplayName
        }
    }
}

# Export results
$ExportPath = "D:\Apps_Created_By_User_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
                                