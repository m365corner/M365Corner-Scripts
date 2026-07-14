# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Job title to filter
$JobTitle = "Sales Manager"

# Output CSV path
$CsvPath = "C:\Temp\SalesManagers.csv"

# Fetch users with the specified job title
$Users = Get-MgUser -All `
    -Filter "jobTitle eq '$JobTitle'" `
    -Property "id,displayName,userPrincipalName,mail,jobTitle,department,accountEnabled" |
    Select-Object DisplayName,
                  UserPrincipalName,
                  Mail,
                  JobTitle,
                  Department,
                  AccountEnabled,
                  Id

# Get total user count
$UserCount = $Users.Count

# Display summary
Write-Host ""
Write-Host "Job Title: $JobTitle" -ForegroundColor Cyan
Write-Host "Total Users: $UserCount" -ForegroundColor Yellow
Write-Host ""

# Display users
$Users | Format-Table DisplayName, UserPrincipalName, JobTitle, Department, AccountEnabled -AutoSize

# Export results with total count
$Users |
    Select-Object *,
        @{Name="TotalUsersWithJobTitle";Expression={$UserCount}} |
    Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Results exported to: $CsvPath" -ForegroundColor Green