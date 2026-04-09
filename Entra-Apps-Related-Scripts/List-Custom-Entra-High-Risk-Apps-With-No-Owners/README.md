<html>

<h1>List Custom Entra High-Risk Apps with No Owners</h1>

<p>
This script helps administrators identify <b>custom (non-template) Microsoft Entra applications</b> that have <b>high-risk API permissions</b> and <b>no assigned owners</b> using Microsoft Graph PowerShell.
</p>

<hr>

<h2>📌 Overview</h2>

<p>
Applications that combine <b>high-risk permissions</b> with <b>no ownership</b> represent one of the most critical security risks in an Entra environment.
</p>

<p>This script enables you to:</p>
<ul>
<li>Identify high-risk custom applications with no accountability</li>
<li>Detect potential security vulnerabilities</li>
<li>Prioritize remediation of critical app risks</li>
</ul>

<hr>

<h2>🚀 Features</h2>

<ul>
<li>Filters only custom (non-template) applications</li>
<li>Identifies apps with no assigned owners</li>
<li>Detects high-risk API permissions</li>
<li>Maps permission IDs to readable permission names</li>
<li>Exports results to CSV for reporting</li>
<li>Highlights critical apps in console output</li>
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
<li><code>list-custom-entra-high-risk-apps-with-no-owners.ps1</code> — PowerShell script</li>
<li><code>README.md</code> — Script overview and usage notes</li>
<li><code>demo.png</code> — Sample output image</li>
</ul>

<hr>

<h2>📊 Sample Output</h2>

<p>Below is a sample output of the script execution:</p>

<img src="demo.png" alt="List Custom Entra High Risk Apps With No Owners Output" width="800"/>

<hr>

<h2>🎯 Use Cases</h2>

<ul>
<li>Identify critical-risk Entra applications</li>
<li>Detect orphaned apps with elevated permissions</li>
<li>Prioritize remediation of high-risk scenarios</li>
<li>Strengthen Zero Trust security posture</li>
<li>Support security audits and incident investigations</li>
</ul>

<hr>

<h2>⚠️ Risk Classification</h2>

<p>
Applications identified by this script are categorized as:
</p>

<ul>
<li><b>Custom App</b> → Not governed by templates</li>
<li><b>No Owner</b> → No accountability</li>
<li><b>High-Risk Permissions</b> → Elevated access</li>
</ul>

<p>
👉 Combined risk level: <b>Critical</b>
</p>

<hr>

<h2>⚠️ Notes</h2>

<ul>
<li>The script evaluates permissions against a predefined high-risk list</li>
<li>Permission resolution requires querying service principals</li>
<li>Review results carefully before taking action</li>
<li>Immediate remediation is recommended for critical findings</li>
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
