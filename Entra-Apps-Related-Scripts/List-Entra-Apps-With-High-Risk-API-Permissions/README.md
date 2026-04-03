<html>



<h1>List Entra Apps with High-Risk API Permissions</h1>



<p>

This script helps administrators identify Microsoft Entra applications that have high-risk API permissions using Microsoft Graph PowerShell.

</p>



<hr>



<h2>📌 Overview</h2>



<p>

Applications with high-risk API permissions can expose sensitive data and operations if not properly governed.

</p>



<p>This script enables you to:</p>

<ul>

<li>Identify applications with elevated or risky permissions</li>

<li>Detect potential security vulnerabilities</li>

<li>Strengthen application governance</li>

</ul>



<hr>



<h2>🚀 Features</h2>



<ul>

<li>Scans Entra applications for high-risk API permissions</li>

<li>Highlights potentially dangerous permission grants</li>

<li>Supports security audits and compliance reviews</li>

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



<img src="demo.png" alt="List Entra Apps with High Risk API Permissions Output" width="800"/>



<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>



<hr>



<h2>🎯 Use Cases</h2>



<ul>

<li>Identify applications with excessive permissions</li>

<li>Audit API permission usage across Entra apps</li>

<li>Detect potential security risks</li>

<li>Strengthen Zero Trust security posture</li>

</ul>



<hr>



<h2>🌐 Detailed Guide</h2>



<p>

For full script, explanation, and enhancements, View Detailed Article on M365Corner 👉 :https://m365corner.com/m365-powershell/find-entra-id-applications-with-high-risk-API-permissions.html

</p>




</p>



<hr>



<h2>⚠️ Notes</h2>



<ul>

<li>Ensure required permissions are granted before execution</li>

<li>Review high-risk permissions carefully before taking action</li>

<li>Consider periodic audits for better governance</li>

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



