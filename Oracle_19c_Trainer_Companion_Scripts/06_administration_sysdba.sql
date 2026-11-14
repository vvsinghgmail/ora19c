-- READ-ONLY. SQL*Plus as SYSDBA, ORCLPDB1 if looking at local users.
SET LINESIZE 160 PAGESIZE 100
SHOW CON_NAME
SELECT username,account_status,default_tablespace FROM dba_users
WHERE username IN ('APP_USER','REPORT_USER','TRAINING_APP') ORDER BY username;
SELECT owner,table_name FROM dba_tables WHERE owner='TRAINING_APP';
SELECT tablespace_name,file_name,ROUND(bytes/1024/1024) mb,autoextensible
FROM dba_data_files ORDER BY tablespace_name,file_name;
SELECT sid,serial#,username,status,event,blocking_session FROM v$session
WHERE username IS NOT NULL ORDER BY username,sid;
SELECT name,display_value,issys_modifiable,isses_modifiable,ispdb_modifiable
FROM v$parameter WHERE name IN ('processes','open_cursors','optimizer_mode','db_block_size');
SELECT name,value FROM v$diag_info WHERE name IN ('Diag Trace','Diag Alert');
