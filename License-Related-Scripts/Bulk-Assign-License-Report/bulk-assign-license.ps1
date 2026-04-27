
# Connect to Microsoft Graph
Connect-MgGraph -Scopes User.ReadWrite.All, Organization.Read.All

# Define License SKU ID (DEVELOPERPACK_E5)
$SkuId = "c42b9cae-ea4f-4ab7-9717-81576235ccac"

# Import CSV
$Users = Import-Csv "C:\Path\UsersToLicense.csv"

foreach ($User in $Users) {

    try {
        Write-Host "Assigning license to $($User.UserPrincipalName)..." -ForegroundColor Cyan

        Set-MgUserLicense -UserId $User.UserPrincipalName `
            -AddLicenses @(
                @{
                    SkuId = $SkuId
                }
            ) `
            -RemoveLicenses @()

        Write-Host "Successfully assigned license to $($User.UserPrincipalName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to assign license to $($User.UserPrincipalName)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}
                                