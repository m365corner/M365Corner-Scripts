<# 
.SYNOPSIS
    Fetches all licensed guest user accounts in the tenant
    and exports the report to CSV.

.DESCRIPTION
    This script retrieves guest users from Microsoft Entra ID
    and filters only those who have assigned licenses.

.REQUIREMENTS
    Microsoft.Graph module
    Directory.Read.All permission
#>

# -------------------------------
# Step 1: Connect to Microsoft Graph
# -------------------------------
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All"

Write-Host "`nFetching licensed guest users..." -ForegroundColor Cyan

# -------------------------------
# Step 2: Fetch All Guest Users
# -------------------------------
$GuestUsers = Get-MgUser -All `
    -Filter "userType eq 'Guest'" `
    -Property Id,DisplayName,UserPrincipalName,AssignedLicenses

# -------------------------------
# Step 3: Filter Only Licensed Guests
# -------------------------------
$LicensedGuests = $GuestUsers |
    Where-Object { $_.AssignedLicenses.Count -gt 0 }

# -------------------------------
# Step 4: Prepare Report Output
# -------------------------------
$Report = $LicensedGuests | Select-Object `
    DisplayName,
    UserPrincipalName,
    @{Name="LicenseCount"; Expression={$_.AssignedLicenses.Count}}

# -------------------------------
# Step 5: Display Results in Console
# -------------------------------
Write-Host "`nLicensed Guest Accounts Found: $($Report.Count)" -ForegroundColor Yellow

$Report | Format-Table -AutoSize

# -------------------------------
# Step 6: Export Report to CSV
# -------------------------------
$ExportPath = "$PSScriptRoot\LicensedGuestUsersReport.csv"

$Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

Write-Host "`nReport exported successfully to:" -ForegroundColor Green
Write-Host $ExportPath -ForegroundColor White
                            