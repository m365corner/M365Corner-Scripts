# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Scanning DISABLED Service Principals with NO owners..." -ForegroundColor Cyan

# Get service principals
$ServicePrincipals = Get-MgServicePrincipal -All -Property Id,DisplayName,AppId,CreatedDateTime,AccountEnabled,Tags,PublisherName

$Results = @()

foreach ($SP in $ServicePrincipals) {

    # Step 1: Check if disabled
    if ($SP.AccountEnabled -ne $false) {
        continue
    }

    # Step 2: Get owners
    $Owners = Get-MgServicePrincipalOwner -ServicePrincipalId $SP.Id

    # Step 3: Check if no owners
    if (-not $Owners -or $Owners.Count -eq 0) {

        # Console output (minimal)
        Write-Host "$($SP.DisplayName) | $($SP.AppId)" -ForegroundColor Red

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            DisplayName        = $SP.DisplayName
            ServicePrincipalId = $SP.Id
            AppId              = $SP.AppId
            AccountEnabled     = $SP.AccountEnabled
            Tags               = ($SP.Tags -join ", ")
            OwnerStatus        = "No Owner Assigned"
            Status             = "Disabled"
            RiskLevel          = "Cleanup Candidate"
        }
    }
}

# Export results
$ExportPath = "D:\Disabled_SP_NoOwners_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan