
# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning applications for expiring/expired client secrets..." -ForegroundColor Cyan

# Threshold for expiring secrets (next 30 days)
$ThresholdDate = (Get-Date).AddDays(30)

# Get all applications with password credentials
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,PasswordCredentials

$Results = @()

foreach ($App in $Applications) {

    if (-not $App.PasswordCredentials) {
        continue
    }

    foreach ($Secret in $App.PasswordCredentials) {

        $ExpiryDate = $Secret.EndDateTime

        # Determine status
        if ($ExpiryDate -lt (Get-Date)) {
            $Status = "Expired"
        }
        elseif ($ExpiryDate -le $ThresholdDate) {
            $Status = "Expiring Soon"
        }
        else {
            continue
        }

        # Console output (basic)
        Write-Host "$($App.DisplayName) | $($App.AppId) | $Status" -ForegroundColor Yellow

        # Detailed export object
        $Results += [PSCustomObject]@{
            ApplicationName   = $App.DisplayName
            ApplicationId     = $App.Id
            ClientId          = $App.AppId
            SecretDisplayName = $Secret.DisplayName
            SecretId          = $Secret.KeyId
            StartDate         = $Secret.StartDateTime
            ExpiryDate        = $ExpiryDate
            Status            = $Status
        }
    }
}

# Export results
$ExportPath = "C:\Path\Expiring_Expired_ClientSecrets_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Client secrets report exported to $ExportPath" -ForegroundColor Cyan
                                