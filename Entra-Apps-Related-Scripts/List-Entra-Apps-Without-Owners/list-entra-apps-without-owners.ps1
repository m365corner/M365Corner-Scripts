
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Fetching Entra ID Applications..." -ForegroundColor Cyan

# Get all applications
$Applications = Get-MgApplication -All

$Results = @()

foreach ($App in $Applications) {

    Write-Host "Checking Application: $($App.DisplayName)" -ForegroundColor Yellow

    # Get application owners
    $Owners = Get-MgApplicationOwner -ApplicationId $App.Id

    # Process only applications without owners
    if (-not $Owners) {

        Write-Host "$($App.DisplayName) → No owners assigned" -ForegroundColor Red

        $Results += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationId   = $App.Id
            OwnerStatus     = "No Owner Assigned"
        }
    }
}

# Export results
$ExportPath = "C:\Path\EntraID_Applications_Without_Owners.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
                                