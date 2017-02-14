param([string]$username, [string]$password)

function GrantLogonAsSerivce {
  <#
    .synopsis
      Grants logon as a service right to user
    .parameter username
      username that can logon as service
  #>
  param([string]$username)
  # Grant logon as a service right
  $tempPath = [System.IO.Path]::GetTempPath()
  $import = Join-Path -Path $tempPath -ChildPath "import.inf"
  if(Test-Path $import) { Remove-Item -Path $import -Force }
  $export = Join-Path -Path $tempPath -ChildPath "export.inf"
  if(Test-Path $export) { Remove-Item -Path $export -Force }
  $secedt = Join-Path -Path $tempPath -ChildPath "secedt.sdb"
  if(Test-Path $secedt) { Remove-Item -Path $secedt -Force }
  try {
    Write-Host ("Granting SeServiceLogonRight to user account: {0}." -f $username)
    $sid = ((New-Object System.Security.Principal.NTAccount($username)).Translate([System.Security.Principal.SecurityIdentifier])).Value
    secedit /export /cfg $export
    $sids = (Select-String $export -Pattern "SeServiceLogonRight").Line
    foreach ($line in @("[Unicode]", "Unicode=yes", "[System Access]", "[Event Audit]", "[Registry Values]", "[Version]", "signature=`"`$CHICAGO$`"", "Revision=1", "[Profile Description]", "Description=GrantLogOnAsAService security template", "[Privilege Rights]", "SeServiceLogonRight = *$sids,*$sid")){
      Add-Content $import $line
    }
    secedit /import /db $secedt /cfg $import
    secedit /configure /db $secedt
    gpupdate /force
    Remove-Item -Path $import -Force
    Remove-Item -Path $export -Force
    Remove-Item -Path $secedt -Force
  }
  catch {
    Write-Host ("Failed to grant SeServiceLogonRight to user account: {0}" -f $username)
    $error[0]
  }
}

GrantLogonAsSerivce -username $username

$cred_user = ".\$username"
$params = @{
  "Namespace" = "root\CIMV2"
  "Class" = "Win32_Service"
  "Filter" = "Name='salt-minion'"
}
$service = Get-WmiObject @params
$service.Change($null,$null,$null,$null,$null,$null,$cred_user,$password)