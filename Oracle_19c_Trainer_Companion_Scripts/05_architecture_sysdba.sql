-- READ-ONLY. SQL*Plus as SYSDBA in CDB$ROOT.
SET LINESIZE 180 PAGESIZE 120
SHOW SGA
SELECT name,ROUND(value/1024/1024,1) mb FROM v$pgastat
WHERE name IN ('total PGA allocated','aggregate PGA target parameter');
SELECT component,ROUND(current_size/1024/1024,1) mb FROM v$sga_dynamic_components
WHERE current_size > 0 ORDER BY mb DESC;
SELECT pname,program FROM v$process WHERE pname IS NOT NULL ORDER BY pname;
SELECT file#,name FROM v$datafile ORDER BY file#;
SELECT name FROM v$controlfile;
SELECT group#,sequence#,status FROM v$log ORDER BY group#;
SELECT member FROM v$logfile;
SELECT tablespace_name,contents,status FROM dba_tablespaces ORDER BY 1;
SHOW PARAMETER spfile
SHOW PARAMETER db_block_size
