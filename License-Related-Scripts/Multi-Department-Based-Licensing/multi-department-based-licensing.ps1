
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

# Define Department-License Mapping (Demo)
$DepartmentLicenseMap = @{
    "HR_Fabricam"    = "f30db892-07e9-47e9-837c-80727f46fd3d"      # FLOW_FREE
    "Sales_Fabricam" = "c42b9cae-ea4f-4ab7-9717-81576235ccac"      # DEVELOPERPACK_E5
    "IT_Fabricam"    = "5b631642-bd26-49fe-bd20-1daaa972ef80"      # POWERAPPS_DEV
}

# Get all users in the 3 departments
$Users = Get-MgUser -Filter "department eq 'HR_Fabricam' or department eq 'Sales_Fabricam' or department eq 'IT_Fabricam'" -All -Property Id,UserPrincipalName,Department,AssignedLicenses

if (-not $Users) {
    Write-Host "No users found in target departments." -ForegroundColor Yellow
    break
}

$Results = @()

foreach ($User in $Users) {

    try {

        $TargetSkuId = $DepartmentLicenseMap[$User.Department]

        if (-not $TargetSkuId) {
            continue
        }

        # Validate SKU exists
        $Sku = Get-MgSubscribedSku | Where-Object {$_.SkuId -eq $TargetSkuId}
        if (-not $Sku) {
            Write-Host "SKU not found for department $($User.Department)" -ForegroundColor Red
            continue
        }

        # Check availability
        $AvailableLicenses = $Sku.PrepaidUnits.Enabled - $Sku.ConsumedUnits
        if ($AvailableLicenses -le 0) {
            Write-Host "No available licenses for $($User.Department)" -ForegroundColor Red
            continue
        }

        # Skip if already licensed
        if ($User.AssignedLicenses.SkuId -contains $TargetSkuId) {

            Write-Host "$($User.UserPrincipalName) already licensed. Skipping." -ForegroundColor Yellow

            $Results += [PSCustomObject]@{
                UserPrincipalName = $User.UserPrincipalName
                Department        = $User.Department
                Status            = "Skipped - Already Licensed"
                Timestamp         = (Get-Date)
            }

            continue
        }

        # Assign license
        Set-MgUserLicense -UserId $User.Id `
            -AddLicenses @(
                @{
                    SkuId = $TargetSkuId
                }
            ) `
            -RemoveLicenses @()

        Write-Host "License assigned to $($User.UserPrincipalName)" -ForegroundColor Green

        $Results += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            Department        = $User.Department
            Status            = "Success"
            Timestamp         = (Get-Date)
        }

    }
    catch {

        Write-Host "Failed for $($User.UserPrincipalName)" -ForegroundColor Red
        Write-Host $_.Exception.Message

        $Results += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            Department        = $User.Department
            Status            = "Failed"
            ErrorMessage      = $_.Exception.Message
            Timestamp         = (Get-Date)
        }
    }
}

# Export Report
$ReportPath = "C:\Path\MultiDept-LicenseReport.csv"
$Results | Export-Csv $ReportPath -NoTypeInformation

Write-Host "Report exported to $ReportPath" -ForegroundColor Cyan
                                