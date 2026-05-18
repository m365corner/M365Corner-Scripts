
# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"Group.Read.All",
"User.Read.All",
"Directory.Read.All",
"Mail.Send"

# CSV Export Path
$CsvPath = "C:\Reports\TeamsOwnershipGovernanceReport.csv"

# Email Settings
$Sender = "admin@contoso.com"
$Recipient = "governance@contoso.com"

# Get all Teams-enabled Microsoft 365 Groups
$Teams = Get-MgGroup `
-Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" `
-All

$OwnershipReport = @()

foreach ($Team in $Teams) {

    try {

        Write-Host "Processing Team: $($Team.DisplayName)" -ForegroundColor Cyan

        # Get Owners
        $Owners = Get-MgGroupOwner `
        -GroupId $Team.Id `
        -All

        $OwnerCount = $Owners.Count

        # Owner Names
        $OwnerNames = (
            $Owners | ForEach-Object {
                $_.AdditionalProperties.displayName
            }
        ) -join ", "

        # Detect Guest Owners
        $GuestOwners = (
            $Owners | Where-Object {
                $_.AdditionalProperties.userType -eq "Guest"
            }
        )

        $GuestOwnerCount = $GuestOwners.Count

        $GuestOwnerNames = (
            $GuestOwners | ForEach-Object {
                $_.AdditionalProperties.displayName
            }
        ) -join ", "

        # Governance evaluation
        $Issues = @()
        $Severity = "Low"
        $RecommendedActions = @()

        # No owners
        if ($OwnerCount -eq 0) {

            $Issues += "No Owners Assigned"
            $Severity = "Critical"

            $RecommendedActions += "Assign at least two Team owners immediately"
        }

        # Single owner
        elseif ($OwnerCount -eq 1) {

            $Issues += "Single Owner Team"

            if ($Severity -ne "Critical") {
                $Severity = "Medium"
            }

            $RecommendedActions += "Add a backup Team owner"
        }

        # Excessive owners
        if ($OwnerCount -gt 5) {

            $Issues += "Excessive Owners"

            if ($Severity -ne "Critical") {
                $Severity = "Medium"
            }

            $RecommendedActions += "Review and reduce unnecessary owners"
        }

        # Guest owners
        if ($GuestOwnerCount -gt 0) {

            $Issues += "Guest Owners Detected"

            if ($Severity -ne "Critical") {
                $Severity = "High"
            }

            $RecommendedActions += "Review external ownership assignments"
        }

        # Public Team with weak ownership
        if (
            $Team.Visibility -eq "Public" -and
            $OwnerCount -le 1
        ) {

            $Issues += "Public Team with Weak Ownership"

            $Severity = "High"

            $RecommendedActions += "Strengthen ownership governance for public Team"
        }

        # Ownership Health Score
        $OwnershipHealthScore = 100

        $OwnershipHealthScore -= ($Issues.Count * 20)

        if ($OwnershipHealthScore -lt 0) {
            $OwnershipHealthScore = 0
        }

        # Add only Teams with governance findings
        if ($Issues.Count -gt 0) {

            $OwnershipReport += [PSCustomObject]@{

                TeamName              = $Team.DisplayName
                Visibility            = $Team.Visibility
                CreatedDate           = $Team.CreatedDateTime
                OwnerCount            = $OwnerCount
                Owners                = $OwnerNames
                GuestOwnerCount       = $GuestOwnerCount
                GuestOwners           = $GuestOwnerNames
                IssuesFound           = $Issues -join "; "
                Severity              = $Severity
                OwnershipHealthScore  = $OwnershipHealthScore
                RecommendedActions    = $RecommendedActions -join "; "
            }
        }
    }

    catch {

        Write-Host "Error processing Team: $($Team.DisplayName)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Export report
$OwnershipReport | Export-Csv `
-Path $CsvPath `
-NoTypeInformation `
-Encoding UTF8

Write-Host "Ownership governance report exported successfully." -ForegroundColor Green

# Governance statistics
$TotalIssues = $OwnershipReport.Count

$CriticalIssues = (
    $OwnershipReport |
    Where-Object {
        $_.Severity -eq "Critical"
    }
).Count

$HighIssues = (
    $OwnershipReport |
    Where-Object {
        $_.Severity -eq "High"
    }
).Count

$SingleOwnerTeams = (
    $OwnershipReport |
    Where-Object {
        $_.IssuesFound -match "Single Owner Team"
    }
).Count

# HTML preview
$HtmlPreview = (
    $OwnershipReport |
    Select-Object -First 10 |
    ConvertTo-Html -Fragment
)

# Email body
$EmailBody = @"
<html>
<body>

<h2>Microsoft Teams Ownership Governance Report</h2>

<p>The automated ownership governance review has completed successfully.</p>

<ul>
<li>Total Teams with Governance Issues: $TotalIssues</li>
<li>Critical Ownership Issues: $CriticalIssues</li>
<li>High Severity Issues: $HighIssues</li>
<li>Single Owner Teams: $SingleOwnerTeams</li>
</ul>

<p>Below is a preview of the first 10 Teams with ownership governance findings:</p>

$HtmlPreview

</body>
</html>
"@

# Send email
$params = @{
    message = @{
        subject = "Microsoft Teams Ownership Governance Report"

        body = @{
            contentType = "HTML"
            content = $EmailBody
        }

        toRecipients = @(
            @{
                emailAddress = @{
                    address = $Recipient
                }
            }
        )

        attachments = @(
            @{
                "@odata.type" = "#microsoft.graph.fileAttachment"
                name          = "TeamsOwnershipGovernanceReport.csv"
                contentBytes  = [System.Convert]::ToBase64String(
                    [System.IO.File]::ReadAllBytes($CsvPath)
                )
            }
        )
    }

    saveToSentItems = "true"
}

Send-MgUserMail `
-UserId $Sender `
-BodyParameter $params

Write-Host "Ownership governance report emailed successfully." -ForegroundColor Green
