
# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"Group.ReadWrite.All",
"User.Read.All",
"Directory.Read.All",
"Mail.Send"

# CSV input file
$CsvPath = "C:\Reports\RoleAssignableGroupMembers.csv"

# Export report path
$ReportPath = "C:\Reports\PrivilegedAccessGovernanceReport.csv"

# Email settings
$Sender = "admin@contoso.com"
$Recipient = "securityteam@contoso.com"

# Dry-run mode
$DryRun = $false

# Import CSV
$Entries = Import-Csv $CsvPath

$GovernanceReport = @()

# Track duplicate CSV rows
$ProcessedCsvEntries = @{}

# Cache group members
$GroupMemberCache = @{}

foreach ($Entry in $Entries) {

    $UPN = $Entry.UserPrincipalName.Trim()
    $GroupId = $Entry.GroupId.Trim()

    $CsvKey = "$($UPN.ToLower())|$($GroupId.ToLower())"

    if ($ProcessedCsvEntries.ContainsKey($CsvKey)) {

        $GovernanceReport += [PSCustomObject]@{
            UserPrincipalName = $UPN
            GroupId           = $GroupId
            Status            = "Skipped"
            Risk              = "Duplicate CSV Entry"
            Recommendation    = "Remove duplicate row from CSV file"
        }

        Write-Host "Duplicate CSV entry skipped: $UPN" -ForegroundColor Yellow
        continue
    }

    $ProcessedCsvEntries[$CsvKey] = $true

    try {

        Write-Host "Processing user: $UPN" -ForegroundColor Cyan

        # Validate user
        $User = Get-MgUser `
        -UserId $UPN `
        -Property @(
            "Id",
            "DisplayName",
            "UserPrincipalName",
            "AccountEnabled",
            "UserType"
        ) `
        -ErrorAction Stop

        # Guest user check
        if ($User.UserType -eq "Guest") {

            $GovernanceReport += [PSCustomObject]@{
                UserPrincipalName = $UPN
                GroupId           = $GroupId
                Status            = "Blocked"
                Risk              = "Guest User"
                Recommendation    = "Do not assign guest users to role-assignable groups"
            }

            continue
        }

        # Disabled account check
        if ($null -eq $User.AccountEnabled -or $User.AccountEnabled -eq $false) {

            $GovernanceReport += [PSCustomObject]@{
                UserPrincipalName = $UPN
                GroupId           = $GroupId
                Status            = "Skipped"
                Risk              = "Disabled Account"
                Recommendation    = "Review stale or disabled privileged accounts"
            }

            continue
        }

        # Cache group members
        if (-not $GroupMemberCache.ContainsKey($GroupId)) {

            $ExistingMembers = Get-MgGroupMember `
            -GroupId $GroupId `
            -All

            $GroupMemberCache[$GroupId] = @($ExistingMembers.Id)
        }

        # Check existing membership
        $AlreadyExists = $GroupMemberCache[$GroupId] -contains $User.Id

        if ($AlreadyExists) {

            $GovernanceReport += [PSCustomObject]@{
                UserPrincipalName = $UPN
                GroupId           = $GroupId
                Status            = "Skipped"
                Risk              = "Existing Membership"
                Recommendation    = "User is already a member of the role-assignable group"
            }

            Write-Host "User already exists in group: $UPN" -ForegroundColor Yellow
            continue
        }

        # Dry-run mode
        if ($DryRun -eq $true) {

            $GovernanceReport += [PSCustomObject]@{
                UserPrincipalName = $UPN
                GroupId           = $GroupId
                Status            = "DryRun"
                Risk              = "None"
                Recommendation    = "Preview mode enabled. User was not added."
            }

            continue
        }

        # Add user to group
        New-MgGroupMember `
        -GroupId $GroupId `
        -DirectoryObjectId $User.Id

        # Update cache
        $GroupMemberCache[$GroupId] += $User.Id

        $GovernanceReport += [PSCustomObject]@{
            UserPrincipalName = $UPN
            GroupId           = $GroupId
            Status            = "Success"
            Risk              = "None"
            Recommendation    = "User added successfully"
        }

        Write-Host "Added user successfully: $UPN" -ForegroundColor Green
    }

    catch {

        $GovernanceReport += [PSCustomObject]@{
            UserPrincipalName = $UPN
            GroupId           = $GroupId
            Status            = "Failed"
            Risk              = "Validation Failure"
            Recommendation    = $_.Exception.Message
        }

        Write-Host "Error processing user: $UPN" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Export report
$GovernanceReport | Export-Csv `
-Path $ReportPath `
-NoTypeInformation `
-Encoding UTF8

Write-Host "Governance report exported successfully." -ForegroundColor Green

# Stats
$SuccessfulAdds = (
    $GovernanceReport |
    Where-Object {
        $_.Status -eq "Success"
    }
).Count

$BlockedUsers = (
    $GovernanceReport |
    Where-Object {
        $_.Status -eq "Blocked"
    }
).Count

$DuplicateCsvEntries = (
    $GovernanceReport |
    Where-Object {
        $_.Risk -eq "Duplicate CSV Entry"
    }
).Count

$ExistingMemberships = (
    $GovernanceReport |
    Where-Object {
        $_.Risk -eq "Existing Membership"
    }
).Count

$Failures = (
    $GovernanceReport |
    Where-Object {
        $_.Status -eq "Failed"
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

<h2>Privileged Access Governance Report</h2>

<p>The role-assignable group governance review has completed successfully.</p>

<ul>
<li>Successful Additions: $SuccessfulAdds</li>
<li>Blocked Guest Users: $BlockedUsers</li>
<li>Duplicate CSV Entries: $DuplicateCsvEntries</li>
<li>Existing Memberships: $ExistingMemberships</li>
<li>Failures: $Failures</li>
</ul>

<p>Below is a preview of the first 10 processed entries:</p>

$HtmlPreview

</body>
</html>
"@

# Send email
$params = @{
    message = @{
        subject = "Privileged Access Governance Report"

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
                name          = "PrivilegedAccessGovernanceReport.csv"
                contentBytes  = [System.Convert]::ToBase64String(
                    [System.IO.File]::ReadAllBytes($ReportPath)
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
