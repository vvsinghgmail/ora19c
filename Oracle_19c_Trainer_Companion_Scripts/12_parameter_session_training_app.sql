-- WRITABLE (session only) | TRAINING_APP on ORCLPDB1.
SHOW USER
SHOW CON_NAME
SELECT name,display_value,issys_modifiable,isses_modifiable
FROM v$parameter WHERE name IN ('processes','open_cursors','optimizer_mode');
ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';
SELECT SYSDATE AS session_formatted_date FROM dual;
-- No ALTER SYSTEM operation runs in this file.
