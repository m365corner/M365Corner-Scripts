<html>

<h1>Find Entra Apps with Service Principal Owners</h1>

<p>
This script helps administrators identify Microsoft Entra applications that have <b>Service Principal</b> owners using Microsoft Graph PowerShell.
</p>

<hr>

<h2>📌 Overview</h2>

<p>
Applications owned by Service Principals can be harder to track and govern than apps owned by individual users. Reviewing these ownership patterns is important for accountability, security, and operational transparency.
</p>

<p>This script enables you to:</p>
<ul>
<li>Identify apps that are owned by Service Principals</li>
<li>Differentiate non-human ownership from user ownership</li>
<li>Review ownership models for governance and audit purposes</li>
</ul>

<hr>

<h2>🚀 Features</h2>

<ul>
<li>Scans all Entra applications</li>
<li>Retrieves application owners</li>
<li>Filters only Service Principal owners</li>
<li>Ignores user owners automatically</li>
<li>Exports results to CSV for reporting and review</li>
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
<li><code>find-entra-apps-with-service-principal-owners.ps1</code> — PowerShell script</li>
<li><code>README.md</code> — Script overview and usage notes</li>
<li><code>demo.png</code> — Sample output image</li>
</ul>

<hr>

<h2>📊 Sample Output</h2>

<p>Below is a sample output of the script execution:</p>

<img src="demo.png" alt="Find Entra Apps With Service Principal Owners Output" width="800"/>

<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>

<hr>

<h2>🎯 Use Cases</h2>

<ul>
<li>Audit non-human ownership of Entra applications</li>
<li>Identify apps governed by Service Principals instead of users</li>
<li>Review accountability gaps in application ownership</li>
<li>Strengthen Entra application governance</li>
</ul>

<hr>

<h2>🌐 Detailed Guide</h2>

<p>
For full script, explanation, and enhancements: <br/>
View Detailed Article on M365Corner👉 https://m365corner.com/m365-powershell/find-entra-apps-with-service-principal-owners-using-powershell.html
</a>
</p>

<hr>

<h2>⚠️ Notes</h2>

<ul>
<li>The script first attempts to resolve owners as users and skips them</li>
<li>Only owners resolvable as Service Principals are included in the report</li>
<li>Useful for periodic ownership and governance reviews</li>
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
