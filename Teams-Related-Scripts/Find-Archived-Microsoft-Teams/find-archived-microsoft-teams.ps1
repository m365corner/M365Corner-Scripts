
# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"Group.Read.All",
"User.Read.All",
"Mail.Send"

# Output CSV path
$CsvPath = "C:\Reports\ArchivedTeamsReport.csv"

# Email settings
$Sender = "admin@contoso.com"
$Recipient = "securityteam@contoso.com"

# Get all Microsoft Teams-enabled groups
$Teams = Get-MgGroup -Filter "resourceProvisioningOptions/Any(x:x eq 'Team')" -All

$Report = @()

foreach ($Team in $Teams) {

    try {

        # Retrieve Team details
        $TeamDetails = Get-MgTeam -TeamId $Team.Id -ErrorAction Stop

        # Process only archived Teams
        if ($TeamDetails.IsArchived -eq $true) {

            Write-Host "Processing archived Team: $($Team.DisplayName)" -ForegroundColor Cyan

            # Get Owners
            $Owners = Get-MgGroupOwner -GroupId $Team.Id -All

            $OwnerNames = ($Owners | ForEach-Object {
                $_.AdditionalProperties.displayName
            }) -join ", "

            # Get Members
            $Members = Get-MgGroupMember -GroupId $Team.Id -All

            $MemberCount = $Members.Count

            # Count Guest Users
            $GuestCount = (
                $Members | Where-Object {
                    $_.AdditionalProperties.userType -eq "Guest"
                }
            ).Count

            # Create report object
            $Report += [PSCustomObject]@{
                TeamName       = $Team.DisplayName
                Visibility     = $Team.Visibility
                CreatedDate    = $Team.CreatedDateTime
                Owners         = $OwnerNames
                MemberCount    = $MemberCount
                GuestCount     = $GuestCount
                ArchivedStatus = $TeamDetails.IsArchived
            }
        }
    }

    catch {
        Write-Host "Error processing Team: $($Team.DisplayName)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Export report
$Report | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

Write-Host "Archived Teams report exported successfully." -ForegroundColor Green

# Create HTML email table preview
$TopTeams = $Report | Select-Object -First 10

$HtmlTable = $TopTeams | ConvertTo-Html -Fragment

$EmailBody = @"
<html>
<body>

<h2>Archived Microsoft Teams Report</h2>

<p>Please find attached the archived Microsoft Teams report.</p>

<p>Below is a preview of the first 10 archived Teams:</p>

$HtmlTable

</body>
</html>
"@

# Send email with attachment
$params = @{
    message = @{
        subject = "Archived Microsoft Teams Governance Report"

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
                name          = "ArchivedTeamsReport.csv"
                contentBytes  = [System.Convert]::ToBase64String(
                    [System.IO.File]::ReadAllBytes($CsvPath)
                )
            }
        )
    }

    saveToSentItems = "true"
}

Send-MgUserMail -UserId $Sender -BodyParameter $params

Write-Host "Email sent successfully." -ForegroundColor Green
