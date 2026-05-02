# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Fetching ALL Service Principals..." -ForegroundColor Cyan

# Get all service principals
$ServicePrincipals = Get-MgServicePrincipal -All -Property Id,DisplayName,AppId,CreatedDateTime,AccountEnabled,Tags,PublisherName

$Results = @()

foreach ($SP in $ServicePrincipals) {

    # Console output (basic)
    $Status = if ($SP.AccountEnabled) { "Enabled" } else { "Disabled" }

    Write-Host "$($SP.DisplayName) | $($SP.AppId) | $Status" -ForegroundColor Yellow

    # Export object (detailed)
    $Results += [PSCustomObject]@{
        DisplayName        = $SP.DisplayName
        ServicePrincipalId = $SP.Id
        AppId              = $SP.AppId
        AccountEnabled     = $SP.AccountEnabled
        Tags               = ($SP.Tags -join ", ")
    }
}

# Export results
$ExportPath = "D:\All_ServicePrincipals_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Full Service Principal inventory exported to $ExportPath" -ForegroundColor Cyan