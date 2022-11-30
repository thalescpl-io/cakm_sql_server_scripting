# Gather input and set variables
param (
  [Parameter(Mandatory=$true)][string]$dbserver="DB_SERVER_NAME",           # Database Server Name
  [Parameter(Mandatory=$true)][string]$dbname="DB_NAME",                    # Database Name
  [Parameter(Mandatory=$true)][string]$sqladmin="SQL_ADMIN",                # SQL Server Security Admin ID
  [Parameter(Mandatory=$false)][string]$sqlpwd="SQL_PASSWORD",              # SQL Server Security Admin Password
  [Parameter(Mandatory=$true)][string]$ekmname="EKM_PROVIDER_NAME",         # CAKM Provider Name
  [Parameter(Mandatory=$true)][string]$dblogin="DB_LOGIN",                  # Existing database login name, not a user
  [Parameter(Mandatory=$true)][string]$dbcred="DB_CREDENTIAL",              # Authenticating credential name, secret ID/Password for communicating to CM
  [Parameter(Mandatory=$true)][string]$keyname="KEY_NAME"                   # New key on CM
)

$newlogin = 'login_' + $keyname

#Invoke-Sqlcmd does not accept encrypted password strings.   I use the following clause to simply prompt and hide the password at the command if the password is omitted.
#This prevents "over the shoulder" access to the password.  However, you can avoid the prompt for a password by including it as a command argument.

if ($sqlpwd -eq 'SQL_PASSWORD'){
  $secureSqlPwd = Read-Host "Enter SQL Admin password" -AsSecureString
  $sqlpwd =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSqlPwd))
} 


$syntax = './rotateSqlKey -dbserver DB_SERVER_NAME -dbname DB_NAME -sqladmin SQL_ADMIN [-sqlpwd SQL_PASSWORD] -ekmname EKM_PROVIDER_NAME -dblogin DB_LOGIN -dbcred DB_CREDENTIAL -keyname KEY_NAME'

Write-Host $syntax


### Load Necessary
# Install necessary SqlServer Module
if (Get-Module -ListAvailable -Name SqlServer) {
} 
else {
  Write-Host "Attempting to install SqlServer Module"
  Install-Module SqlServer -AllowClobber
}


#1 Create Asymmetric key 
$StringArray = "keyname=$keyname", "ekmname=$ekmname"

$Query = "
Use Master;
CREATE ASYMMETRIC KEY `$(keyname)
FROM PROVIDER `$(ekmname)
WITH
  CREATION_DISPOSITION = OPEN_EXISTING,
  PROVIDER_KEY_NAME = '`$(keyname)';
"

Invoke-Sqlcmd  -ConnectionString "Data Source='$dbserver'; User Id='$sqladmin'; Password ='$sqlpwd'" -Query "$Query" -Variable $StringArray

#2 Create New Login from New key
$StringArray =  "newlogin=$newlogin", "keyname=$keyname"

$Query = "
Use Master;
CREATE LOGIN `$(newlogin)
FROM ASYMMETRIC KEY `$(keyname) ;
"

Invoke-Sqlcmd  -ConnectionString "Data Source='$dbserver'; User Id='$sqladmin'; Password ='$sqlpwd'" -Query "$Query" -Variable $StringArray

#3 Alter DB login drop credential
$StringArray =  "dblogin=$dblogin", "dbcred=$dbcred"

$Query = "
Use Master;
ALTER LOGIN `$(dblogin) 
DROP CREDENTIAL `$(dbcred);
"

Invoke-Sqlcmd  -ConnectionString "Data Source='$dbserver'; User Id='$sqladmin'; Password ='$sqlpwd'" -Query "$Query" -Variable $StringArray

#4 Drop DB login
$StringArray =  "dblogin=$dblogin"

$Query = "
Use Master;
DROP LOGIN `$(dblogin);
"

#5 Alter new login add credential
$StringArray =  "newlogin=$newlogin", "dbcred=$dbcred"

$Query = "
Use Master;
ALTER LOGIN `$(newlogin) 
ADD CREDENTIAL `$(dbcred);
"

Invoke-Sqlcmd  -ConnectionString "Data Source='$dbserver'; User Id='$sqladmin'; Password ='$sqlpwd'" -Query "$Query" -Variable $StringArray

#6 Alter database with new asymmetric key 

$StringArray = "dbname=$dbname", "keyname=$keyname"

$Query = "
Use `$(dbname);
ALTER DATABASE ENCRYPTION KEY
ENCRYPTION BY SERVER
ASYMMETRIC KEY `$(keyname);
"

# sql authentication without database name
Invoke-Sqlcmd  -ConnectionString "Data Source='$dbserver'; User Id='$sqladmin'; Password ='$sqlpwd'" -Query "$Query" -Variable $StringArray



