<#
 .Synopsis
 .Description
 .Parameter Uri
 .Parameter Username
 .Parameter Password
 .Example
#>

function Start-JenkinsSlave {
    param (
        [Parameter(Mandatory=$true)]
        [Uri]$Uri,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$true)]
        [String]$Password
    )

    $credentials = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
    $crumbs = Invoke-RestMethod -Method "GET" -Headers @{ "Authorization" = "Basic $credentials" } -Uri "$Uri/crumbIssuer/api/xml" -UseBasic
    $headers = @{}
    $headers.Add("Authorization", "Basic $credentials")
    $headers.Add($crumbs.defaultCrumbIssuer.crumbRequestField, $crumbs.defaultCrumbIssuer.crumb)
    $secret = (Invoke-RestMethod -Method "POST" -Headers $headers -Uri "$Uri/scriptText" -Body "script=for (aSlave in hudson.model.Hudson.instance.slaves) { if (aSlave.name == `"$env:ComputerName`") { println aSlave.getComputer().getJnlpMac() } }").Trim()

    Invoke-WebRequest -Uri "$Uri/jnlpJars/slave.jar" -OutFile "C:\Jenkins\slave.jar" -UseBasic

    Start-Process -FilePath "java" -ArgumentList "-jar C:\Jenkins\slave.jar -jnlpUrl $Uri/computer/$env:ComputerName/slave-agent.jnlp -secret $secret"
}

Export-ModuleMember -Function Start-JenkinsSlave
