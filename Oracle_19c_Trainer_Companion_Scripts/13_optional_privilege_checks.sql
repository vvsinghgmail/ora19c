-- READ-ONLY | SYSDBA in ORCLPDB1.
SHOW CON_NAME
SELECT username,account_status,default_tablespace FROM dba_users
WHERE username='TRAINING_APP';
SELECT grantee,privilege FROM dba_sys_privs
WHERE grantee='TRAINING_APP' ORDER BY privilege;
SELECT username,tablespace_name,bytes,max_bytes FROM dba_ts_quotas
WHERE username='TRAINING_APP';
SELECT owner,table_name FROM dba_tables WHERE owner='TRAINING_APP';
