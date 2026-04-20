<html>

<h1>Find Team Member and Owner Counts</h1>

<p>
This script helps administrators retrieve Microsoft Teams along with their <b>owner count</b> and <b>member count</b> using Microsoft Graph PowerShell.
</p>

<hr>

<h2>📌 Overview</h2>

<p>
Understanding the ownership and membership distribution of Teams is critical for governance, collaboration management, and security.
</p>

<p>This script enables you to:</p>
<ul>
<li>List all Microsoft Teams in the tenant</li>
<li>Count the number of owners per Team</li>
<li>Count the number of members per Team</li>
<li>Export detailed results for reporting</li>
</ul>

<hr>

<h2>🚀 Features</h2>

<ul>
<li>Retrieves all Teams (Microsoft 365 Groups with Teams enabled)</li>
<li>Calculates owner and member counts for each Team</li>
<li>Displays owner names for quick reference</li>
<li>Exports results to CSV for analysis</li>
<li>Provides real-time console output during execution</li>
</ul>

<hr>

<h2>🛠 Prerequisites</h2>

<ul>
<li>Microsoft Graph PowerShell module</li>
<li>Required permissions:
    <ul>
        <li><code>Group.Read.All</code></li>
        <li><code>Directory.Read.All</code></li>
    </ul>
</li>
</ul>

<p>Connect using:</p>

<pre>
Connect-MgGraph -Scopes "Group.Read.All","Directory.Read.All"
</pre>

<hr>

<h2>📂 Files Included</h2>

<ul>
<li><code>find-team-member-and-owner-counts.ps1</code> — PowerShell script</li>
<li><code>README.md</code> — Script overview and usage notes</li>
<li><code>demo.png</code> — Sample output image</li>
</ul>

<hr>

<h2>📊 Sample Output</h2>

<p>Below is a sample output of the script execution:</p>

<img src="demo.png" alt="Find Team Member and Owner Counts Output" width="800"/>

<hr>

<h2>🎯 Use Cases</h2>

<ul>
<li>Audit Team ownership distribution</li>
<li>Identify Teams with too few or too many owners</li>
<li>Monitor membership size across Teams</li>
<li>Support governance and reporting requirements</li>
</ul>

<hr>

<h2>⚠️ Governance Insights</h2>

<ul>
<li>Teams should have at least <b>2 owners</b> to avoid dependency risks</li>
<li>Very large Teams may require additional governance controls</li>
<li>Ownership imbalance can indicate governance gaps</li>
</ul>

<hr>

<h2>⚠️ Notes</h2>

<ul>
<li>The script filters only Teams-enabled groups</li>
<li>Owner names are retrieved from directory properties</li>
<li>Export path should be updated based on your environment</li>
</ul>

<hr>

🌐 Detailed Guide
For full script, explanation, and enhancements:
View Detailed Article on M365Corner👉 https://m365corner.com/m365-powershell/find-teams-member-and-owner-counts.html

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
