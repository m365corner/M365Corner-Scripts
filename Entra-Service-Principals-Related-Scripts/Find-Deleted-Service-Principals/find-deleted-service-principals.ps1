
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Directory.Read.All, Application.Read.All

Write-Host "Fetching deleted Service Principals..." -ForegroundColor Cyan

# Get deleted service principals
$DeletedSPs = Get-MgDirectoryDeletedItemAsServicePrincipal -All `
    -Property Id,DisplayName,AppId,DeletedDateTime,AccountEnabled,PublisherName,Tags

$Results = @()

foreach ($SP in $DeletedSPs) {

    # Console output - basic info
    Write-Host "$($SP.DisplayName) | $($SP.AppId) | Deleted: $($SP.DeletedDateTime)" -ForegroundColor Yellow

    # CSV output - detailed info
    $Results += [PSCustomObject]@{
        DisplayName        = $SP.DisplayName
        ServicePrincipalId = $SP.Id
        AppId              = $SP.AppId
        DeletedDateTime    = $SP.DeletedDateTime
        AccountEnabled     = $SP.AccountEnabled
        PublisherName      = $SP.PublisherName
        Tags               = ($SP.Tags -join ", ")
        ObjectType         = "Deleted Service Principal"
    }
}

# Export report
$ExportPath = "C:\Path\Deleted_ServicePrincipals_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Deleted Service Principals report exported to $ExportPath" -ForegroundColor Cyan
