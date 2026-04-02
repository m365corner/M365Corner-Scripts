<html>



<h1>List Entra Apps with No Assigned Roles</h1>



<p>

This script helps administrators identify Microsoft Entra applications that do not have any roles assigned using Microsoft Graph PowerShell.

</p>



<hr>



<h2>📌 Overview</h2>



<p>

Applications without assigned roles may indicate incomplete configurations or unused app registrations that require attention.

</p>



<p>This script enables you to:</p>

<ul>

<li>Identify apps without defined roles</li>

<li>Detect incomplete or unused application configurations</li>

<li>Improve application governance</li>

</ul>



<hr>



<h2>🚀 Features</h2>



<ul>

<li>Scans Entra applications for missing role assignments</li>

<li>Highlights apps with no defined roles</li>

<li>Supports cleanup and governance activities</li>

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



<img src="demo.png" alt="List Entra Apps With No Assigned Roles Output" width="800"/>



<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>



<hr>



<h2>🎯 Use Cases</h2>



<ul>

<li>Identify unused or incomplete applications</li>

<li>Clean up redundant app registrations</li>

<li>Improve Entra application governance</li>

<li>Audit application configurations</li>

</ul>



<hr>



<h2>🌐 Detailed Guide</h2>



<p>

For full script, explanation, and enhancements:

</p>



<p>

👉 <a href="https://m365corner.com/m365-powershell/list-entra-apps-with-no-assigned-roles.html" target="\_blank">

View Detailed Article on M365Corner

</a>

</p>



<hr>



<h2>⚠️ Notes</h2>



<ul>

<li>Ensure required permissions are granted before execution</li>

<li>Review applications before taking cleanup actions</li>

<li>Useful as part of periodic governance checks</li>

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



