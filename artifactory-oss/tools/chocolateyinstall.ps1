
$url = 'https://bintray.com/artifact/download/jfrog/artifactory/jfrog-artifactory-oss-4.5.1.zip'
$checksum = '3572deecb47d2ef15f0bee09f6b455d90a804ec2'
$checksumtype = 'sha1'
$validExitCodes = @(0)

$packageName= 'artifactory-oss'
$versionedfolder = 'artifactory-oss-4.5.1'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$OSBits = Get-ProcessorBits

#On 64-bit, always favor 64-bit Program Files no matter what our execution is now (works back past XP / Server 2003)
If ($env:ProgramFiles.contains('x86'))
{
  $PF = $env:ProgramFiles.replace(' (x86)','')
}
Else
{
  $PF = $env:ProgramFiles
}

$TargetFolder = "$PF\artifactory-oss"
$ExtractFolder = "$env:temp\jfrog"
$servicename = 'artifactory'

If ([bool](Get-Service $servicename -ErrorAction SilentlyContinue))
{
  Write-Warning "Nexus web app is already present, shutting it down so that we can upgrade it."
  Stop-Service $servicename -force
}

Install-ChocolateyZipPackage -PackageName $packageName -unziplocation "$ExtractFolder" -url $url -checksum $checksum -checksumtype $checksumtype -url64 $url -checksum64 $checksum -checksumtype64 $checksumtype

Copy-Item "$ExtractFolder\$versionedfolder" "$TargetFolder" -Force -Recurse
Remove-Item "$ExtractFolder\$versionedfolder" -Force -Recurse

Start-ChocolateyProcessAsAdmin "/c `"$TargetFolder\bin\installservice.bat`"" "cmd.exe" -validExitCodes $validExitCodes

Install-ChocolateyEnvironmentVariable 'ARTIFACTORY_HOME' "$TargetFolder\bin"

Start-Service $servicename

Write-Warning "`r`n"
Write-Warning "***************************************************************************"
Write-Warning "*  You can manage the repository by visiting http://localhost:8081/artifactory"
Write-Warning "*  The default user is 'admin' with password 'password'"
Write-Warning "*  Artifactory availability is controlled via the service `"$servicename`""
Write-Warning "***************************************************************************"