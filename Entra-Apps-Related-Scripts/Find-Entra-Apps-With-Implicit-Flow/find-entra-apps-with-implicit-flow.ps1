# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All

Write-Host "Scanning applications with Implicit Flow enabled..." -ForegroundColor Cyan

# Get applications with Web settings
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description,Web

$Results = @()

foreach ($App in $Applications) {

    $ImplicitIdToken    = $App.Web.ImplicitGrantSettings.EnableIdTokenIssuance
    $ImplicitAccessToken = $App.Web.ImplicitGrantSettings.EnableAccessTokenIssuance

    if ($ImplicitIdToken -eq $true -or $ImplicitAccessToken -eq $true) {

        # Console output (minimal)
        Write-Host "$($App.DisplayName) | $($App.AppId)" -ForegroundColor Yellow

        # Export object (detailed)
        $Results += [PSCustomObject]@{
            ApplicationName        = $App.DisplayName
            ApplicationId          = $App.Id
            ClientId               = $App.AppId
            CreatedDate            = $App.CreatedDateTime
            Description            = $App.Description
            ImplicitIdTokenEnabled = $ImplicitIdToken
            ImplicitAccessTokenEnabled = $ImplicitAccessToken
            ImplicitFlowStatus     = "Enabled"
        }
    }
}

# Export results
$ExportPath = "C:\Path\Apps_ImplicitFlow_Enabled_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan