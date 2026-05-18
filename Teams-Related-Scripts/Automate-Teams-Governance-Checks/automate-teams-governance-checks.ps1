
# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"Group.Read.All",
"User.Read.All",
"Mail.Send"

# CSV export path
$CsvPath = "C:\Reports\TeamsGovernanceReport.csv"

# Email settings
$Sender = "admin@contoso.com"
$Recipient = "governance@contoso.com"

# Naming convention pattern
$NamingPattern = "^(HR|IT|FIN|OPS)-"

# Teams older than this will be checked
$MinimumTeamAgeDays = 30

# Get all Teams-enabled Microsoft 365 Groups
$Teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All

$GovernanceReport = @()

foreach ($Team in $Teams) {

    try {

        Write-Host "Processing Team: $($Team.DisplayName)" -ForegroundColor Cyan

        # Calculate Team age
        $TeamAgeDays = (
            New-TimeSpan `
            -Start $Team.CreatedDateTime `
            -End (Get-Date)
        ).Days

        # Skip newly created Teams
        if ($TeamAgeDays -lt $MinimumTeamAgeDays) {
            continue
        }

        # Get Owners
        $Owners = Get-MgGroupOwner -GroupId $Team.Id -All

        $OwnerNames = ($Owners | ForEach-Object {
            $_.AdditionalProperties.displayName
        }) -join ", "

        $OwnerCount = $Owners.Count

        # Governance checks
        $Issues = @()
        $Severity = "Low"
        $RecommendedAction = @()

        # Missing description
        if ([string]::IsNullOrWhiteSpace($Team.Description)) {

            $Issues += "Missing Description"
            $Severity = "Medium"

            $RecommendedAction += "Add a meaningful Team description"
        }

        # Default or weak descriptions
        if (
            $Team.Description -match "^(test|na|none|team description)$"
        ) {

            $Issues += "Weak Description"
            $Severity = "Medium"

            $RecommendedAction += "Replace placeholder description"
        }

        # Public Team without description
        if (
            $Team.Visibility -eq "Public" -and
            [string]::IsNullOrWhiteSpace($Team.Description)
        ) {

            $Issues += "Public Team Missing Description"
            $Severity = "High"

            $RecommendedAction += "Review public Team metadata immediately"
        }

        # No owners
        if ($OwnerCount -eq 0) {

            $Issues += "No Owners Assigned"
            $Severity = "Critical"

            $RecommendedAction += "Assign at least one Team owner"
        }

        # Naming convention validation
        if ($Team.DisplayName -notmatch $NamingPattern) {

            $Issues += "Naming Convention Violation"

            if ($Severity -ne "Critical") {
                $Severity = "Medium"
            }

            $RecommendedAction += "Rename Team to match naming standards"
        }

        # Only add non-compliant Teams
        if ($Issues.Count -gt 0) {

            # Governance score
            $GovernanceScore = 100

            $GovernanceScore -= ($Issues.Count * 20)

            if ($GovernanceScore -lt 0) {
                $GovernanceScore = 0
            }

            $GovernanceReport += [PSCustomObject]@{

                TeamName           = $Team.DisplayName
                Visibility         = $Team.Visibility
                CreatedDate        = $Team.CreatedDateTime
                TeamAgeInDays      = $TeamAgeDays
                Owners             = $OwnerNames
                OwnerCount         = $OwnerCount
                IssuesFound        = $Issues -join "; "
                Severity           = $Severity
                GovernanceScore    = $GovernanceScore
                RecommendedActions = $RecommendedAction -join "; "
            }
        }
    }

    catch {

        Write-Host "Error processing Team: $($Team.DisplayName)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Export governance report
$GovernanceReport | Export-Csv `
-Path $CsvPath `
-NoTypeInformation `
-Encoding UTF8

Write-Host "Governance report exported successfully." -ForegroundColor Green

# Governance statistics
$TotalIssues = $GovernanceReport.Count

$CriticalIssues = (
    $GovernanceReport |
    Where-Object {
        $_.Severity -eq "Critical"
    }
).Count

$HighIssues = (
    $GovernanceReport |
    Where-Object {
        $_.Severity -eq "High"
    }
).Count

# HTML preview
$HtmlPreview = (
    $GovernanceReport |
    Select-Object -First 10 |
    ConvertTo-Html -Fragment
)

# Email body
$EmailBody = @"
<html>
<body>

<h2>Microsoft Teams Governance Report</h2>

<p>The automated governance review has completed successfully.</p>

<ul>
<li>Total Non-Compliant Teams: $TotalIssues</li>
<li>Critical Issues: $CriticalIssues</li>
<li>High Severity Issues: $HighIssues</li>
</ul>

<p>Below is a preview of the first 10 non-compliant Teams:</p>

$HtmlPreview

</body>
</html>
"@

# Send email
$params = @{
    message = @{
        subject = "Microsoft Teams Governance Report"

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
                name          = "TeamsGovernanceReport.csv"
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

Write-Host "Governance report emailed successfully." -ForegroundColor Green
