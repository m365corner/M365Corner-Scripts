<html>

<h1>List Custom Entra Apps with High-Risk Permissions</h1>

<p>
This script helps administrators identify custom (non-template) Microsoft Entra applications that have high-risk API permissions using Microsoft Graph PowerShell.
</p>

<hr>

<h2>📌 Overview</h2>

<p>
Custom applications with high-risk permissions can pose serious security threats if not monitored properly.
</p>

<p>This script enables you to:</p>
<ul>
<li>Identify custom Entra apps with elevated permissions</li>
<li>Detect potential security risks</li>
<li>Audit permission usage across custom applications</li>
</ul>

<hr>

<h2>🚀 Features</h2>

<ul>
<li>Filters only custom (non-template) applications</li>
<li>Detects high-risk API permissions</li>
<li>Maps permission IDs to readable permission names</li>
<li>Exports results to CSV for analysis</li>
<li>Highlights high-risk apps in console output</li>
</ul>

<hr>

<h2>🛠 Prerequisites</h2>

<ul>
<li>Microsoft Graph PowerShell module</li>
<li>Required permission:
    <ul>
        <li><code>Application.Read.All</code></li>
    </ul>
</li>
</ul>

<p>Connect using:</p>

<pre>
Connect-MgGraph -Scopes "Application.Read.All"
</pre>

<hr>

<h2>📂 Files Included</h2>

<ul>
<li><code>list-custom-entra-apps-with-high-risk-permissions.ps1</code> — PowerShell script</li>
<li><code>README.md</code> — Script overview and usage notes</li>
<li><code>demo.png</code> — Sample output image</li>
</ul>

<hr>

<h2>📊 Sample Output</h2>

<p>Below is a sample output of the script execution:</p>

<img src="demo.png" alt="List Custom Entra Apps with High Risk Permissions Output" width="800"/>

<p><em>📌 The image above is sourced from the original M365Corner article.</em></p>

<hr>

<h2>🎯 Use Cases</h2>

<ul>
<li>Identify high-risk custom applications</li>
<li>Audit permission usage across Entra apps</li>
<li>Detect potential security vulnerabilities</li>
<li>Strengthen Zero Trust security posture</li>
</ul>

<hr>

<h2>⚠️ Notes</h2>

<ul>
<li>The script evaluates permissions against a predefined high-risk list</li>
<li>Permission resolution requires querying service principals</li>
<li>Review results carefully before taking action</li>
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
👉 <a href="https://m365corner.com" target="_blank">https://m365corner.com</a>
</p>

</html>
