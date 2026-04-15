# Connect to Microsoft Graph
Connect-MgGraph -Scopes Application.Read.All, Directory.Read.All

Write-Host "Scanning applications with Service Principal owners..." -ForegroundColor Cyan

# Get all applications
$Applications = Get-MgApplication -All -Property Id,DisplayName,AppId,CreatedDateTime,Description

$Results = @()

foreach ($App in $Applications) {

    $Owners = Get-MgApplicationOwner -ApplicationId $App.Id

    foreach ($Owner in $Owners) {

        $OwnerType = $null
        $OwnerName = "N/A"
        $OwnerId   = "N/A"

        # Try resolving as User first
        try {
            $User = Get-MgUser -UserId $Owner.Id -ErrorAction Stop
            $OwnerType = "User"
            continue   # Skip users — we only want Service Principals
        }
        catch {
            # Not a user, continue checking
        }

        # Try resolving as Service Principal
        try {
            $SP = Get-MgServicePrincipal -ServicePrincipalId $Owner.Id -ErrorAction Stop

            if ($SP) {
                $OwnerType = "ServicePrincipal"
                $OwnerName = $SP.DisplayName
                $OwnerId   = $SP.Id

                # Console output (minimal)
                Write-Host "$($App.DisplayName) | ServicePrincipal Owner" -ForegroundColor Red

                # Export object
                $Results += [PSCustomObject]@{
                    ApplicationName = $App.DisplayName
                    ApplicationId   = $App.Id
                    ClientId        = $App.AppId
                    CreatedDate     = $App.CreatedDateTime
                    Description     = $App.Description
                    OwnerType       = $OwnerType
                    OwnerName       = $OwnerName
                    OwnerId         = $OwnerId
                }
            }
        }
        catch {
            # Could be group or unknown type
        }
    }
}

# Export results
$ExportPath = "C:\Path\Apps_ServicePrincipal_Owners_Report.csv"

$Results | Export-Csv $ExportPath -NoTypeInformation

Write-Host "Report exported to $ExportPath" -ForegroundColor Cyan