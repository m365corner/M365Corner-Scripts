\# List Entra App Owners using Graph PowerShell



This script retrieves all Microsoft Entra applications along with their assigned owners using Microsoft Graph PowerShell.



\---



\## 📌 Overview



Managing application ownership is critical for maintaining security and accountability in Microsoft Entra ID.



This script helps administrators:



\- Identify application owners

\- Detect orphaned applications (apps without owners)

\- Improve governance and audit readiness



\---



\## 🚀 Features



\- Retrieves all Entra applications

\- Fetches assigned owners for each application

\- Displays owner details (Display Name, UPN)

\- Helps identify ownership gaps



\---



\## 🛠 Prerequisites



\- Microsoft Graph PowerShell module installed  

\- Required permissions:

&#x20; - `Application.Read.All`

&#x20; - `Directory.Read.All`



Connect using:



```powershell

Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All"

```



\---



\## 📜 Script



```powershell

\# Connect to Microsoft Graph

Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All"



\# Retrieve all applications

$Apps = Get-MgApplication -All



$Results = @()



foreach ($App in $Apps) {

&#x20;   $Owners = Get-MgApplicationOwner -ApplicationId $App.Id



&#x20;   if ($Owners) {

&#x20;       foreach ($Owner in $Owners) {

&#x20;           $Results += \[PSCustomObject]@{

&#x20;               AppName        = $App.DisplayName

&#x20;               AppId          = $App.AppId

&#x20;               OwnerName      = $Owner.AdditionalProperties.displayName

&#x20;               OwnerUPN       = $Owner.AdditionalProperties.userPrincipalName

&#x20;           }

&#x20;       }

&#x20;   }

&#x20;   else {

&#x20;       $Results += \[PSCustomObject]@{

&#x20;           AppName   = $App.DisplayName

&#x20;           AppId     = $App.AppId

&#x20;           OwnerName = "No Owner"

&#x20;           OwnerUPN  = "N/A"

&#x20;       }

&#x20;   }

}



\# Output results

$Results | Format-Table -AutoSize

```



\---



\## 📊 Sample Output



| AppName | AppId | OwnerName | OwnerUPN |

|--------|------|----------|----------|

| Sample App | xxxxxxxx | John Doe | john@domain.com |



\---



\## 🎯 Use Cases



\- Audit application ownership

\- Identify orphaned Entra applications

\- Strengthen security governance

\- Support compliance requirements



\---



\## 🌐 Detailed Guide



For a complete walkthrough, explanation, and enhancements:



👉 https://m365corner.com/m365-powershell/list-entra-id-application-owners-using-graph-powershell.html



\---



\## ⚠️ Notes



\- Ensure proper permissions before running the script

\- Large environments may take time to process

\- Consider exporting results for reporting



\---



\## 🤝 Contributing



Suggestions and improvements are welcome as this repository evolves.



\---



\## ⭐ Support



If you find this useful:



\- Star ⭐ the repository  

\- Share with fellow administrators  



\---



\## 📌 About M365Corner



M365Corner provides practical Microsoft 365 PowerShell scripts and admin guides to simplify day-to-day operations.



👉 https://m365corner.com

