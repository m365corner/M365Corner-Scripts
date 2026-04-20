# Output file
$OutputFile = "D:/Teams_Owner_Member_Report.csv"

# Get all Teams (Unified Groups with Teams)
Write-Host "Fetching Teams..." -ForegroundColor Cyan
$Teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All

$Results = @()

foreach ($Team in $Teams) {

    Write-Host "Processing Team: $($Team.DisplayName)" -ForegroundColor Yellow

    # Get Owners
    $Owners = Get-MgGroupOwner -GroupId $Team.Id -All
    $OwnerCount = ($Owners | Measure-Object).Count

    # Get Members
    $Members = Get-MgGroupMember -GroupId $Team.Id -All
    $MemberCount = ($Members | Measure-Object).Count

    # Owner names (optional but useful)
    $OwnerNames = ($Owners | Where-Object { $_.AdditionalProperties.displayName } | 
        ForEach-Object { $_.AdditionalProperties.displayName }) -join ", "

    # Store result
    $Results += [PSCustomObject]@{
        TeamName     = $Team.DisplayName
        TeamId       = $Team.Id
        OwnerCount   = $OwnerCount
        MemberCount  = $MemberCount
        Owners       = $OwnerNames
    }

    # Console Output (basic view)
    Write-Host "Team: $($Team.DisplayName) | Owners: $OwnerCount | Members: $MemberCount"
}

# Export to CSV (detailed)
$Results | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "`nReport exported to: $OutputFile" -ForegroundColor Green