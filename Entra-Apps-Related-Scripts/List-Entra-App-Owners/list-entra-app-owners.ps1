# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Fetching Entra ID Applications..." -ForegroundColor Cyan

# Get all applications
$Applications = Get-MgApplication -All

$Results = @()

foreach ($App in $Applications) {

    # Get application owners
    $Owners = Get-MgApplicationOwner -ApplicationId $App.Id

    # Skip applications without owners
    if (-not $Owners) {
        continue
    }

    Write-Host "Processing Application: $($App.DisplayName)" -ForegroundColor Yellow

    foreach ($Owner in $Owners) {

        $OwnerDetails = Get-MgUser -UserId $Owner.Id -ErrorAction SilentlyContinue

        $OwnerName = $OwnerDetails.DisplayName
        $OwnerUPN  = $OwnerDetails.UserPrincipalName

        $Results += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationId   = $App.Id
            OwnerName       = $OwnerName
            OwnerUPN        = $OwnerUPN
        }

        Write-Host "$($App.DisplayName) → $OwnerName ($OwnerUPN)" -ForegroundColor Green
    }
}

# Export results
$ExportPath = "D:\EntraID_Applications_With_Owners.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan
                                