
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

# Define Variables
$DepartmentName = "Sales-Rajkot"
$SkuId = "c42b9cae-ea4f-4ab7-9717-81576235ccac"

# Get SKU details
$Sku = Get-MgSubscribedSku | Where-Object {$_.SkuId -eq $SkuId}

if (-not $Sku) {
    Write-Host "Specified SKU not found in tenant." -ForegroundColor Red
    break
}

# Check license availability
$AvailableLicenses = $Sku.PrepaidUnits.Enabled - $Sku.ConsumedUnits

if ($AvailableLicenses -le 0) {
    Write-Host "No available licenses to assign." -ForegroundColor Red
    break
}

Write-Host "Available Licenses: $AvailableLicenses" -ForegroundColor Cyan

# Fetch users from department
$Users = Get-MgUser -Filter "department eq '$DepartmentName'" -All -Property Id,UserPrincipalName,AssignedLicenses

if (-not $Users) {
    Write-Host "No users found in department: $DepartmentName" -ForegroundColor Yellow
    break
}

# Prepare reporting array
$Results = @()

foreach ($User in $Users) {

    try {

        # Skip if already licensed
        if ($User.AssignedLicenses.SkuId -contains $SkuId) {

            Write-Host "$($User.UserPrincipalName) already licensed. Skipping." -ForegroundColor Yellow

            $Results += [PSCustomObject]@{
                UserPrincipalName = $User.UserPrincipalName
                Status            = "Skipped - Already Licensed"
                Timestamp         = (Get-Date)
            }

            continue
        }

        # Re-check license availability
        if ($AvailableLicenses -le 0) {
            Write-Host "No remaining licenses available. Stopping process." -ForegroundColor Red
            break
        }

        # Assign license
        Set-MgUserLicense -UserId $User.Id `
            -AddLicenses @(
                @{
                    SkuId = $SkuId
                }
            ) `
            -RemoveLicenses @()

        Write-Host "License assigned to $($User.UserPrincipalName)" -ForegroundColor Green

        $AvailableLicenses--

        $Results += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            Status            = "Success"
            Timestamp         = (Get-Date)
        }

    }
    catch {

        Write-Host "Failed to assign license to $($User.UserPrincipalName)" -ForegroundColor Red
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
$ReportPath = "C:\Path\Sales-Rajkot-LicenseReport.csv"
$Results | Export-Csv $ReportPath -NoTypeInformation

Write-Host "Report exported to $ReportPath" -ForegroundColor Cyan
                                