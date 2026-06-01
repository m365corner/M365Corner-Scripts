
# Import required modules
Import-Module ExchangeOnlineManagement
Import-Module Microsoft.Graph

# Connect to Exchange Online
Connect-ExchangeOnline

# Verify EXO connection
$EXOConnection = Get-ConnectionInformation

if (-not $EXOConnection) {
    Write-Host "Exchange Online connection failed. Please reconnect using Connect-ExchangeOnline." -ForegroundColor Red
    return
}

# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"Domain.Read.All",
"Mail.Send"

# Report path
$ReportPath = "C:\Reports\MailboxPermissionSecurityAudit.csv"

# Email settings
$Sender = "admin@contoso.com"
$EmailRecipient = "securityteam@contoso.com"

# Internal verified domains
$AcceptedDomains = (
    Get-MgDomain |
    Where-Object {
        $_.IsVerified -eq $true
    }
).Id

$AuditReport = @()

# Get user and shared mailboxes
$Mailboxes = Get-EXOMailbox `
-ResultSize Unlimited `
-RecipientTypeDetails UserMailbox,SharedMailbox `
-Properties GrantSendOnBehalfTo

foreach ($Mailbox in $Mailboxes) {

    Write-Host "Processing mailbox: $($Mailbox.UserPrincipalName)" -ForegroundColor Cyan

    # Full Access permissions
    $FullAccessPermissions = Get-EXOMailboxPermission `
    -Identity $Mailbox.UserPrincipalName `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.AccessRights -contains "FullAccess" -and
        $_.IsInherited -eq $false -and
        $_.User -notlike "NT AUTHORITY\SELF"
    }

    foreach ($Permission in $FullAccessPermissions) {

        $DelegateIdentity = $Permission.User.ToString()
        $DelegateName = $DelegateIdentity
        $DelegateAddress = "Unknown"
        $DelegateType = "Unknown"
        $DomainCategory = "Unknown"

        try {
            $ResolvedDelegate = Get-EXORecipient `
            -Identity $DelegateIdentity `
            -ErrorAction Stop

            $DelegateName = $ResolvedDelegate.DisplayName
            $DelegateType = $ResolvedDelegate.RecipientTypeDetails

            if ($ResolvedDelegate.PrimarySmtpAddress) {
                $DelegateAddress = $ResolvedDelegate.PrimarySmtpAddress.ToString()

                $Domain = (
                    $DelegateAddress -split "@"
                )[-1].ToLower()

                if ($AcceptedDomains -contains $Domain) {
                    $DomainCategory = "Internal"
                }
                else {
                    $DomainCategory = "External or Unknown"
                }
            }
        }
        catch {
            $DomainCategory = "Unresolved"
        }

        $RiskScore = 30
        $Severity = "Medium"
        $Recommendation = "Review Full Access permission"

        if ($Mailbox.RecipientTypeDetails -eq "SharedMailbox") {
            $RiskScore += 10
            $Recommendation += "; validate shared mailbox access"
        }

        if ($DomainCategory -ne "Internal") {
            $RiskScore += 30
            $Severity = "High"
            $Recommendation += "; investigate external or unresolved delegate"
        }

        $AuditReport += [PSCustomObject]@{
            Mailbox         = $Mailbox.UserPrincipalName
            DisplayName     = $Mailbox.DisplayName
            MailboxType     = $Mailbox.RecipientTypeDetails
            PermissionType  = "Full Access"
            DelegateName    = $DelegateName
            DelegateAddress = $DelegateAddress
            DelegateType    = $DelegateType
            DomainCategory  = $DomainCategory
            Severity        = $Severity
            RiskScore       = $RiskScore
            Recommendation  = $Recommendation
        }
    }

    # Send As permissions
    $SendAsPermissions = Get-RecipientPermission `
    -Identity $Mailbox.UserPrincipalName `
    -ErrorAction SilentlyContinue |
    Where-Object {
        $_.AccessRights -contains "SendAs" -and
        $_.Trustee -notlike "NT AUTHORITY\SELF"
    }

    foreach ($Permission in $SendAsPermissions) {

        $DelegateIdentity = $Permission.Trustee.ToString()
        $DelegateName = $DelegateIdentity
        $DelegateAddress = "Unknown"
        $DelegateType = "Unknown"
        $DomainCategory = "Unknown"

        try {
            $ResolvedDelegate = Get-EXORecipient `
            -Identity $DelegateIdentity `
            -ErrorAction Stop

            $DelegateName = $ResolvedDelegate.DisplayName
            $DelegateType = $ResolvedDelegate.RecipientTypeDetails

            if ($ResolvedDelegate.PrimarySmtpAddress) {
                $DelegateAddress = $ResolvedDelegate.PrimarySmtpAddress.ToString()

                $Domain = (
                    $DelegateAddress -split "@"
                )[-1].ToLower()

                if ($AcceptedDomains -contains $Domain) {
                    $DomainCategory = "Internal"
                }
                else {
                    $DomainCategory = "External or Unknown"
                }
            }
        }
        catch {
            $DomainCategory = "Unresolved"
        }

        $RiskScore = 40
        $Severity = "High"
        $Recommendation = "Review Send As permission immediately"

        if ($DomainCategory -ne "Internal") {
            $RiskScore += 30
            $Severity = "Critical"
            $Recommendation += "; investigate external or unresolved Send As delegate"
        }

        $AuditReport += [PSCustomObject]@{
            Mailbox         = $Mailbox.UserPrincipalName
            DisplayName     = $Mailbox.DisplayName
            MailboxType     = $Mailbox.RecipientTypeDetails
            PermissionType  = "Send As"
            DelegateName    = $DelegateName
            DelegateAddress = $DelegateAddress
            DelegateType    = $DelegateType
            DomainCategory  = $DomainCategory
            Severity        = $Severity
            RiskScore       = $RiskScore
            Recommendation  = $Recommendation
        }
    }

    # Send on Behalf permissions
    if ($Mailbox.GrantSendOnBehalfTo) {

        foreach ($Delegate in $Mailbox.GrantSendOnBehalfTo) {

            $DelegateIdentity = $Delegate.ToString()
            $DelegateName = $DelegateIdentity
            $DelegateAddress = "Unknown"
            $DelegateType = "Unknown"
            $DomainCategory = "Unknown"

            try {
                $ResolvedDelegate = Get-EXORecipient `
                -Identity $DelegateIdentity `
                -ErrorAction Stop

                $DelegateName = $ResolvedDelegate.DisplayName
                $DelegateType = $ResolvedDelegate.RecipientTypeDetails

                if ($ResolvedDelegate.PrimarySmtpAddress) {
                    $DelegateAddress = $ResolvedDelegate.PrimarySmtpAddress.ToString()

                    $Domain = (
                        $DelegateAddress -split "@"
                    )[-1].ToLower()

                    if ($AcceptedDomains -contains $Domain) {
                        $DomainCategory = "Internal"
                    }
                    else {
                        $DomainCategory = "External or Unknown"
                    }
                }
            }
            catch {
                $DomainCategory = "Unresolved"
            }

            $RiskScore = 25
            $Severity = "Medium"
            $Recommendation = "Review Send on Behalf permission"

            if ($DomainCategory -ne "Internal") {
                $RiskScore += 25
                $Severity = "High"
                $Recommendation += "; investigate external or unresolved delegate"
            }

            $AuditReport += [PSCustomObject]@{
                Mailbox         = $Mailbox.UserPrincipalName
                DisplayName     = $Mailbox.DisplayName
                MailboxType     = $Mailbox.RecipientTypeDetails
                PermissionType  = "Send on Behalf"
                DelegateName    = $DelegateName
                DelegateAddress = $DelegateAddress
                DelegateType    = $DelegateType
                DomainCategory  = $DomainCategory
                Severity        = $Severity
                RiskScore       = $RiskScore
                Recommendation  = $Recommendation
            }
        }
    }
}

# Export report
$AuditReport | Export-Csv `
-Path $ReportPath `
-NoTypeInformation `
-Encoding UTF8

