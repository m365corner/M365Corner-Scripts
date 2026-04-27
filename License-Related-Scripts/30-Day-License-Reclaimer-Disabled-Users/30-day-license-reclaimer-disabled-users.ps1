
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All, AuditLog.Read.All

Write-Host "Fetching disabled users..." -ForegroundColor Cyan

# Define threshold
$ThresholdDate = (Get-Date).AddDays(-30)

# Fetch disabled users with sign-in activity
$DisabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All `
    -Property Id,UserPrincipalName,AssignedLicenses,SignInActivity

if (-not $DisabledUsers) {
    Write-Host "No disabled users found." -ForegroundColor Yellow
    break
}

$Results = @()

foreach ($User in $DisabledUsers) {

    try {

        # Determine last sign-in
        $LastSignIn = $User.SignInActivity.LastSignInDateTime

        if (-not $LastSignIn) {
            # If no sign-in activity exists, treat as eligible
            $EligibleForReclaim = $true
        }
        else {
            $EligibleForReclaim = ([datetime]$LastSignIn -lt $ThresholdDate)
        }

        if (-not $EligibleForReclaim) {

            Write-Host "$($User.UserPrincipalName) disabled less than 30 days. Skipping." -ForegroundColor Yellow

            $Results += [PSCustomObject]@{
                UserPrincipalName = $User.UserPrincipalName
                Status            = "Skipped - Disabled < 30 Days"
                Timestamp         = (Get-Date)
            }

            continue
        }

        # Get assigned licenses
        $AssignedSkuIds = $User.AssignedLicenses.SkuId

        if (-not $AssignedSkuIds) {

            Write-Host "$($User.UserPrincipalName) has no licenses. Skipping." -ForegroundColor Yellow

            $Results += [PSCustomObject]@{
                UserPrincipalName = $User.UserPrincipalName
                Status            = "Skipped - No Licenses"
                Timestamp         = (Get-Date)
            }

            continue
        }

        # Remove all assigned licenses
        Set-MgUserLicense -UserId $User.Id `
            -AddLicenses @() `
            -RemoveLicenses $AssignedSkuIds

        Write-Host "Licenses reclaimed from $($User.UserPrincipalName)" -ForegroundColor Green

        $Results += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            LicensesRemoved   = ($AssignedSkuIds -join ", ")
            Status            = "Success"
            Timestamp         = (Get-Date)
        }

    }
    catch {

        Write-Host "Failed for $($User.UserPrincipalName)" -ForegroundColor Red
        Write-Host $_.Exception.Message

        $Results += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            Status            = "Failed"
            ErrorMessage      = $_.Exception.Message
            Timestamp         = (Get-Date)
        }
    }
}

# Export Report
$ReportPath = "C:\Path\30DayDisabledLicenseReclaimReport.csv"
$Results | Export-Csv $ReportPath -NoTypeInformation

Write-Host "Report exported to $ReportPath" -ForegroundColor Cyan
                                