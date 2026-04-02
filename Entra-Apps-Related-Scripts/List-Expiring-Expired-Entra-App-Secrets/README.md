<html>



<h1>List Expiring or Expired Entra App Secrets</h1>



<p>

This script helps administrators identify Microsoft Entra applications with expiring or expired client secrets using Microsoft Graph PowerShell.

</p>



<hr>



<h2>📌 Overview</h2>



<p>

Expired or soon-to-expire client secrets can cause application failures and potential service disruptions if not monitored proactively.

</p>



<p>This script enables you to:</p>

<ul>

<li>Identify expired client secrets</li>

<li>Detect secrets that are nearing expiration</li>

<li>Prevent unexpected application outages</li>

</ul>



<hr>



<h2>🚀 Features</h2>



<ul>

<li>Detects expired and expiring application secrets</li>

<li>Helps prevent authentication failures</li>

<li>Supports proactive monitoring and maintenance</li>

</ul>



<hr>



<h2>🛠 Prerequisites</h2>



<ul>

<li>Microsoft Graph PowerShell module</li>

<li>Required permissions:

&#x20;   <ul>

&#x20;       <li><code>Application.Read.All</code></li>

&#x20;       <li><code>Directory.Read.All</code></li>

&#x20;   </ul>

</li>

</ul>



<p>Connect using:</p>



<pre>

Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All"

</pre>



<hr>



<h2>📊 Sample Output</h2>



<p>Below is a sample output of the script execution:</p>



<img src="demo.png" alt="List Expiring or Expired Entra App Secrets Output" width="800"/>



<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>



<hr>



<h2>🎯 Use Cases</h2>



<ul>

<li>Monitor expiring application secrets</li>

<li>Prevent service disruptions due to expired credentials</li>

<li>Maintain application authentication health</li>

<li>Support security and compliance audits</li>

</ul>



<hr>



<h2>🌐 Detailed Guide</h2>



<p>

For full script, explanation, and enhancements:

</p>



<p>

👉 <a href="https://m365corner.com/m365-powershell/list-expiring-or-expired-entra-app-secrets.html" target="\_blank">

View Detailed Article on M365Corner

</a>

</p>



<hr>



<h2>⚠️ Notes</h2>



<ul>

<li>Ensure required permissions are granted before execution</li>

<li>Regular monitoring is recommended to avoid downtime</li>

<li>Consider automating alerts for expiring secrets</li>

</ul>



<hr>



<h2>⭐ Support</h2>



<p>If you find this useful:</p>



<ul>

<li>Star ⭐ the repository</li>

<li>Share with fellow administrators</li>

</ul>



<hr>



<h2>📌 About M365Corner</h2>



<p>

M365Corner provides practical Microsoft 365 PowerShell scripts and admin guides to simplify day-to-day operations.

</p>



<p>

👉 <a href="https://m365corner.com" target="\_blank">https://m365corner.com</a>

</p>



</html>



