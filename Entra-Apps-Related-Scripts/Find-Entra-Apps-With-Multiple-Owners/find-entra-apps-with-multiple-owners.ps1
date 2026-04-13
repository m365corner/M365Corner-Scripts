# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Scanning applications with multiple owners..." -ForegroundColor Cyan

# Get all applications
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description

$Results = @()

foreach ($App in $Applications) {

    # Get application owners
    $Owners = Get-MgApplicationOwner -ApplicationId $App.Id

    if ($Owners.Count -gt 1) {

        # Console output (minimal + useful)
        Write-Host "$($App.DisplayName) | Owners: $($Owners.Count)" -ForegroundColor Yellow

        $OwnerList = @()

        foreach ($Owner in $Owners) {

            $OwnerDetails = Get-MgUser -UserId $Owner.Id -ErrorAction SilentlyContinue

            if ($OwnerDetails) {
                $OwnerList += "$($OwnerDetails.DisplayName) ($($OwnerDetails.UserPrincipalName))"
            }
        }

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationId   = $App.Id
            ClientId        = $App.AppId
            CreatedDate     = $App.CreatedDateTime
            Description     = $App.Description
            OwnerCount      = $Owners.Count
            Owners          = ($OwnerList -join "; ")
        }
    }
}

# Export results
$ExportPath = "D:\Applications_With_Multiple_Owners_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan