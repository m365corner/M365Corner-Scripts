<html>



<h1>List Entra Apps with Disabled Users</h1>



<p>

This script helps administrators identify Microsoft Entra applications that are associated with disabled user accounts using Microsoft Graph PowerShell.

</p>



<hr>



<h2>📌 Overview</h2>



<p>

Applications linked to disabled user accounts can pose security and governance risks if not reviewed regularly.

</p>



<p>This script enables you to:</p>

<ul>

<li>Identify apps owned or associated with disabled users</li>

<li>Detect stale or unmanaged application ownership</li>

<li>Improve security posture and governance</li>

</ul>



<hr>



<h2>🚀 Features</h2>



<ul>

<li>Detects applications linked to disabled user accounts</li>

<li>Helps identify orphaned or risky app ownership</li>

<li>Supports audit and cleanup activities</li>

</ul>



<hr>



<h2>🛠 Prerequisites</h2>



<ul>

<li>Microsoft Graph PowerShell module</li>

<li>Required permissions:

&#x20;   <ul>

&#x20;       <li><code>Application.Read.All</code></li>

&#x20;       <li><code>Directory.Read.All</code></li>

&#x20;       <li><code>User.Read.All</code></li>

&#x20;   </ul>

</li>

</ul>



<p>Connect using:</p>



<pre>

Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All","User.Read.All"

</pre>



<hr>



<h2>📊 Sample Output</h2>



<p>Below is a sample output of the script execution:</p>



<img src="demo.png" alt="List Entra Apps with Disabled Users Output" width="800"/>



<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>



<hr>



<h2>🎯 Use Cases</h2>



<ul>

<li>Identify applications owned by disabled users</li>

<li>Clean up stale or unmanaged app ownership</li>

<li>Strengthen security and compliance posture</li>

<li>Audit application ownership regularly</li>

</ul>



<hr>



<h2>🌐 Detailed Guide</h2>



<p>

For full script, explanation, and enhancements:

</p>



<p>

👉 <a href="https://m365corner.com/m365-powershell/list-entra-apps-with-disabled-users-using-graph-powershell.html" target="\_blank">

View Detailed Article on M365Corner

</a>

</p>



<hr>



<h2>⚠️ Notes</h2>



<ul>

<li>Ensure required permissions are granted before execution</li>

<li>Large environments may take time to process</li>

<li>Review results carefully before taking action</li>

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



