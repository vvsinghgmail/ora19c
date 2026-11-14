-- READ-ONLY. Run from SQL*Plus as local SYSDBA connected to CDB$ROOT.
SET PAGESIZE 100 LINESIZE 160
SHOW USER
SHOW CON_NAME
SELECT name,dbid,open_mode,log_mode,cdb FROM v$database;
SELECT instance_name,host_name,status,database_status,startup_time FROM v$instance;
SHOW PDBS
SELECT con_id,name,open_mode FROM v$pdbs ORDER BY con_id;
SELECT name,value FROM v$diag_info WHERE name IN ('Diag Trace','Diag Alert');
SELECT banner_full FROM v$version WHERE ROWNUM=1;
SELECT patch_id,action,status,action_time FROM dba_registry_sqlpatch ORDER BY action_time DESC;
