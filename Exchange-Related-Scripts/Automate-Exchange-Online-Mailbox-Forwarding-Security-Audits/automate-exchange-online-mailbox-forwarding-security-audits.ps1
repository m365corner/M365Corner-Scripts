
# Import required modules
Import-Module ExchangeOnlineManagement
Import-Module Microsoft.Graph

# Connect to Exchange Online
Connect-ExchangeOnline

# Verify Exchange Online connection
$EXOConnection = Get-ConnectionInformation

if (-not $EXOConnection) {
    Write-Host "Exchange Online connection failed. Please reconnect using Connect-ExchangeOnline." -ForegroundColor Red
    return
}

# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"User.Read.All",
"Domain.Read.All",
"Mail.Send"

# Export report path
$ReportPath = "C:\Reports\MailboxForwardingSecurityAudit.csv"

# Email settings
$Sender = "admin@contoso.com"
$Recipient = "securityteam@contoso.com"

# Get accepted/internal domains using Microsoft Graph
$AcceptedDomains = (
    Get-MgDomain |
    Where-Object {
        $_.IsVerified -eq $true
    }
).Id

# High-risk consumer domains
$ConsumerDomains = @(
    "gmail.com",
    "yahoo.com",
    "outlook.com",
    "hotmail.com",
    "icloud.com"
)

$AuditReport = @()

# Retrieve mailboxes
$Mailboxes = Get-EXOMailbox `
-ResultSize Unlimited `
-Properties ForwardingSMTPAddress,ForwardingAddress,RecipientTypeDetails

foreach ($Mailbox in $Mailboxes) {

    try {

        Write-Host "Processing mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Cyan

        $ForwardingMethods = @()
        $Severity = "Low"
        $RiskScore = 0
        $Recommendations = @()

        $ForwardDestination = $null
        $ForwardingType = $null
        $DestinationCategory = "None"

        # Mailbox-level forwarding detection
        if ($Mailbox.ForwardingSMTPAddress) {

            $ForwardDestination = $Mailbox.ForwardingSMTPAddress.ToString()
            $ForwardingType = "Mailbox Forwarding"

            $ForwardingMethods += "Mailbox Forwarding"
            $RiskScore += 30
            $Recommendations += "Review mailbox-level forwarding"

            # Clean forwarding address
            $CleanForwardingAddress = $ForwardDestination -replace "smtp:", ""

            # Extract domain
            $ForwardDomain = (
                $CleanForwardingAddress -split "@"
            )[-1].ToLower()

            # Internal vs external forwarding
            if ($AcceptedDomains -contains $ForwardDomain) {

                $DestinationCategory = "Internal"

                if ($Severity -ne "Critical") {
                    $Severity = "Medium"
                }
            }
            else {

                $DestinationCategory = "External"
                $Severity = "High"
                $RiskScore += 40
                $Recommendations += "Investigate external forwarding immediately"

                if ($ConsumerDomains -contains $ForwardDomain) {

                    $DestinationCategory = "Consumer Email Domain"
                    $RiskScore += 20
                    $Recommendations += "Review suspicious consumer email forwarding"
                }
            }
        }

        # Inbox rule forwarding detection
        $InboxRules = Get-InboxRule `
        -Mailbox $Mailbox.UserPrincipalName `
        -ErrorAction SilentlyContinue

        $ForwardingRules = $InboxRules | Where-Object {
            $_.ForwardTo -or
            $_.RedirectTo -or
            $_.ForwardAsAttachmentTo
        }

        if ($ForwardingRules) {

            $ForwardingMethods += "Inbox Rule Forwarding"
            $RiskScore += 35

            if ($Severity -ne "Critical") {
                $Severity = "High"
            }

            $Recommendations += "Review suspicious inbox forwarding rules"
        }

        # Multiple forwarding method detection
        if ($ForwardingMethods.Count -gt 1) {

            $Severity = "Critical"
            $RiskScore += 30
            $Recommendations += "Investigate possible compromise activity"
        }

        # Shared mailbox detection
        if ($Mailbox.RecipientTypeDetails -eq "SharedMailbox") {

            $RiskScore += 10
            $Recommendations += "Validate forwarding necessity for shared mailbox"
        }

        # Add only mailboxes with forwarding activity
        if ($ForwardingMethods.Count -gt 0) {

            $AuditReport += [PSCustomObject]@{
                Mailbox                 = $Mailbox.UserPrincipalName
                DisplayName             = $Mailbox.DisplayName
                MailboxType             = $Mailbox.RecipientTypeDetails
                ForwardingType          = $ForwardingMethods -join "; "
                ForwardDestination      = $ForwardDestination
                DestinationCategory     = $DestinationCategory
                Severity                = $Severity
                ForwardingRiskScore     = $RiskScore
                Recommendations         = $Recommendations -join "; "
            }
        }
    }

    catch {

        $AuditReport += [PSCustomObject]@{
            Mailbox                 = $Mailbox.UserPrincipalName
            DisplayName             = $Mailbox.DisplayName
            MailboxType             = $Mailbox.RecipientTypeDetails
            ForwardingType          = "Audit Failure"
            ForwardDestination      = "N/A"
            DestinationCategory     = "Unknown"
            Severity                = "High"
            ForwardingRiskScore     = 0
            Recommendations         = $_.Exception.Message
        }

        Write-Host "Error processing mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Export report
$AuditReport | Export-Csv `
-Path $ReportPath `
-NoTypeInformation `
-Encoding UTF8

Write-Host "Mailbox forwarding security report exported successfully." -ForegroundColor Green

# Governance statistics
$TotalForwardingMailboxes = $AuditReport.Count

$ExternalForwarding = (
    $AuditReport |
    Where-Object {
        $_.DestinationCategory -match "External|Consumer"
    }
).Count

$CriticalFindings = (
    $AuditReport |
    Where-Object {
        $_.Severity -eq "Critical"
    }
).Count

$InboxRuleForwarding = (
    $AuditReport |
    Where-Object {
        $_.ForwardingType -match "Inbox Rule Forwarding"
    }
).Count

# HTML preview
$HtmlPreview = (
    $AuditReport |
    Select-Object -First 10 |
    ConvertTo-Html -Fragment
)

# Email body
$EmailBody = @"
<html>
<body>

<h2>Exchange Online Mailbox Forwarding Security Audit</h2>

<p>The automated mailbox forwarding security audit has completed successfully.</p>

<ul>
<li>Total Mailboxes with Forwarding: $TotalForwardingMailboxes</li>
<li>External Forwarding Detected: $ExternalForwarding</li>
<li>Critical Security Findings: $CriticalFindings</li>
<li>Inbox Rule Forwarding Detected: $InboxRuleForwarding</li>
</ul>

<p>Below is a preview of the first 10 mailboxes with forwarding activity:</p>

$HtmlPreview

</body>
</html>
"@

# Send email report
$params = @{
    message = @{
        subject = "Exchange Online Mailbox Forwarding Security Audit"

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
                name          = "MailboxForwardingSecurityAudit.csv"
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

Write-Host "Mailbox forwarding security audit emailed successfully." -ForegroundColor Green
