
# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"Group.ReadWrite.All",
"RoleManagement.ReadWrite.Directory",
"Directory.ReadWrite.All",
"Mail.Send"

# CSV input file
$CsvPath = "C:\Reports\RoleAssignableGroups.csv"

# Export report path
$ReportPath = "C:\Reports\RBACGovernanceReport.csv"

# Email settings
$Sender = "admin@contoso.com"
$Recipient = "securityteam@contoso.com"

# Dry-run mode
$DryRun = $false

# Critical roles
$CriticalRoles = @(
    "Global Administrator",
    "Privileged Role Administrator",
    "Authentication Administrator"
)

# Import CSV
$Entries = Import-Csv $CsvPath

$GovernanceReport = @()

foreach ($Entry in $Entries) {

    try {

        $GroupName = $Entry.GroupName.Trim()
        $MailNickname = $Entry.MailNickname.Trim()

        $RoleNames = $Entry.RoleNames.Split(";") | ForEach-Object {
            $_.Trim()
        }

        Write-Host "Processing group: $GroupName" -ForegroundColor Cyan

        # Duplicate group detection
        $ExistingGroup = Get-MgGroup `
        -Filter "displayName eq '$GroupName'"

        if ($ExistingGroup) {

            $GovernanceReport += [PSCustomObject]@{
                GroupName         = $GroupName
                AssignedRoles     = $Entry.RoleNames
                Status            = "Skipped"
                Severity          = "Medium"
                Risk              = "Duplicate Group"
                Recommendation    = "Review existing RBAC group before creating duplicates"
            }

            continue
        }

        # Naming convention validation
        if ($GroupName -notmatch "^PIM-T[0-9]-") {
            $NamingWarning = "Naming Convention Warning"
        }
        else {
            $NamingWarning = "None"
        }

        # Excessive role detection
        if ($RoleNames.Count -gt 3) {
            $RoleThresholdRisk = "Too Many Roles Assigned"
            $Severity = "High"
        }
        else {
            $RoleThresholdRisk = "None"
            $Severity = "Low"
        }

        # Dry-run mode
        if ($DryRun -eq $true) {

            $GovernanceReport += [PSCustomObject]@{
                GroupName         = $GroupName
                AssignedRoles     = $Entry.RoleNames
                Status            = "DryRun"
                Severity          = $Severity
                Risk              = "Preview Mode"
                Recommendation    = "Validation completed successfully"
            }

            continue
        }

        # Create role-assignable group
        $NewGroup = New-MgGroup `
        -DisplayName $GroupName `
        -MailEnabled:$false `
        -MailNickname $MailNickname `
        -SecurityEnabled:$true `
        -IsAssignableToRole:$true

        Write-Host "Created group: $GroupName" -ForegroundColor Green

        $AssignedRoles = @()

        foreach ($RoleName in $RoleNames) {

            # Validate role template
            $RoleTemplate = Get-MgDirectoryRoleTemplate | Where-Object {
                $_.DisplayName -eq $RoleName
            }

            if (-not $RoleTemplate) {
                $AssignedRoles += "$RoleName (Invalid Role)"
                continue
            }

            # Activate role if not already active
            $DirectoryRole = Get-MgDirectoryRole | Where-Object {
                $_.DisplayName -eq $RoleName
            }

            if (-not $DirectoryRole) {

                New-MgDirectoryRole `
                -DirectoryRoleTemplateId $RoleTemplate.Id

                Start-Sleep -Seconds 5

                $DirectoryRole = Get-MgDirectoryRole | Where-Object {
                    $_.DisplayName -eq $RoleName
                }
            }

            # Assign role to group
            New-MgRoleManagementDirectoryRoleAssignment `
            -PrincipalId $NewGroup.Id `
            -RoleDefinitionId $DirectoryRole.Id `
            -DirectoryScopeId "/"

            $AssignedRoles += $RoleName

            Write-Host "Assigned role: $RoleName" -ForegroundColor Yellow
        }

        # Critical role detection
        $CriticalRoleDetected = (
            $AssignedRoles | Where-Object {
                $_ -in $CriticalRoles
            }
        )

        if ($CriticalRoleDetected) {
            $Severity = "Critical"
        }

        # Governance score
        $GovernanceScore = 100

        if ($NamingWarning -ne "None") {
            $GovernanceScore -= 20
        }

        if ($RoleThresholdRisk -ne "None") {
            $GovernanceScore -= 30
        }

        if ($CriticalRoleDetected) {
            $GovernanceScore -= 30
        }

        $GovernanceReport += [PSCustomObject]@{
            GroupName         = $GroupName
            AssignedRoles     = $AssignedRoles -join "; "
            Status            = "Success"
            Severity          = $Severity
            Risk              = "$NamingWarning; $RoleThresholdRisk"
            GovernanceScore   = $GovernanceScore
            Recommendation    = "Review RBAC assignments periodically"
        }
    }

    catch {

        $GovernanceReport += [PSCustomObject]@{
            GroupName         = $GroupName
            AssignedRoles     = $Entry.RoleNames
            Status            = "Failed"
            Severity          = "High"
            Risk              = "Validation Failure"
            GovernanceScore   = 0
            Recommendation    = $_.Exception.Message
        }

        Write-Host "Error processing group: $GroupName" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Export governance report
$GovernanceReport | Export-Csv `
-Path $ReportPath `
-NoTypeInformation `
-Encoding UTF8

Write-Host "RBAC governance report exported successfully." -ForegroundColor Green

# Governance statistics
$SuccessfulGroups = (
    $GovernanceReport |
    Where-Object {
        $_.Status -eq "Success"
    }
).Count

$CriticalFindings = (
    $GovernanceReport |
    Where-Object {
        $_.Severity -eq "Critical"
    }
).Count

$DuplicateGroups = (
    $GovernanceReport |
    Where-Object {
        $_.Risk -match "Duplicate Group"
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

<h2>Entra ID RBAC Governance Report</h2>

<p>The automated RBAC governance review has completed successfully.</p>

<ul>
<li>Successfully Created Groups: $SuccessfulGroups</li>
<li>Critical RBAC Findings: $CriticalFindings</li>
<li>Duplicate Groups Detected: $DuplicateGroups</li>
<li>Failures: $Failures</li>
</ul>

<p>Below is a preview of the first 10 processed groups:</p>

$HtmlPreview

</body>
</html>
"@

# Send governance report
$params = @{
    message = @{
        subject = "Entra ID RBAC Governance Report"

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
                name          = "RBACGovernanceReport.csv"
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

Write-Host "RBAC governance report emailed successfully." -ForegroundColor Green
