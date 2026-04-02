\# List Entra Apps Created by a Specific User



This script helps administrators identify all Microsoft Entra applications created by a specific user using Microsoft Graph PowerShell.



\---



\## 📌 Overview



Tracking application ownership and origin is essential for maintaining control over your Entra environment.



This script enables you to:



\- Identify apps created by a specific user

\- Investigate suspicious or unauthorized app registrations

\- Support audit and compliance scenarios



\---



\## 🚀 Features



\- Filters Entra applications by creator

\- Helps track user-based app creation activity

\- Useful for security investigations and audits



\---



\## 🛠 Prerequisites



\- Microsoft Graph PowerShell module  

\- Required permissions:

&#x20; - `Application.Read.All`

&#x20; - `Directory.Read.All`



Connect using:



```powershell

Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All"

```



\---



\## 📊 Sample Output



Below is a sample output of the script execution:



!\[Sample Output](demo.png)



> 📌 The image above is sourced from the original M365Corner article.



\---



\## 🎯 Use Cases



\- Identify applications created by a specific user

\- Audit developer or admin activity

\- Detect shadow IT or unauthorized app registrations

\- Strengthen governance and compliance



\---



\## 🌐 Detailed Guide



For full script, explanation, and enhancements:



👉 https://m365corner.com/m365-powershell/list-entra-apps-created-by-specific-user-using-graph-powershell.html



\---



\## ⚠️ Notes



\- Ensure required permissions are granted before execution

\- Results depend on directory size and number of applications

\- Consider exporting results for reporting



\---



\## ⭐ Support



If you find this useful:



\- Star ⭐ the repository  

\- Share with fellow administrators  



\---



\## 📌 About M365Corner



M365Corner provides practical Microsoft 365 PowerShell scripts and admin guides to simplify day-to-day operations.



👉 https://m365corner.com

