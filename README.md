# Scripts/Samples for Management of CAKM in SQL Server environment 
## Scripts
- rotateSqlKey.ps1 = Rotates the asymmetric key managed by CipherTrust Manager (CM).  Assumes the createion of a new key on CM before rotation

```
rotateSqlKey.ps1   
  -dbserver DB_SERVER_NAME            # Database Server Name  
  -dbname DB_NAME                     # Database Name  
  -sqladmin SQL_ADMIN                 # SQL Server Security Admin ID  
  [-sqlpwd SQL_PASSWORD]              # SQL Server Security Admin Password  
  -ekmname EKM_PROVIDER_NAME          # CAKM Provider Name  
  -dblogin DB_LOGIN                   # Existing database login name, not a user  
  -dbcred DB_CREDENTIAL               # Authenticating credential name secret ID/Password for communicating to CM  
  -keyname KEY_NAME                   # New key on CM  
```

- SQL_Queries.md = SQL queries to determine the existence of relevant SQL/CAKM setup