# Summary counts
$TotalFindings = $AuditReport.Count

$CriticalFindings = (
    $AuditReport |
    Where-Object {
        $_.Severity -eq "Critical"
    }
).Count

$HighFindings = (
    $AuditReport |
    Where-Object {
        $_.Severity -eq "High"
    }
).Count

$SendAsFindings = (
    $AuditReport |
    Where-Object {
        $_.PermissionType -eq "Send As"
    }
).Count

$ExternalDelegates = (
    $AuditReport |
    Where-Object {
        $_.DomainCategory -ne "Internal"
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

<h2>Exchange Online Mailbox Permission Security Audit</h2>

<p>The automated mailbox permission security audit has completed successfully.</p>

<ul>
<li>Total Permission Findings: $TotalFindings</li>
<li>Critical Findings: $CriticalFindings</li>
<li>High Severity Findings: $HighFindings</li>
<li>Send As Permissions Found: $SendAsFindings</li>
<li>External or Unresolved Delegates: $ExternalDelegates</li>
</ul>

<p>Below is a preview of the first 10 permission findings:</p>

$HtmlPreview

</body>
</html>
"@

# Send report
$params = @{
    message = @{
        subject = "Exchange Online Mailbox Permission Security Audit"

        body = @{
            contentType = "HTML"
            content = $EmailBody
        }

        toRecipients = @(
            @{
                emailAddress = @{
                    address = $EmailRecipient
                }
            }
        )

        attachments = @(
            @{
                "@odata.type" = "#microsoft.graph.fileAttachment"
                name          = "MailboxPermissionSecurityAudit.csv"
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

Write-Host "Mailbox permission security audit completed and emailed successfully." -ForegroundColor Green
