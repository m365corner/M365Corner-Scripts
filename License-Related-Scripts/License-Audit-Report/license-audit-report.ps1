
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.Read.All, Organization.Read.All

Write-Host "Fetching tenant license information..." -ForegroundColor Cyan

# Get all subscribed SKUs
$SubscribedSkus = Get-MgSubscribedSku

# Create SKU lookup table (SkuId → SkuPartNumber)
$SkuLookup = @{}
foreach ($Sku in $SubscribedSkus) {
    $SkuLookup[$Sku.SkuId] = $Sku.SkuPartNumber
}

# License Summary Report
$LicenseSummary = foreach ($Sku in $SubscribedSkus) {
    [PSCustomObject]@{
        SkuPartNumber  = $Sku.SkuPartNumber
        SkuId          = $Sku.SkuId
        EnabledUnits   = $Sku.PrepaidUnits.Enabled
        ConsumedUnits  = $Sku.ConsumedUnits
        AvailableUnits = ($Sku.PrepaidUnits.Enabled - $Sku.ConsumedUnits)
    }
}

Write-Host "Fetching all users..." -ForegroundColor Cyan

# Get all users with assigned licenses
$Users = Get-MgUser -All -Property Id,UserPrincipalName,DisplayName,AssignedLicenses,AccountEnabled

$UserLicenseReport = @()
$UnlicensedUsers = @()

foreach ($User in $Users) {

    if (-not $User.AssignedLicenses) {

        $UnlicensedUsers += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            DisplayName       = $User.DisplayName
            AccountEnabled    = $User.AccountEnabled
        }

        continue
    }

    foreach ($AssignedLicense in $User.AssignedLicenses) {

        $UserLicenseReport += [PSCustomObject]@{
            UserPrincipalName = $User.UserPrincipalName
            DisplayName       = $User.DisplayName
            AccountEnabled    = $User.AccountEnabled
            SkuPartNumber     = $SkuLookup[$AssignedLicense.SkuId]
            SkuId             = $AssignedLicense.SkuId
        }
    }
}

# Export Reports
$BasePath = "C:\Path\"

$LicenseSummary | Export-Csv "$BasePath\TenantLicenseSummary.csv" -NoTypeInformation
$UserLicenseReport | Export-Csv "$BasePath\UserLicenseDetails.csv" -NoTypeInformation
$UnlicensedUsers | Export-Csv "$BasePath\UnlicensedUsers.csv" -NoTypeInformation

Write-Host "License audit reports exported successfully." -ForegroundColor Green
                            