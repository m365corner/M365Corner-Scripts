# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Scanning applications with a SINGLE owner..." -ForegroundColor Cyan

# Get all applications
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description

$Results = @()

foreach ($App in $Applications) {

    # Get application owners
    $Owners = Get-MgApplicationOwner -ApplicationId $App.Id

    if ($Owners.Count -eq 1) {

        Write-Host "$($App.DisplayName) | Owners: 1" -ForegroundColor Yellow

        $OwnerName = "N/A"
        $OwnerUPN  = "N/A"
        $OwnerId   = "N/A"

        foreach ($Owner in $Owners) {

            try {
                # This matches your working multiple owners logic
                $OwnerDetails = Get-MgUser -UserId $Owner.Id -ErrorAction Stop

                if ($OwnerDetails) {
                    $OwnerName = $OwnerDetails.DisplayName
                    $OwnerUPN  = $OwnerDetails.UserPrincipalName
                    $OwnerId   = $OwnerDetails.Id
                }
            }
            catch {
                # Fallback if not a user object
                if ($Owner.AdditionalProperties -and $Owner.AdditionalProperties.ContainsKey("displayName")) {
                    $OwnerName = $Owner.AdditionalProperties["displayName"]
                }

                if ($Owner.AdditionalProperties -and $Owner.AdditionalProperties.ContainsKey("id")) {
                    $OwnerId = $Owner.AdditionalProperties["id"]
                }

                $OwnerUPN = "Non-User Object"
            }
        }

        $Results += [PSCustomObject]@{
            ApplicationName = $App.DisplayName
            ApplicationId   = $App.Id
            ClientId        = $App.AppId
            CreatedDate     = $App.CreatedDateTime
            Description     = $App.Description
            OwnerCount      = 1
            OwnerName       = $OwnerName
            OwnerUPN        = $OwnerUPN
            OwnerId         = $OwnerId
        }
    }
}

# Export results
$ExportPath = "C:\Path\Applications_With_Single_Owner_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan