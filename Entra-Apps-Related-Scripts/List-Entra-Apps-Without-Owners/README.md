<html>

<h1>List Entra Apps Without Owners</h1>

<p>
This script helps administrators identify Microsoft Entra applications that do not have any assigned owners using Microsoft Graph PowerShell.
</p>

<hr>

<h2>📌 Overview</h2>

<p>
Applications without owners pose a significant governance and security risk, as there is no accountability for their management.
</p>

<p>This script enables you to:</p>
<ul>
<li>Identify orphaned Entra applications</li>
<li>Detect ownership gaps</li>
<li>Improve governance and accountability</li>
</ul>

<hr>

<h2>🚀 Features</h2>

<ul>
<li>Scans all Entra applications for missing owners</li>
<li>Highlights orphaned applications</li>
<li>Supports audit and governance activities</li>
</ul>

<hr>

<h2>🛠 Prerequisites</h2>

<ul>
<li>Microsoft Graph PowerShell module</li>
<li>Required permissions:
    <ul>
        <li><code>Application.Read.All</code></li>
        <li><code>Directory.Read.All</code></li>
    </ul>
</li>
</ul>

<p>Connect using:</p>

<pre>
Connect-MgGraph -Scopes "Application.Read.All","Directory.Read.All"
</pre>

<hr>

<h2>📊 Sample Output</h2>

<p>Below is a sample output of the script execution:</p>

<img src="demo.png" alt="List Entra Apps Without Owners Output" width="800"/>

<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>

<hr>

<h2>🎯 Use Cases</h2>

<ul>
<li>Identify orphaned applications</li>
<li>Assign ownership to unmanaged apps</li>
<li>Improve governance and compliance</li>
<li>Reduce security risks associated with unmanaged resources</li>
</ul>

<hr>

<h2>🌐 Detailed Guide</h2>

<p>
For full script, explanation, and enhancements:
</p>

<p>
👉 <a href="https://m365corner.com/m365-powershell/find-entra-id-applications-without-owners-using-powershell.html" target="_blank">
View Detailed Article on M365Corner
</a>
</p>

<hr>

<h2>⚠️ Notes</h2>

<ul>
<li>Ensure required permissions are granted before execution</li>
<li>Review results before assigning owners</li>
<li>Useful for periodic governance reviews</li>
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
👉 <a href="https://m365corner.com" target="_blank">https://m365corner.com</a>
</p>

</html>
