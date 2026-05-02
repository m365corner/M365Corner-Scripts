# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Scanning Service Principals with NO owners..." -ForegroundColor Cyan

# Get all service principals
$ServicePrincipals = Get-MgServicePrincipal -All -Property Id,DisplayName,AppId,CreatedDateTime,AccountEnabled,Tags

$Results = @()

foreach ($SP in $ServicePrincipals) {

    # Get owners
    $Owners = Get-MgServicePrincipalOwner -ServicePrincipalId $SP.Id

    if (-not $Owners -or $Owners.Count -eq 0) {

        # Console output (minimal)
        Write-Host "$($SP.DisplayName) | $($SP.AppId)" -ForegroundColor Red

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            DisplayName        = $SP.DisplayName
            ServicePrincipalId = $SP.Id
            AppId              = $SP.AppId
            CreatedDate        = $SP.CreatedDateTime
            AccountEnabled     = $SP.AccountEnabled
            Tags               = ($SP.Tags -join ", ")
            OwnerStatus        = "No Owner Assigned"
        }
    }
}

# Export results
$ExportPath = "D:\SP_No_Owners_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan


