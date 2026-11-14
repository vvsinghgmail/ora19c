-- WRITABLE | TRAINER ONLY | ISOLATED ORCLPDB1. Do NOT execute on customer production.
-- Connect to CDB$ROOT as SYSDBA and verify the container before running.
SET ECHO OFF VERIFY OFF
SHOW USER
SHOW CON_NAME
ALTER SESSION SET CONTAINER=ORCLPDB1;
SHOW CON_NAME
SELECT tablespace_name,contents,status FROM dba_tablespaces ORDER BY tablespace_name;
-- Replace the password and USERS tablespace selection after explicit trainer review.
-- Uncomment ONE-TIME statements below on an approved disposable lab copy.
-- CREATE USER TRAINING_APP IDENTIFIED BY "REPLACE_WITH_LAB_SECRET"
--    DEFAULT TABLESPACE USERS QUOTA 100M ON USERS;
-- GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO TRAINING_APP;
-- Confirm: SELECT username,account_status,default_tablespace FROM dba_users WHERE username='TRAINING_APP';
-- Do NOT create TRAINING_APP in CDB$ROOT: local users belong to a PDB.
-- Account setup is deliberately commented: instructor authorizes before enabling.
