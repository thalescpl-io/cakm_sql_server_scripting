## Query Status
Query encryption status and asymmtric key in use for databases
```SQL
    Use Master;
    SELECT DB_NAME(e.database_id) AS DatabaseName, e.database_id, e.encryption_state,
    CASE e.encryption_state
      WHEN 0 THEN 'No database encryption key present, no encryption'
      WHEN 1 THEN 'Unencrypted'
      WHEN 2 THEN 'Encryption in progress'
      WHEN 3 THEN 'Encrypted'
      WHEN 4 THEN 'Key change in progress'
      WHEN 5 THEN 'Decryption in progress'
    END AS encryption_state_desc, c.name AS asym_key_name, e.percent_complete
    FROM sys.dm_database_encryption_keys AS e
    LEFT JOIN master.sys.asymmetric_keys AS c
    ON e.encryptor_thumbprint = c.thumbprint;
	GO
```

Query known database asymmetric keys for CAKM EKM provider
```SQL
Use Master;
SELECT
	AK.name,
	AK.algorithm,
	AK.key_length
FROM
  sys.asymmetric_keys as AK
JOIN sys.cryptographic_providers as CP on AK.cryptographic_provider_guid = CP.guid
WHERE CP.name = 'cakm_provider';
```

Query credential information for CAKM EKM provider
```SQL
Use Master;
SELECT 
  C.credential_id, 
  C.name, 
  C.credential_identity, 
  C.target_type, 
  C.target_id 
FROM 
  sys.credentials as C
JOIN sys.cryptographic_providers as CP on C.target_id = CP.provider_id
WHERE CP.name = 'cakm_provider'
```

Query login information for CAKM EKM provider
```SQL
Use Master;
SELECT 
  CP.name CRYPTO_NAME, 
  SP.name LOGIN_NAME,  
  SP.type_desc TYPE, 
  C.name CRED_NAME 
FROM 
  sys.server_principals as SP
JOIN sys.server_principal_credentials as SPC ON SP.principal_id = SPC.principal_id
JOIN sys.credentials as C ON SPC.credential_id = C.credential_id
JOIN sys.cryptographic_providers CP ON C.target_id = CP.provider_id
WHERE CP.name = 'cakm_provider';
GO
```

Query Asymmetric key information for CAKM EKM provider
```SQL
Use Master;
SELECT 
	c.name KEY_NAME, 
	p.name PROVIDER_NAME, 
	c.algorithm_desc DESCRIPTION, 
	c.key_length LENGTH
FROM 
	master.sys.asymmetric_keys AS c
LEFT JOIN master.sys.cryptographic_providers as p
ON c.cryptographic_provider_guid = p.guid
AND p.name = 'cakm_provider';
GO
```