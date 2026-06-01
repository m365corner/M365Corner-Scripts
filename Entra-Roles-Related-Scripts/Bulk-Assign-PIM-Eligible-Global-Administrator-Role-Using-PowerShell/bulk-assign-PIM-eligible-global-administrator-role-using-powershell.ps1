
# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
"RoleManagement.ReadWrite.Directory",
"Directory.ReadWrite.All",
"User.Read.All"

# Import CSV
$Users = Import-Csv "C:\Temp\PIMEligibleAdmins.csv"

# Initialize results array
$Results = @()

# Get Global Administrator role definition
$RoleDefinition = Get-MgRoleManagementDirectoryRoleDefinition `
    -Filter "displayName eq 'Global Administrator'"

if (-not $RoleDefinition) {
    Write-Host "Global Administrator role definition not found. Exiting script." -ForegroundColor Red
    return
}

# Schedule information
$StartDateTime = Get-Date
$EndDateTime = $StartDateTime.AddYears(1)

foreach ($UserEntry in $Users) {

    $UPN = $UserEntry.UserPrincipalName

    Write-Host "`nProcessing user: $UPN" -ForegroundColor Cyan

    try {

        # Validate user
        $User = Get-MgUser -UserId $UPN -ErrorAction SilentlyContinue

        if (-not $User) {

            Write-Host "User not found: $UPN" -ForegroundColor Red

            $Results += [PSCustomObject]@{
                UserPrincipalName = $UPN
                Status            = "Failed"
                Message           = "User not found"
                TimeStamp         = Get-Date
            }

            continue
        }

        # Check for existing eligible assignment
        $ExistingAssignment = Get-MgRoleManagementDirectoryRoleEligibilityScheduleInstance `
            -Filter "principalId eq '$($User.Id)'"

        $AlreadyAssigned = $ExistingAssignment | Where-Object {
            $_.RoleDefinitionId -eq $RoleDefinition.Id
        }

        if ($AlreadyAssigned) {

            Write-Host "Eligible assignment already exists for $UPN" -ForegroundColor Yellow

            $Results += [PSCustomObject]@{
                UserPrincipalName = $UPN
                Status            = "Skipped"
                Message           = "Eligible assignment already exists"
                TimeStamp         = Get-Date
            }

            continue
        }

        # Create eligible assignment request
        $Params = @{
            Action           = "adminAssign"
            PrincipalId      = $User.Id
            RoleDefinitionId = $RoleDefinition.Id
            DirectoryScopeId = "/"
            Justification    = "Bulk PIM onboarding using Graph PowerShell"
            ScheduleInfo     = @{
                StartDateTime = $StartDateTime
                Expiration    = @{
                    Type        = "afterDateTime"
                    EndDateTime = $EndDateTime
                }
            }
        }

        New-MgRoleManagementDirectoryRoleEligibilityScheduleRequest `
            -BodyParameter $Params

        Write-Host "PIM eligible assignment created for $UPN" -ForegroundColor Green

        $Results += [PSCustomObject]@{
            UserPrincipalName = $UPN
            Status            = "Success"
            Message           = "Eligible assignment created successfully"
            TimeStamp         = Get-Date
        }
    }
    catch {

        Write-Host "Error processing user: $UPN" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red

        $Results += [PSCustomObject]@{
            UserPrincipalName = $UPN
            Status            = "Failed"
            Message           = $_.Exception.Message
            TimeStamp         = Get-Date
        }
    }
}

# Export final results
$Results | Export-Csv `
    "C:\Temp\PIMEligibleAssignmentResults.csv" `
    -NoTypeInformation

Write-Host "`nResults exported to C:\Temp\PIMEligibleAssignmentResults.csv" `
    -ForegroundColor Green
