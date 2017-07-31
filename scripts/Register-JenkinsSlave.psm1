<#
 .Synopsis
 .Description
 .Parameter Uri
 .Parameter Username
 .Parameter Password
 .Example
#>

function Register-JenkinsSlave {
    param (
        [Parameter(Mandatory=$true)]
        [Uri]$Uri,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$true)]
        [String]$Password
    )

    $auth = $Username + ":" + $Password

    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/DomainGroupOSS/jenkins/master/config/node.xml" -OutFile "C:\Jenkins\node.xml" -UseBasic
    Invoke-WebRequest -Uri "$Uri/jnlpJars/jenkins-cli.jar" -OutFile "C:\Jenkins\jenkins-cli.jar" -UseBasic

    $path = "C:\Jenkins\node.xml"
    $xml = [xml](Get-Content -Path $path)
    $xml.slave.name = "$env:ComputerName"
    $xml.slave.description = ""
    $xml.slave.remoteFS = "C:\Jenkins"
    $xml.slave.numExecutors = "1"
    $xml.slave.mode = "NORMAL"
    $xml.slave.label = "windows"
    $xml.slave.userId = "SYSTEM"
    $xml.Save($path)

    Get-Content -Path "C:\Jenkins\node.xml" | java -jar C:\Jenkins\jenkins-cli.jar -s $Uri -auth $auth create-node $env:ComputerName
}

Export-ModuleMember -Function Register-JenkinsSlave
