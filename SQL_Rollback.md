## Sample Rollback SQL
```SQL
ALTER DATABASE BaseballData
SET ENCRYPTION OFF;
GO

USE BaseballData;
DROP DATABASE ENCRYPTION KEY;
GO

USE Master;
ALTER LOGIN cakm_login
DROP CREDENTIAL cakm_db_cred;
GO

DROP LOGIN cakm_login
GO

DROP CREDENTIAL cakm_db_cred;
GO

-- The following statement works for asymmetric keys create via T-SQL
DROP ASYMMETRIC KEY cakm_key_1 REMOVE PROVIDER KEY
GO

-- An asymmetric key created at CM can only be deleted via CM access
-- The following statement unregisters the key with SQL Server
-- Use the GUI to delete the key on CM
DROP ASYMMETRIC KEY cakm_key_1
GO

ALTER LOGIN sa
DROP CREDENTIAL cakm_sa_cred;
GO

DROP CREDENTIAL cakm_sa_cred;
GO

DROP CRYPTOGRAPHIC PROVIDER cakm_provider
GO

-- Disable EKM provider
sp_configure 'EKM provider enabled', 0 ;
GO
RECONFIGURE ;
GO
sp_configure 'show advanced options', 0 ;
GO
RECONFIGURE ;
GO
```