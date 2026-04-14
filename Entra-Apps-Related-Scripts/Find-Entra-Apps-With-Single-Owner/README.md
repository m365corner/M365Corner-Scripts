<html>

<h1>Find Entra Apps with Single Owner</h1>

<p>
This script helps administrators identify Microsoft Entra applications that have exactly one assigned owner using Microsoft Graph PowerShell.
</p>

<hr>

<h2>📌 Overview</h2>

<p>
Applications with a single owner can pose operational risks if that individual becomes unavailable, potentially impacting application management and support.
</p>

<p>This script enables you to:</p>
<ul>
<li>Identify apps with only one owner</li>
<li>Detect potential ownership risks</li>
<li>Improve resilience and governance</li>
</ul>

<hr>

<h2>🚀 Features</h2>

<ul>
<li>Scans all Entra applications</li>
<li>Identifies apps with exactly one owner</li>
<li>Retrieves detailed owner information (Name, UPN, ID)</li>
<li>Handles both user and non-user owner objects</li>
<li>Exports results to CSV for reporting</li>
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

<h2>📂 Files Included</h2>

<ul>
<li><code>find-entra-apps-with-single-owner.ps1</code> — PowerShell script</li>
<li><code>README.md</code> — Script overview and usage notes</li>
<li><code>demo.png</code> — Sample output image</li>
</ul>

<hr>

<h2>📊 Sample Output</h2>

<p>Below is a sample output of the script execution:</p>

<img src="demo.png" alt="Find Entra Apps With Single Owner Output" width="800"/>

<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>

<hr>

<h2>🎯 Use Cases</h2>

<ul>
<li>Identify applications with ownership risk</li>
<li>Ensure backup ownership for critical apps</li>
<li>Improve application resilience</li>
<li>Strengthen governance and accountability</li>
</ul>

<h2>🌐 Detailed Guide</h2>

<p>
For full script, explanation, and enhancements: <br/>
View Detailed Article on M365Corner👉 https://m365corner.com/m365-powershell/find-entra-apps-with-single-owner-using-powershell.html
</a>
</p>

<hr>

<hr>

<h2>⚠️ Notes</h2>

<ul>
<li>Single-owner apps may create operational dependency risks</li>
<li>Consider assigning additional owners for critical applications</li>
<li>Script handles both user and service principal ownership scenarios</li>
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
