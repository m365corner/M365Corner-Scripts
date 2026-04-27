
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

# Define License SKU ID (DEVELOPERPACK_E5)
$SkuId = "c42b9cae-ea4f-4ab7-9717-81576235ccac"

# Import CSV
$Users = Import-Csv "C:\Path\UsersToRemoveLicense.csv"

# Prepare result tracking array
$Results = @()

foreach ($User in $Users) {

    try {
        Write-Host "Processing $($User.UserPrincipalName)..." -ForegroundColor Cyan

        # Get user license details
        $UserDetails = Get-MgUser -UserId $User.UserPrincipalName -Property AssignedLicenses

        if ($UserDetails.AssignedLicenses.SkuId -notcontains $SkuId) {

            Write-Host "License not assigned. Skipping." -ForegroundColor Yellow

            $Results += [PSCustomObject]@{
                UserPrincipalName = $User.UserPrincipalName
                Status            = "Skipped - License Not Assigned"
                Timestamp         = (Get-Date)
            }

            continue
        }

        # Remove license
        Set-MgUserLicense -UserId $User.UserPrincipalName `
            -AddLicenses @() `
            -RemoveLicenses @($SkuId)

        Write-Host "License removed successfully." -ForegroundColor Green

        $Results += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            Status            = "Success"
            Timestamp         = (Get-Date)
        }

    }
    catch {

        Write-Host "Failed to remove license." -ForegroundColor Red
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
$ReportPath = "C:\Path\BulkLicenseRemovalReport.csv"
$Results | Export-Csv $ReportPath -NoTypeInformation

Write-Host "Report exported to $ReportPath" -ForegroundColor Cyan
                                