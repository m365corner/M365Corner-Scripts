# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning for DISABLED Service Principals..." -ForegroundColor Cyan

# Get service principals
$ServicePrincipals = Get-MgServicePrincipal -All -Property Id,DisplayName,AppId,CreatedDateTime,AccountEnabled,Tags,PublisherName

$Results = @()

foreach ($SP in $ServicePrincipals) {

    if ($SP.AccountEnabled -eq $false) {

        # Console output (basic)
        Write-Host "$($SP.DisplayName) | $($SP.AppId) | $($SP.CreatedDateTime)" -ForegroundColor Yellow

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            DisplayName        = $SP.DisplayName
            ServicePrincipalId = $SP.Id
            AppId              = $SP.AppId
            CreatedDate        = $SP.CreatedDateTime
            AccountEnabled     = $SP.AccountEnabled
            PublisherName      = $SP.PublisherName
            Tags               = ($SP.Tags -join ", ")
            Status             = "Disabled"
        }
    }
}

# Export results
$ExportPath = "C:\Path\Disabled_ServicePrincipals_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Disabled Service Principals report exported to $ExportPath" -ForegroundColor Cyan