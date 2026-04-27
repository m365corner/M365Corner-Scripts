
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

Write-Host "Fetching disabled users..." -ForegroundColor Cyan

# Get all disabled users with assigned licenses
$DisabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All -Property Id,UserPrincipalName,AssignedLicenses

if (-not $DisabledUsers) {
    Write-Host "No disabled users found." -ForegroundColor Yellow
    break
}

$Results = @()

foreach ($User in $DisabledUsers) {

    try {

        # Get assigned license SKUs
        $AssignedSkuIds = $User.AssignedLicenses.SkuId

        if (-not $AssignedSkuIds) {

            Write-Host "$($User.UserPrincipalName) has no assigned licenses. Skipping." -ForegroundColor Yellow

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
$ReportPath = "C:\Path\DisabledUserLicenseReclaimReport.csv"
$Results | Export-Csv $ReportPath -NoTypeInformation

Write-Host "Report exported to $ReportPath" -ForegroundColor Cyan
                                