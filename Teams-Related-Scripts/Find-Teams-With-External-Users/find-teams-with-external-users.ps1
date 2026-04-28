Connect-MgGraph -Scopes "Directory.Read.All"

# Output file
$OutputFile = "D:/Teams_With_Guests_Report.csv"

Write-Host "Fetching Teams..." -ForegroundColor Cyan

# Get all Teams
$Teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All

$Results = @()

foreach ($Team in $Teams) {
    Write-Host "Checking Team: $($Team.DisplayName)" -ForegroundColor Yellow

    # Get only user members and explicitly request needed properties
    $Members = Get-MgGroupMemberAsUser -GroupId $Team.Id -All -Property "id,displayName,userPrincipalName,mail,userType"

    # Filter guest users
    $GuestUsers = $Members | Where-Object { $_.UserType -eq "Guest" }

    if ($GuestUsers.Count -gt 0) {
        Write-Host "Team: $($Team.DisplayName) | Guest Count: $($GuestUsers.Count)" -ForegroundColor Red

        foreach ($Guest in $GuestUsers) {
            $Results += [PSCustomObject]@{
                TeamName    = $Team.DisplayName
                TeamId      = $Team.Id
                GuestName   = $Guest.DisplayName
                GuestUPN    = $Guest.UserPrincipalName
                GuestEmail  = $Guest.Mail
                GuestType   = $Guest.UserType
                GuestId     = $Guest.Id
            }
        }
    }
}

# Export results
if ($Results.Count -gt 0) {
    $Results | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8
    Write-Host "`nReport exported to: $OutputFile" -ForegroundColor Green
} else {
    Write-Host "No Teams with guest users found." -ForegroundColor Green
}