
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, AuditLog.Read.All

Write-Host "Scanning Service Principals with NO sign-in activity (last 30 days)..." -ForegroundColor Cyan

# Define timeframe
$Days = 30
$StartDate = (Get-Date).AddDays(-$Days)

# Get all service principals
$ServicePrincipals = Get-MgServicePrincipal -All -Property Id,DisplayName,AppId,Tags

# Get sign-in logs for timeframe
$SignIns = Get-MgAuditLogSignIn -Filter "createdDateTime ge $($StartDate.ToString('yyyy-MM-ddTHH:mm:ssZ'))" -All

# Extract SP AppIds that have activity
$ActiveSPs = $SignIns |
    Where-Object { $_.AppId } |
    Select-Object -ExpandProperty AppId -Unique

$Results = @()

foreach ($SP in $ServicePrincipals) {

    # Exclude Microsoft apps (optional but recommended)
    if (
        $SP.Tags -contains "WindowsAzureActiveDirectoryIntegratedApp" -or
        $SP.Tags -contains "MicrosoftApplication"
    ) {
        continue
    }

    # Check if SP has NO activity
    if ($ActiveSPs -notcontains $SP.AppId) {

        # Console output (minimal)
        Write-Host "$($SP.DisplayName) | $($SP.AppId)" -ForegroundColor Yellow

        # Export object
        $Results += [PSCustomObject]@{
            DisplayName        = $SP.DisplayName
            ServicePrincipalId = $SP.Id
            AppId              = $SP.AppId
            LastSignInStatus   = "No sign-in activity in last $Days days"
            RiskLevel          = "Review Required"
        }
    }
}

# Export results
$ExportPath = "C:\Path\SP_NoSignInActivity_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
