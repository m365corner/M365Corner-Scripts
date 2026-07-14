# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Department to filter
$Department = "Sales"

# Output CSV path
$CsvPath = "C:\Temp\SalesUsers.csv"

# Fetch users from the specified department
$Users = Get-MgUser -All `
    -Filter "department eq '$Department'" `
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
Write-Host "Department: $Department" -ForegroundColor Cyan
Write-Host "Total Users: $UserCount" -ForegroundColor Yellow
Write-Host ""

# Display users
$Users | Format-Table DisplayName, UserPrincipalName, JobTitle, Department, AccountEnabled -AutoSize

# Add the total count to each exported record
$Users |
    Select-Object *,
        @{Name="TotalUsersInDepartment";Expression={$UserCount}} |
    Export-Csv -Path $CsvPath -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Results exported to: $CsvPath" -ForegroundColor Green