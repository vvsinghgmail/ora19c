**TOPIC-ALIGNED \| ALL 81 SUB-TOPICS \| WINDOWS SERVER**

Five-Day Oracle Database Training --- Instructor Edition

Aligned to the uploaded Oracle-5Day-Training-Topics(1).xlsx, preserving
the original topic and serial-number structure. Includes controlled
hands-on, micro-demonstrations, expected outcomes and teaching
commentary.

**Training target:** Oracle Database 19c Enterprise Edition, Windows
Server, ORCLCDB with ORCLPDB1; scripts assume a dedicated TRAINING_APP
schema prepared by the trainer.

**Version:** 1.0 \| 12 November 2026 \| No customer database
modifications performed to produce this manual.

**Operating rule:** Items marked read-only can be inspected on the
agreed server. Writable tasks must run only in an isolated training
schema or clone, with authorization. Recovery, service lifecycle and
patching activities are instructor-controlled and require
snapshots/rollback.

# How to run this course

## 1. Coverage and sequencing

**Source alignment:** 14 main topics and 81 individually mapped
sub-topics. Original day labels are retained; a feasible timeboxed
timetable is proposed below because the source sheet does not assign
per-session durations.

  **Day**   **Teaching allocation (8 h)**                            **Practical emphasis**
  --------- -------------------------------------------------------- -----------------------------------------------------
  1                                                                  
            Topic 1 (5h), Topic 2 first half (3h)                    
                                                                     SQL basics, transactions, relational integrity
  2                                                                  
            Topic 2 remainder (1h), Topics 3--6 (1h), Topic 7 (6h)   
                                                                     SGA/PGA, processes, CDB/PDB, physical files
  3                                                                  
            Topic 8 (5h), Topic 9 (1h), Topic 10 (2h)                
                                                                     Windows/SQL\*Plus read-only DBA, upgrade planning
  4                                                                  
            Topics 11--12 (7h), review (1h)                          
                                                                     Spatial data, geometry, metadata and indexing
  5                                                                  
            Topic 13 (2h), Topic 14 (4h), capstone (2h)              
                                                                     Online session settings, RMAN backup and validation

**Scheduling note:** The workbook covers every source item, but 81
independent, lengthy labs will not fit in 40 hours. Core code exercises
are batched and repeated sub-topics are taught through the same guided
workflow; discussion exercises are 3--8 minutes and advanced operations
are instructor-led.

## 2. Safety labels and permissions

  **Label**   **Meaning**                                               **Default environment**
  ----------- --------------------------------------------------------- ------------------------------------
  RO                                                                    
              Read-only SQL or OS inspection                            
                                                                        Existing client 19c or lab VM
  WRITE                                                                 
              Controlled DDL/DML in sandbox TRAINING_APP                
                                                                        Disposable PDB/VM; not production
  MIX                                                                   
              Combination of SQL observation and worksheet              
                                                                        Approved lab
  INSTR                                                                 
              Instructor-controlled operation or recoverability check   
                                                                        Isolated VM/clone, approved backup
  DISC                                                                  
              Conceptual exercise; no full single-node implementation   
                                                                        Whiteboard / worksheet

## 3. Lab prerequisites

-   Windows Server with a supported Oracle Database 19c Enterprise
    Edition installation and corresponding Release Update. Use a
    disposable lab copy whenever possible.

-   Instance ORCLCDB, PDB ORCLPDB1, listener TCP/1521 unless site
    configuration differs; previous example Oracle Home was
    C:\\app\\oracle\\product\\19.0.0\\dbhome_1; discover the actual
    installation path rather than assuming it.

-   SQL\*Plus, RMAN, optional Oracle SQL Developer, PowerShell and the
    approved Oracle Home utilities.

-   Appropriate OSDBA SYSDBA connectivity for privileged inspection;
    trainer-provisioned local TRAINING_APP for all writable labs.

-   Separate D:\\OracleLabs\\Backups (or another approved training disk)
    with sufficient capacity. D: is illustrative and may not exist.

-   One clean VM snapshot, verified baseline backup and a second
    disposable recovery copy for all destructive or service-impacting
    lessons.

-   Spatial registration shows VALID in DBA_REGISTRY, and appropriate
    USER_SDO_GEOM_METADATA privileges available in the lab.

-   Individual participant credentials must never be placed in logs,
    screenshots or reusable scripts. Use interactive password prompts.

## 4. First 15 minutes: preflight

**Step 1 --- Windows PowerShell (read-only):** List Oracle services and
validate the listener TCP port. Service names vary by Oracle Home.

  -----------------------------------------------------------------------------------------
  Get-Service \| Where-Object { \$\_.Name -match \'Oracle\|TNS\' } \| Select Name,Status\
  Test-NetConnection 127.0.0.1 -Port 1521

  -----------------------------------------------------------------------------------------

**Step 2 --- Connect as SYSDBA (local OSDBA user):** Use SQL\*Plus from
Windows Command Prompt or PowerShell.

  -----------------------------------------------------
  sqlplus / as sysdba\
  SHOW USER\
  SHOW CON_NAME\
  SELECT name, open_mode, log_mode FROM v\$database;\
  SHOW PDBS\
  EXIT

  -----------------------------------------------------

**Step 3 --- Connect as training schema owner:** Use Easy Connect and
let SQL\*Plus prompt for credentials; no wallet or TNS alias is required
for the example.

  ---------------------------------------------------------
  sqlplus TRAINING_APP@//127.0.0.1:1521/orclpdb1\
  SHOW USER\
  SHOW CON_NAME\
  SELECT table_name FROM user_tables ORDER BY table_name;

  ---------------------------------------------------------

**Expected:** SYSDBA sees CDB\$ROOT; TRAINING_APP connects to ORCLPDB1;
the sample schema is visible. If ORA-12154 occurs, use Easy Connect; if
ORA-01031 occurs, inspect grants and quota. Do not interpret ORA-12154
as a password-idle issue.

## 5. Instructor setup in the isolated PDB

**Important:** The CREATE USER and GRANT commands below are preparatory,
not participant assignments on the customer server. Run as a privileged
local administrator connected to ORCLPDB1 after confirming quota/storage
and security approval.

  -----------------------------------------------------------------------------------
  \-- SQL\*Plus as SYSDBA\
  ALTER SESSION SET CONTAINER=ORCLPDB1;\
  SELECT tablespace_name FROM dba_tablespaces WHERE contents=\'PERMANENT\';\
  \-- Choose the approved permanent tablespace; USERS is illustrative.\
  CREATE USER TRAINING_APP IDENTIFIED BY \"REPLACE_WITH_STRONG_LAB_SECRET\"\
  DEFAULT TABLESPACE USERS QUOTA 100M ON USERS;\
  GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO TRAINING_APP;

  -----------------------------------------------------------------------------------

**Instructor note:** The table owner may create indexes on its own
tables after appropriate CREATE TABLE privilege and tablespace quota. No
generic CREATE INDEX system privilege is required for that operation.

**Known earlier lab issue:** An IDENTITY column may require CREATE
SEQUENCE permission for TRAINING_APP; CREATE TABLE privilege alone does
not guarantee the exercise works. A missing tablespace quota can also
cause ORA-01950. The accompanying setup script provides a corrected set
of grants.

# Topic-by-topic practical exercise catalogue

**Execution guidance:** Each SR\# maps exactly to one sub-topic in the
uploaded sheet. For conceptual items, the hands-on exercise is a
worksheet/observation because a real cross-version/HA execution requires
additional resources.

# 1. Introduction to Databases and RDBMS

**Days 1-2 \| Foundations:** This block introduces foundational RDBMS
principles before participants execute DML on TRAINING_APP. Use pairs
for two-session concurrency.

## 01 \| What is a database?

*Execution: Read-only*

**Learning outcome:** Identify what constitutes a database.

**Trainer procedure:** Open SQL\*Plus and locate the database and
current container; contrast a database with one table.

  -------------------------------------------
  SELECT name, open_mode FROM v\$database;\
  SHOW CON_NAME

  -------------------------------------------

**Expected result / evidence:** The database name is ORCLCDB and the
current container is displayed.

**Explanation to give participants:** An Oracle database is an organized
set of persistent files; a table is only one database object. Run as
SYSDBA for V\$ access.

## 02 \| Evolution of data storage and database management systems

*Execution: Observation / discussion*

**Learning outcome:** Contrast file-based storage with managed database
storage.

**Trainer procedure:** Show an example CSV row, then retrieve the same
logical record through SQL.

  ----------------------------------------------------------------------
  \-- CSV example (worksheet): 101,Asha,Delhi\
  SELECT customer_id, customer_name, city FROM training_app.customers;

  ----------------------------------------------------------------------

**Expected result / evidence:** SQL returns typed rows and enforces
rules that an unmanaged CSV cannot enforce.

**Explanation to give participants:** Discuss indexes, concurrency,
constraints, recovery, and centralized authorization; CSV is a
discussion aid, not an Oracle feature.

## 03 \| File-based systems versus database systems

*Execution: Writable lab*

**Learning outcome:** Compare update anomalies in files and databases.

**Trainer procedure:** Write a hypothetical CSV update for one customer
used in several files; run a single-table update in the sandbox.

  -------------------------------------------------------------------------
  UPDATE training_app.customers SET city=\'Pune\' WHERE customer_id=101;\
  ROLLBACK;

  -------------------------------------------------------------------------

**Expected result / evidence:** Uncommitted change is rolled back;
original city remains.

**Explanation to give participants:** Point out transactions, duplicate
records, and multiple-user access. Do not use customer production data.

## 04 \| Introduction to DBMS and RDBMS

*Execution: Read-only*

**Learning outcome:** Distinguish DBMS from RDBMS.

**Trainer procedure:** Inspect Oracle version and demonstrate SQL access
to relational objects.

  -------------------------------------------------------------------------------------
  SELECT banner_full FROM v\$version WHERE ROWNUM = 1;\
  SELECT table_name FROM dba_tables WHERE owner=\'TRAINING_APP\' ORDER BY table_name;

  -------------------------------------------------------------------------------------

**Expected result / evidence:** Oracle version and application tables
appear.

**Explanation to give participants:** DBMS manages persistence and
access; RDBMS implements relational tables, keys, integrity and SQL.

## 05 \| Relational database concepts

*Execution: Read-only*

**Learning outcome:** Explain relations, domains and tuples.

**Trainer procedure:** Inspect columns and types on a sample table.

  ---------------------------------------------------------------------------------
  SELECT column_name, data_type, nullable\
  FROM dba_tab_columns WHERE owner=\'TRAINING_APP\' AND table_name=\'CUSTOMERS\'\
  ORDER BY column_id;

  ---------------------------------------------------------------------------------

**Expected result / evidence:** Column definitions show the implemented
relational schema.

**Explanation to give participants:** Explain that a relation is
represented by a table; a row is a tuple; a column has a domain/type.

## 06 \| Tables, rows, columns and records

*Execution: Writable lab*

**Learning outcome:** Create and query rows and columns.

**Trainer procedure:** Connect as TRAINING_APP and query selected
columns with a filter.

  ---------------------------------------------------------------
  SELECT customer_id, customer_name\
  FROM customers WHERE city=\'Bengaluru\' ORDER BY customer_id;

  ---------------------------------------------------------------

**Expected result / evidence:** Only matching customer rows and
requested columns appear.

**Explanation to give participants:** Demonstrate SELECT projection,
WHERE selection, and ORDER BY; never assume row order without ORDER BY.

## 07 \| Primary keys and foreign keys

*Execution: Writable lab*

**Learning outcome:** Demonstrate PK and FK integrity.

**Trainer procedure:** Inspect constraints and try inserting an order
referring to a missing customer; rollback after expected error.

  ---------------------------------------------------------------------------
  SELECT constraint_name, constraint_type, status FROM user_constraints\
  WHERE table_name IN (\'CUSTOMERS\',\'ORDERS\');\
  INSERT INTO orders(order_id,customer_id,amount) VALUES (9901,999999,100);

  ---------------------------------------------------------------------------

**Expected result / evidence:** The insert raises ORA-02291 (parent key
not found).

**Explanation to give participants:** PK identifies rows and prevents
duplicates; FK ensures valid parent references. Expected error is a
successful learning outcome.

## 08 \| Relationships -- one-to-one, one-to-many and many-to-many

*Execution: Writable lab*

**Learning outcome:** Model cardinality using SQL.

**Trainer procedure:** Compare a customer-to-order join and discuss a
junction table for many-to-many.

  ----------------------------------------------------------------
  SELECT c.customer_name,o.order_id,o.amount\
  FROM customers c JOIN orders o ON o.customer_id=c.customer_id\
  ORDER BY c.customer_id,o.order_id;

  ----------------------------------------------------------------

**Expected result / evidence:** A customer can appear on multiple rows,
one per order.

**Explanation to give participants:** Sketch 1:1 profile, 1:N
customer/orders, N:M students/courses through enrollment.

## 09 \| Database constraints and data integrity

*Execution: Writable lab*

**Learning outcome:** Observe NOT NULL, UNIQUE and CHECK constraints.

**Trainer procedure:** Inspect constraints and attempt a deliberately
invalid insertion; then roll back.

  ------------------------------------------------------------------------------
  SELECT constraint_name, constraint_type FROM user_constraints\
  WHERE table_name=\'CUSTOMERS\';\
  \-- Instructor: try duplicate customer_id using a new row; expect ORA-00001.

  ------------------------------------------------------------------------------

**Expected result / evidence:** Constraint definitions appear, and a
duplicate-key attempt fails.

**Explanation to give participants:** Constraint enforcement is
database-side; it protects integrity even when applications misbehave.

## 10 \| Normalisation -- 1NF, 2NF, 3NF

*Execution: Conceptual worksheet*

**Learning outcome:** Apply normalization to a simple model.

**Trainer procedure:** Take flat order data with repeated customer
fields; sketch separate CUSTOMER and ORDER tables and identify FK.

  -------------------------------------------------------------------------------------
  \-- Worksheet: Flat(order_id,customer_name,city,item_1,item_2)\
  \-- Normalize to CUSTOMERS(customer_id,\...) and ORDERS(order_id,customer_id,\...).

  -------------------------------------------------------------------------------------

**Expected result / evidence:** Participants identify atomic fields,
customer dependencies and removal of duplicated values.

**Explanation to give participants:** Explain 1NF atomic values; 2NF
removes partial-key dependencies; 3NF removes transitive dependencies.

## 11 \| ACID properties:

*Execution: Writable lab*

**Learning outcome:** Introduce ACID as properties of a transaction.

**Trainer procedure:** Use the savepoint/rollback example as a group
demonstration.

  --------------------------------------------------------------
  SAVEPOINT acid_demo;\
  UPDATE customers SET city=\'Jaipur\' WHERE customer_id=101;\
  ROLLBACK TO acid_demo;

  --------------------------------------------------------------

**Expected result / evidence:** The value is restored within the
transaction.

**Explanation to give participants:** Use the next four activities to
separate atomicity, consistency, isolation and durability.

## 12 \| Atomicity

*Execution: Writable lab*

**Learning outcome:** Show atomicity.

**Trainer procedure:** Treat two changes as one unit; roll both back.

  ---------------------------------------------------------------
  SAVEPOINT before_two_changes;\
  UPDATE customers SET city=\'Chennai\' WHERE customer_id=101;\
  UPDATE customers SET city=\'Kolkata\' WHERE customer_id=102;\
  ROLLBACK TO before_two_changes;

  ---------------------------------------------------------------

**Expected result / evidence:** Neither update remains after rollback.

**Explanation to give participants:** Oracle transaction boundaries are
COMMIT or ROLLBACK; DDL generally commits implicitly.

## 13 \| Consistency

*Execution: Writable lab*

**Learning outcome:** Show consistency using integrity constraints.

**Trainer procedure:** Attempt a foreign-key violating order insert in
TRAINING_APP.

  ----------------------------------------------------
  INSERT INTO orders(order_id, customer_id, amount)\
  VALUES (9902, 999999, 250);

  ----------------------------------------------------

**Expected result / evidence:** ORA-02291 prevents a broken customer
reference.

**Explanation to give participants:** Consistency includes application
invariants; referential integrity is one DB-enforced example.

## 14 \| Isolation

*Execution: Writable lab*

**Learning outcome:** Demonstrate read consistency and isolation.

**Trainer procedure:** Open two SQL\*Plus sessions connected as
TRAINING_APP. In A update a row without commit; in B query the row; then
commit in A and query B again.

  ---------------------------------------------------------------
  \-- Session A\
  UPDATE customers SET city=\'Lucknow\' WHERE customer_id=101;\
  \-- Session B\
  SELECT city FROM customers WHERE customer_id=101;\
  \-- Session A after comparison: ROLLBACK;

  ---------------------------------------------------------------

**Expected result / evidence:** B sees the previously committed value
while A has an uncommitted change.

**Explanation to give participants:** Oracle READ COMMITTED uses
statement-level read consistency by default; avoid promising that all
anomalies are impossible.

## 15 \| Durability

*Execution: Writable lab*

**Learning outcome:** Explain durability and redo.

**Trainer procedure:** Commit a harmless test update and reconnect; then
undo it in a second committed transaction.

  ----------------------------------------------------------------------
  UPDATE customers SET city=\'Mysuru\' WHERE customer_id=101; COMMIT;\
  SELECT city FROM customers WHERE customer_id=101;\
  \-- Trainer: restore original value with a later COMMIT.

  ----------------------------------------------------------------------

**Expected result / evidence:** The committed value survives
disconnect/reconnect.

**Explanation to give participants:** Durability is supported by redo
and recovery; commit does not mean every data block is immediately
written to a datafile.

## 16 \| Transactions and concurrency

*Execution: Writable lab*

**Learning outcome:** Observe transaction concurrency and locking.

**Trainer procedure:** Use two sessions: A updates one customer and
leaves uncommitted; B updates the same row, observes wait; A rolls back.

  ----------------------------------------------------------------------------
  \-- Session A: UPDATE customers SET city=\'Agra\' WHERE customer_id=102;\
  \-- Session B: UPDATE customers SET city=\'Surat\' WHERE customer_id=102;\
  \-- Session A: ROLLBACK; Session B: ROLLBACK;

  ----------------------------------------------------------------------------

**Expected result / evidence:** Session B waits until A releases the row
lock.

**Explanation to give participants:** Never create unbounded lock waits
on the client database; two instructor-controlled sandbox sessions only.

## 17 \| SQL fundamentals and database interaction

*Execution: Writable lab*

**Learning outcome:** Exercise core SQL DML and aggregate functions.

**Trainer procedure:** Run SELECT, WHERE, JOIN and GROUP BY against
TRAINING_APP.

  ---------------------------------------------------------------------
  SELECT c.customer_name, COUNT(o.order_id) AS orders,\
  NVL(SUM(o.amount),0) AS total\
  FROM customers c LEFT JOIN orders o ON c.customer_id=o.customer_id\
  GROUP BY c.customer_name ORDER BY c.customer_name;

  ---------------------------------------------------------------------

**Expected result / evidence:** One row per customer with orders and
totals.

**Explanation to give participants:** Explain SELECT, joins,
aggregations and NULL handling; DDL is covered separately.

# 2. Database Architecture and Concepts

**Days 1-2 \| Concepts:** Trace the same live 19c system from client to
listener, instance, files and recovery. Discovery remains read-only
unless explicitly marked.

## 18 \| Database server architecture

*Execution: Read-only*

**Learning outcome:** Identify major components of a database server.

**Trainer procedure:** Inspect Windows Oracle services, database state
and listener.

  -----------------------------------------------------------------------------------------
  \# PowerShell (read-only)\
  Get-Service \| Where-Object { \$\_.Name -match \'Oracle\|TNS\' } \| Select Name,Status\
  \# SQL\*Plus: SELECT instance_name,status FROM v\$instance;

  -----------------------------------------------------------------------------------------

**Expected result / evidence:** OracleServiceORCLCDB and other installed
services are listed (names vary).

**Explanation to give participants:** An Oracle server includes OS
processes/services, memory, instance, storage and connectivity; service
presence alone does not prove DB health.

## 19 \| Client-server database architecture

*Execution: Read-only*

**Learning outcome:** Trace client-to-database connectivity.

**Trainer procedure:** From PowerShell run a TCP check and connect with
Easy Connect; use password prompt.

  ------------------------------------------------
  Test-NetConnection 127.0.0.1 -Port 1521\
  \# CMD/PowerShell (interactive):\
  sqlplus TRAINING_APP@//127.0.0.1:1521/orclpdb1

  ------------------------------------------------

**Expected result / evidence:** Port reachable, SQL\*Plus prompts for
password, connection to PDB succeeds.

**Explanation to give participants:** Use Easy Connect when no local TNS
alias exists. ORA-12154 is name resolution, not an idle-password
timeout.

## 20 \| Two-tier and three-tier architectures

*Execution: Conceptual worksheet*

**Learning outcome:** Map two-tier versus three-tier.

**Trainer procedure:** Draw two flows: SQL Developer -\> listener -\>
DB; browser -\> application API -\> connection pool -\> DB.

  ---------------------------------------------------
  \-- Worksheet (no DB change)\
  \-- 2-tier: client SQL application -\> Oracle DB\
  \-- 3-tier: browser -\> app/API -\> Oracle DB

  ---------------------------------------------------

**Expected result / evidence:** Participants label authentication,
business logic and SQL execution layers.

**Explanation to give participants:** A browser generally does not
connect directly to a database; a middle tier handles authorization and
pooling.

## 21 \| Database instances and database storage

*Execution: Read-only*

**Learning outcome:** Separate instance from persistent database files.

**Trainer procedure:** Query instance and database names and identify
startup dependency.

  ----------------------------------------------------------
  SELECT instance_name,host_name,status FROM v\$instance;\
  SELECT name,open_mode,log_mode FROM v\$database;

  ----------------------------------------------------------

**Expected result / evidence:** Instance and database views return
distinct properties.

**Explanation to give participants:** Instance = memory plus processes;
database = persistent files. Single instance can open one database at a
time.

## 22 \| Memory management concepts

*Execution: Read-only*

**Learning outcome:** Inspect Oracle memory management.

**Trainer procedure:** Read memory parameters and current allocation.

  ----------------------------------------------------------------------------
  SHOW PARAMETER sga_target\
  SHOW PARAMETER pga_aggregate_target\
  SELECT component,current_size/1024/1024 mb FROM v\$sga_dynamic_components\
  WHERE current_size\>0 ORDER BY mb DESC;

  ----------------------------------------------------------------------------

**Expected result / evidence:** Different SGA components with allocation
in MB.

**Explanation to give participants:** Avoid changing memory parameters
in this exercise, particularly on a 12 GB training VM.

## 23 \| Buffer cache and shared pool

*Execution: Read-only*

**Learning outcome:** Distinguish buffer cache from shared pool.

**Trainer procedure:** Inspect SGA memory consumers and identify their
functions.

  --------------------------------------------------------------
  SELECT name, ROUND(bytes/1024/1024,1) AS mb FROM v\$sgainfo\
  WHERE bytes \> 0 ORDER BY bytes DESC;

  --------------------------------------------------------------

**Expected result / evidence:** Memory pool names and sizes appear.

**Explanation to give participants:** Buffer cache holds data blocks;
shared pool includes SQL/library cache and dictionary cache.

## 24 \| Datafiles, control files and redo logs

*Execution: Read-only*

**Learning outcome:** Locate physical database files.

**Trainer procedure:** Query control file, redo log and datafile paths;
never open or edit the files manually.

  ------------------------------------------------
  SELECT name FROM v\$datafile ORDER BY file\#;\
  SELECT name FROM v\$controlfile;\
  SELECT member FROM v\$logfile;

  ------------------------------------------------

**Expected result / evidence:** Paths show the corresponding Windows
data directories.

**Explanation to give participants:** Control file tracks structure,
redo records changes, datafiles hold persistent block contents.

## 25 \| Database processes and background services

*Execution: Read-only*

**Learning outcome:** Relate database processes and Windows services.

**Trainer procedure:** Review Oracle processes from the DB and operating
system.

  ------------------------------------------------------------------
  SELECT pname,program FROM v\$process WHERE pname IS NOT NULL\
  ORDER BY pname;\
  \-- PowerShell: Get-Process oracle -ErrorAction SilentlyContinue

  ------------------------------------------------------------------

**Expected result / evidence:** DBW/ LGWR and other processes shown
depending on Windows architecture.

**Explanation to give participants:** Some background processes are
threads within Windows Oracle process; do not expect one Windows service
per background process.

## 26 \| Transaction management

*Execution: Writable lab*

**Learning outcome:** Trace transaction lifecycle.

**Trainer procedure:** Record a before/after customer value with an
update, then ROLLBACK.

  --------------------------------------------------------------------------------
  SELECT city FROM training_app.customers WHERE customer_id=101;\
  \-- As TRAINING_APP: UPDATE customers SET city=\'Goa\' WHERE customer_id=101;\
  \-- As TRAINING_APP: ROLLBACK;

  --------------------------------------------------------------------------------

**Expected result / evidence:** Rollback restores the value.

**Explanation to give participants:** Server updates cached blocks and
redo/undo data; LGWR makes committed redo durable, DBWn writes dirty
blocks later.

## 27 \| Database locking and concurrency control

*Execution: Observation / discussion*

**Learning outcome:** Observe blocking and transaction concurrency.

**Trainer procedure:** Open two app sessions and a privileged observer;
create a short intentional row lock.

  ---------------------------------------------------------------
  SELECT sid,serial\#,username,status,blocking_session,event\
  FROM v\$session WHERE username=\'TRAINING_APP\' ORDER BY sid;

  ---------------------------------------------------------------

**Expected result / evidence:** Sessions visible; a blocked waiter may
show BLOCKING_SESSION.

**Explanation to give participants:** Blocking is a transaction wait.
Never kill production sessions for a demonstration.

## 28 \| Database availability and recovery fundamentals

*Execution: Read-only*

**Learning outcome:** Interpret availability and recovery fundamentals.

**Trainer procedure:** Check OPEN_MODE, LOG_MODE and FRA parameters;
contrast backup with standby.

  -----------------------------------------------------------------
  SELECT name,open_mode,log_mode,force_logging FROM v\$database;\
  SHOW PARAMETER db_recovery_file_dest

  -----------------------------------------------------------------

**Expected result / evidence:** Current recovery readiness values
appear.

**Explanation to give participants:** ARCHIVELOG helps online media
recovery but does not replace backups. One-node labs cannot prove
host-level HA.

# 3. Overview of Major Database Platforms

**Day 2 \| Comparison:** Keep platform comparisons neutral and
version-qualified; no non-Oracle DBMS installation is needed.

## 29 \| Introduction and comparison of major enterprise and open-source database platforms.

*Execution: Conceptual worksheet*

**Learning outcome:** Compare enterprise and open-source database
platforms.

**Trainer procedure:** Give participants a matrix to complete for
Oracle, PostgreSQL, SQL Server and MySQL: licensing, HA, backup, SQL and
extension ecosystem.

  ------------------------------------------------------------------------
  \-- Deliverable: 4-column comparison table, not a database command.\
  \-- Label vendor-edition and feature differences as version-dependent.

  ------------------------------------------------------------------------

**Expected result / evidence:** A completed, qualified comparison rather
than absolute feature claims.

**Explanation to give participants:** Avoid asserting one product is
objectively best; suitability depends on workloads, operational
constraints and licensing.

# 4. History and Evolution of Oracle Database

**Day 2 \| Context:** Use a release timeline as an instructor-led
discussion, anchored by the installed version.

## 30 \| 4. History and Evolution of Oracle Database

*Execution: Observation / discussion*

**Learning outcome:** Place Oracle releases in historical context.

**Trainer procedure:** Have learners identify major milestones: early
relational Oracle, 11g, 12c multitenant, 19c long-term release, 21c,
23ai, 26ai.

  ----------------------------------------------------
  SELECT banner_full FROM v\$version WHERE ROWNUM=1;
  ----------------------------------------------------

**Expected result / evidence:** Local installation version is
distinguished from a slide-based historical timeline.

**Explanation to give participants:** Database release and Release
Update levels are different. Correct historical names rather than mixing
marketing release names with RUs.

# 5. Oracle Database Versions and Current Releases

**Day 2 \| Releases:** Verify the actual installed 19c release and patch
inventory; do not assume 26ai runs on this server.

## 31 \| 5. Oracle Database Versions and Current Releases

*Execution: Read-only*

**Learning outcome:** Interpret installed version and patch level.

**Trainer procedure:** Record current DB release and SQL patch registry
entries.

  -------------------------------------------------------
  SELECT banner_full FROM v\$version WHERE ROWNUM=1;\
  SELECT patch_id,action,status,action_time\
  FROM dba_registry_sqlpatch ORDER BY action_time DESC;

  -------------------------------------------------------

**Expected result / evidence:** Installed release and applied SQL
patches documented.

**Explanation to give participants:** Current 19c patch inventory is not
evidence that 21c/26ai features run on the 19c instance.

# 6. Oracle Database vs Other RDBMS Platforms

**Day 2 \| Comparison:** Build conceptual mappings rather than claiming
Oracle terms map precisely onto other RDBMS implementations.

## 32 \| A practical comparison of Oracle 19c against SQL Server, PostgreSQL, MySQL

*Execution: Observation / discussion*

**Learning outcome:** Compare Oracle concepts with familiar RDBMS.

**Trainer procedure:** Map Oracle PDB, schema, tablespace, redo,
listener to approximate SQL Server/PostgreSQL equivalents in a
worksheet.

  --------------------------------------------------------------------------
  SELECT sys_context(\'USERENV\',\'CON_NAME\') AS current_container,\
  sys_context(\'USERENV\',\'CURRENT_SCHEMA\') AS current_schema FROM dual;

  --------------------------------------------------------------------------

**Expected result / evidence:** Participants describe the distinctions
without assuming 1:1 equivalents.

**Explanation to give participants:** In Oracle, schema and user share a
name; a PDB is not equivalent to an individual Oracle user.

# 7. Introduction to Oracle 19c Architecture

**Day 2 \| Architecture:** Deep-dive instance, SGA/PGA, processes, file
structures and CDB/PDBs through live read-only views.

## 33 \| Oracle Database architecture overview

*Execution: Read-only*

**Learning outcome:** Build the 19c architecture mental model.

**Trainer procedure:** Draw client -\> listener -\> instance
(SGA/processes) -\> datafiles/redo/control files and place PDBs inside
CDB.

  ------------------------------------------------
  SELECT instance_name,status FROM v\$instance;\
  SELECT name,cdb,open_mode FROM v\$database;

  ------------------------------------------------

**Expected result / evidence:** One instance, one CDB and its containers
shown in the diagram.

**Explanation to give participants:** Use the architecture reference
diagram from the earlier course; clarify database != instance.

## 34 \| Database versus instance

*Execution: Read-only*

**Learning outcome:** Verify database versus instance identifiers.

**Trainer procedure:** Record instance name, database name, DBID and
creation date.

  ----------------------------------------------------------
  SELECT instance_name,host_name,status FROM v\$instance;\
  SELECT name,dbid,created,cdb FROM v\$database;

  ----------------------------------------------------------

**Expected result / evidence:** Instance and durable database identity
values differ in role.

**Explanation to give participants:** An instance is ephemeral; DBID
identifies the database in backup/recovery contexts.

## 35 \| System Global Area (SGA)

*Execution: Read-only*

**Learning outcome:** Inspect SGA allocations.

**Trainer procedure:** Query summary SGA and dynamic components.

  --------------------------------------------------
  SHOW SGA\
  SELECT component,current_size/1024/1024 AS mb\
  FROM v\$sga_dynamic_components ORDER BY mb DESC;

  --------------------------------------------------

**Expected result / evidence:** SGA components and total memory
observed.

**Explanation to give participants:** SGA is shared by sessions; inspect
rather than tune during foundational exercise.

## 36 \| Program Global Area (PGA)

*Execution: Read-only*

**Learning outcome:** Inspect PGA allocation metrics.

**Trainer procedure:** Query current and maximum aggregate PGA usage.

  -----------------------------------------------------------------------------------------------------------------------
  SELECT name,ROUND(value/1024/1024,1) AS mb\
  FROM v\$pgastat WHERE name IN (\'total PGA allocated\',\'maximum PGA allocated\',\'aggregate PGA target parameter\');

  -----------------------------------------------------------------------------------------------------------------------

**Expected result / evidence:** PGA aggregates appear in MB.

**Explanation to give participants:** PGA is process-private;
target/limit guidance differs from SGA architecture.

## 37 \| Background processes:

*Execution: Read-only*

**Learning outcome:** Identify background-process roles.

**Trainer procedure:** List non-null background process names and map
each to a function.

  -----------------------------------------
  SELECT pname, program FROM v\$process\
  WHERE pname IS NOT NULL ORDER BY pname;

  -----------------------------------------

**Expected result / evidence:** Processes displayed; participants assign
DBW, LGWR, CKPT, SMON, PMON, ARC.

**Explanation to give participants:** Some names depend on
edition/configuration; not every process must appear.

## 38 \| DBWn

*Execution: Read-only*

**Learning outcome:** Explain DBWn (Database Writer).

**Trainer procedure:** Inspect dirty-block checkpoints conceptually; do
not force a checkpoint in a shared environment.

  ------------------------------------------------------------
  SELECT file\#,checkpoint_change\# FROM v\$datafile_header\
  ORDER BY file\#;

  ------------------------------------------------------------

**Expected result / evidence:** File header checkpoint SCNs are listed.

**Explanation to give participants:** DBWn writes dirty blocks to
datafiles; commits do not wait for DBWn to write the modified block.

## 39 \| LGWR

*Execution: Read-only*

**Learning outcome:** Explain LGWR (Log Writer).

**Trainer procedure:** Inspect online redo log groups and current
sequence.

  ---------------------------------------------------------------
  SELECT l.group\#, l.thread\#,l.sequence\#,l.status,\
  ROUND(l.bytes/1024/1024) mb FROM v\$log l ORDER BY l.group\#;

  ---------------------------------------------------------------

**Expected result / evidence:** Redo group status and sequence appear.

**Explanation to give participants:** LGWR writes redo for commit
durability. Check log groups without forcing switches on the client
server.

## 40 \| CKPT

*Execution: Read-only*

**Learning outcome:** Explain CKPT (Checkpoint).

**Trainer procedure:** Compare database and datafile checkpoint values.

  ----------------------------------------------------------------------------
  SELECT checkpoint_change\# FROM v\$database;\
  SELECT file\#,checkpoint_change\# FROM v\$datafile_header ORDER BY file\#;

  ----------------------------------------------------------------------------

**Expected result / evidence:** Checkpoint change numbers are reported.

**Explanation to give participants:** CKPT signals checkpoints and
updates control-file/datafile headers; DBWn writes dirty buffers.

## 41 \| SMON

*Execution: Read-only*

**Learning outcome:** Explain SMON recovery role.

**Trainer procedure:** Query instance startup time and status; discuss
instance recovery after unexpected failure.

  ------------------------------------------------------------
  SELECT instance_name,startup_time,status FROM v\$instance;
  ------------------------------------------------------------

**Expected result / evidence:** Instance startup and status captured.

**Explanation to give participants:** SMON supports instance recovery
and other cleanup; simulate no crash on the client database.

## 42 \| PMON

*Execution: Read-only*

**Learning outcome:** Explain PMON/process cleanup.

**Trainer procedure:** Inspect user sessions and dead-session behavior
conceptually.

  ----------------------------------------------------
  SELECT username,status,COUNT(\*) AS sessions\
  FROM v\$session WHERE type=\'USER\'\
  GROUP BY username,status ORDER BY username,status;

  ----------------------------------------------------

**Expected result / evidence:** Open sessions counted.

**Explanation to give participants:** PMON handles process-related
cleanup; avoid killing sessions to prove the point.

## 43 \| ARCn

*Execution: Read-only*

**Learning outcome:** Explain ARCH/ARCn and archived logs.

**Trainer procedure:** Inspect ARCHIVELOG status and archived log
records.

  ---------------------------------------------------------------
  ARCHIVE LOG LIST\
  SELECT sequence\#,first_time,archived,deleted\
  FROM v\$archived_log WHERE ROWNUM \<= 10 ORDER BY sequence\#;

  ---------------------------------------------------------------

**Expected result / evidence:** Archiving status visible; log rows may
be absent in NOARCHIVELOG mode.

**Explanation to give participants:** ARCn archives full online redo
logs when archiving is configured; never enable ARCHIVELOG casually.

## 44 \| Physical database structures

*Execution: Read-only*

**Learning outcome:** Map physical structures to paths.

**Trainer procedure:** Locate datafiles, redo members, control files and
tempfiles.

  ----------------------------------------
  SELECT file_name FROM dba_data_files;\
  SELECT file_name FROM dba_temp_files;\
  SELECT member FROM v\$logfile;\
  SELECT name FROM v\$controlfile;

  ----------------------------------------

**Expected result / evidence:** Windows file paths documented.

**Explanation to give participants:** Database-managed files must not be
edited, moved or deleted using File Explorer during live service.

## 45 \| Logical database structures

*Execution: Read-only*

**Learning outcome:** Differentiate logical storage.

**Trainer procedure:** Inspect tablespaces and segments.

  --------------------------------------------------------------------------
  SELECT tablespace_name,contents,status FROM dba_tablespaces ORDER BY 1;\
  SELECT owner,segment_name,segment_type,tablespace_name\
  FROM dba_segments WHERE owner=\'TRAINING_APP\' ORDER BY 2;

  --------------------------------------------------------------------------

**Expected result / evidence:** Objects map to segments and tablespaces.

**Explanation to give participants:** A tablespace maps logical
allocation to physical datafiles.

## 46 \| Tablespaces, segments, extents and blocks

*Execution: Read-only*

**Learning outcome:** Trace table -\> segment -\> extent -\> block.

**Trainer procedure:** Query allocation and block size.

  ------------------------------------------------------------------------
  SELECT segment_name,segment_type,extents,blocks\
  FROM dba_segments WHERE owner=\'TRAINING_APP\' ORDER BY segment_name;\
  SHOW PARAMETER db_block_size

  ------------------------------------------------------------------------

**Expected result / evidence:** Extent/block counts and configured block
size visible.

**Explanation to give participants:** Oracle allocates extents of blocks
to segments; not every logical table is stored in a separate file.

## 47 \| Redo logs and archive logs

*Execution: Read-only*

**Learning outcome:** Connect redo logs and archived logs to recovery.

**Trainer procedure:** Compare live redo and archived redo inventory.

  -----------------------------------------------------------------
  SELECT group\#,sequence\#,status FROM v\$log ORDER BY group\#;\
  SELECT COUNT(\*) AS archived_log_rows FROM v\$archived_log;

  -----------------------------------------------------------------

**Expected result / evidence:** Live redo group state and archive
catalog count appear.

**Explanation to give participants:** Redo is overwritten cyclically;
archived logs preserve prior sequences where archiving is enabled.

## 48 \| Control files and SPFILE/PFILE

*Execution: Observation / discussion*

**Learning outcome:** Inspect control files, SPFILE and PFILE.

**Trainer procedure:** Query initialization file location, control file
parameters and export only to a trainer-approved folder if required.

  --------------------------------------------------------------------------------------------------------
  SHOW PARAMETER spfile\
  SHOW PARAMETER control_files\
  \-- Instructor-only optional: CREATE PFILE=\'C:\\OracleLabs\\exports\\init_training.ora\' FROM SPFILE;

  --------------------------------------------------------------------------------------------------------

**Expected result / evidence:** SPFILE and control file locations are
identified.

**Explanation to give participants:** SPFILE is server-managed binary
configuration, PFILE is a text parameter file; do not overwrite either.

## 49 \| Oracle database startup and shutdown lifecycle

*Execution: Instructor-controlled*

**Learning outcome:** Explain startup/shutdown states without
interrupting the existing DB.

**Trainer procedure:** Query OPEN state and diagram NOMOUNT -\> MOUNT
-\> OPEN. On a disposable clone only, observe a controlled lifecycle.

  -------------------------------------------------------------------------
  SELECT status FROM v\$instance;\
  SELECT open_mode FROM v\$database;\
  \-- Clone only: SHUTDOWN IMMEDIATE; STARTUP MOUNT; ALTER DATABASE OPEN;

  -------------------------------------------------------------------------

**Expected result / evidence:** Observer identifies current state;
optional clone returns to OPEN.

**Explanation to give participants:** Startup/shutdown changes have
broad impact. Prefer instructor demonstration on an expendable clone.

## 50 \| Introduction to CDB and PDB architecture

*Execution: Read-only*

**Learning outcome:** Inspect multitenant architecture and scope.

**Trainer procedure:** Check container, PDB state and common/local user
metadata.

  -----------------------------------------------------------------------------------
  SHOW CON_NAME\
  SHOW PDBS\
  SELECT con_id,name,open_mode FROM v\$pdbs;\
  SELECT username,common FROM cdb_users\
  WHERE username IN (\'SYS\',\'SYSTEM\',\'TRAINING_APP\') ORDER BY con_id,username;

  -----------------------------------------------------------------------------------

**Expected result / evidence:** CDB\$ROOT and ORCLPDB1 are
distinguished.

**Explanation to give participants:** CDB\$ROOT stores shared dictionary
metadata; PDB\$SEED is read-only template; local schemas reside inside
PDBs.

# 8. Basic Oracle 19c Administration Demonstration

**Day 3 \| Practical operations:** Use customer-host read-only checks
plus writable TRAINING_APP actions in a disposable clone. Clearly
distinguish privileged SQL\*Plus from OS shell.

## 51 \| Use the customer\'s existing Oracle 19c database for a short live walkthrough.

*Execution: Read-only*

**Learning outcome:** Conduct safe walkthrough of customer 19c host.

**Trainer procedure:** Record host, Oracle Home, service names, database
name and PDBs before modifying anything.

  -----------------------------------------------------------------------------
  \# PowerShell\
  Get-Service \| Where-Object Name -Match \'\^Oracle\' \| Select Name,Status\
  \# SQL\*Plus: SHOW PDBS

  -----------------------------------------------------------------------------

**Expected result / evidence:** One-page environment inventory
completed.

**Explanation to give participants:** Existing client database is
read-only for training unless change approval has been granted; use
isolated TRAINING_APP for DML.

## 52 \| Connecting through SQL\*Plus

*Execution: Read-only*

**Learning outcome:** Connect using SQL\*Plus from Windows.

**Trainer procedure:** Open PowerShell or CMD, start SYSDBA local
connection, then a PDB connection with a password prompt.

  ------------------------------------------------
  sqlplus / as sysdba\
  \# In SQL\*Plus: SHOW CON_NAME EXIT\
  sqlplus TRAINING_APP@//127.0.0.1:1521/orclpdb1

  ------------------------------------------------

**Expected result / evidence:** Root administrator and local PDB user
connections succeed.

**Explanation to give participants:** Easy Connect avoids reliance on
TNS aliases; connection user is in the PDB, not necessarily root.

## 53 \| Using SQL Developer (if available)

*Execution: Read-only*

**Learning outcome:** Use SQL Developer if installed.

**Trainer procedure:** Create an ordinary training connection using
host, TCP port 1521, service name orclpdb1 and TRAINING_APP credentials.

  ---------------------------------------------------------
  \-- Connection form: hostname=127.0.0.1, port=1521\
  \-- service=orclpdb1, username=TRAINING_APP\
  SELECT sys_context(\'USERENV\',\'CON_NAME\') FROM dual;

  ---------------------------------------------------------

**Expected result / evidence:** SQL Developer worksheet shows ORCLPDB1.

**Explanation to give participants:** Do not use SID=ORCLCDB for a PDB
application connection; prefer the PDB service name.

## 54 \| Checking database version

*Execution: Read-only*

**Learning outcome:** Identify installed 19c release and RU.

**Trainer procedure:** Run version and patch inventory queries; compare
with OPatch home inventory.

  ----------------------------------------------------------------
  SELECT banner_full FROM v\$version WHERE ROWNUM=1;\
  SELECT patch_id,status,action_time FROM dba_registry_sqlpatch\
  ORDER BY action_time DESC;

  ----------------------------------------------------------------

**Expected result / evidence:** Version and SQL patch history recorded.

**Explanation to give participants:** Base version 19.3 alone does not
prove the latest security RU; Windows OS certification depends on
applied RU.

## 55 \| Checking database status

*Execution: Read-only*

**Learning outcome:** Verify database health/status.

**Trainer procedure:** Inspect instance, database and PDB open states
and startup time.

  -----------------------------------------------------------------------------
  SELECT instance_name,status,database_status,startup_time FROM v\$instance;\
  SELECT name,open_mode,log_mode FROM v\$database;\
  SHOW PDBS

  -----------------------------------------------------------------------------

**Expected result / evidence:** Expected normal state is instance OPEN,
CDB READ WRITE and ORCLPDB1 READ WRITE in this training lab.

**Explanation to give participants:** Capture exceptions rather than
making changes immediately; PDB\$SEED normally READ ONLY.

## 56 \| Viewing database users and schemas

*Execution: Read-only*

**Learning outcome:** Differentiate user, schema and privileges.

**Trainer procedure:** List users and statuses, then confirm current
schema and sample objects.

  ------------------------------------------------------------------------------------
  SELECT username,account_status,default_tablespace\
  FROM dba_users WHERE username IN (\'APP_USER\',\'REPORT_USER\',\'TRAINING_APP\');\
  SELECT owner,table_name FROM dba_tables WHERE owner=\'TRAINING_APP\';

  ------------------------------------------------------------------------------------

**Expected result / evidence:** User accounts and object ownership are
visible.

**Explanation to give participants:** Oracle schema has same name as its
user, and objects live in a PDB. Account status is separate from table
privileges.

## 57 \| Exploring tablespaces and datafiles

*Execution: Read-only*

**Learning outcome:** Map tablespaces to datafiles.

**Trainer procedure:** Query USERS/SYSTEM/SYSAUX and size.

  ------------------------------------------------------------------
  SELECT tablespace_name,file_name,\
  ROUND(bytes/1024/1024) AS mb,autoextensible FROM dba_data_files\
  ORDER BY tablespace_name,file_name;

  ------------------------------------------------------------------

**Expected result / evidence:** Paths and sizes for permanent datafiles
appear.

**Explanation to give participants:** A user also needs quota (or
authorized alternative) to create segments; CREATE TABLE alone is
insufficient.

## 58 \| Viewing database parameters

*Execution: Read-only*

**Learning outcome:** Explore dynamic vs static parameters.

**Trainer procedure:** Read parameter value and modifiability flags; do
not change them.

  --------------------------------------------------------------------------------------
  SELECT name,display_value,issys_modifiable,isses_modifiable,ispdb_modifiable\
  FROM v\$parameter\
  WHERE name IN (\'db_block_size\',\'open_cursors\',\'optimizer_mode\',\'processes\');

  --------------------------------------------------------------------------------------

**Expected result / evidence:** Each parameter has a value and
modification category.

**Explanation to give participants:** DEFERRED and IMMEDIATE have
different effects; PDB-level modifiability is separate.

## 59 \| Checking SGA and PGA

*Execution: Read-only*

**Learning outcome:** Measure SGA and PGA.

**Trainer procedure:** Run summary memory views and report MB.

  ------------------------------------------------------------------------------
  SELECT name,ROUND(value/1024/1024,1) mb FROM v\$pgastat\
  WHERE name IN (\'total PGA allocated\',\'aggregate PGA target parameter\');\
  SHOW SGA

  ------------------------------------------------------------------------------

**Expected result / evidence:** Current memory allocation recorded.

**Explanation to give participants:** Show how memory sizing connects to
OS RAM, but do not tune the client database as part of discovery.

## 60 \| Viewing database background processes

*Execution: Read-only*

**Learning outcome:** Observe background processes.

**Trainer procedure:** Map actual names to DBW, LGWR, CKPT, SMON, PMON
and ARC.

  ------------------------------------------------------------------------------
  SELECT pname,program FROM v\$process WHERE pname IS NOT NULL ORDER BY pname;
  ------------------------------------------------------------------------------

**Expected result / evidence:** Available named background processes
appear.

**Explanation to give participants:** Oracle Windows uses threads in
processes; do not equate every Oracle background process with a separate
Windows service.

## 61 \| Understanding alert logs and diagnostic directories

*Execution: Read-only*

**Learning outcome:** Locate and interpret alert logs.

**Trainer procedure:** Retrieve ADR diagnostic location and inspect
alert log read-only through ADRCI or filesystem.

  -------------------------------------------------------------------------------
  SELECT name,value FROM v\$diag_info\
  WHERE name IN (\'Diag Trace\',\'Diag Alert\',\'Default Trace File\');\
  \-- CMD: adrci; show homes; set homepath \<actual home\>; show alert -tail 30

  -------------------------------------------------------------------------------

**Expected result / evidence:** Actual diagnostic paths and recent
messages identified.

**Explanation to give participants:** Do not hardcode an ADR path; the
listener and database can have distinct ADR homes.

# 9. Database Upgrade Fundamentals(planning and prechecks)

**Day 3 \| Upgrade foundations:** Only inventory and precheck operations
are in baseline single-node scope. Do not apply patches or upgrade live.

## 62 \| Oracle Database release and versioning

*Execution: Read-only*

**Learning outcome:** Separate release, version, PSU/RU and patch
identifiers.

**Trainer procedure:** Compare v\$version, dba_registry_sqlpatch and
opatch inventory (read-only).

  -----------------------------------------------------------------------
  SELECT banner_full FROM v\$version WHERE ROWNUM=1;\
  SELECT patch_id,patch_type,action,status FROM dba_registry_sqlpatch;\
  \-- CMD (Oracle Home bin): opatch lsinventory

  -----------------------------------------------------------------------

**Expected result / evidence:** Release and installed patch levels
listed independently.

**Explanation to give participants:** Binary patch inventory and SQL
registry should be reconciled; use the patch README for exact
applicability.

## 63 \| Release Updates (RU) and Release Update Revisions

*Execution: Read-only*

**Learning outcome:** Understand Release Updates and patch
prerequisites.

**Trainer procedure:** Inspect home and registry inventory; build a
patch readiness checklist.

  --------------------------------------------------------------------
  \-- Windows CMD in approved Oracle Home:\
  %ORACLE_HOME%\\OPatch\\opatch.bat lsinventory\
  \-- SQL: SELECT patch_id,action,status FROM dba_registry_sqlpatch;

  --------------------------------------------------------------------

**Expected result / evidence:** Checklist includes RU version, OPatch
version, backups, service stop, rollback and datapatch.

**Explanation to give participants:** Actual patch application is a
maintenance change, not a read-only training step.

## 64 \| Upgrade versus patching

*Execution: Conceptual worksheet*

**Learning outcome:** Distinguish RU patching from version upgrade.

**Trainer procedure:** Create two change plans: patch 19c RU on same
release vs 19c-to-new-release upgrade.

  ---------------------------------------------------------------------
  \-- Worksheet\
  \-- RU: same major release, new patch inventory / SQL patching\
  \-- Upgrade: new Oracle Home, catalog upgrade, compatibility checks

  ---------------------------------------------------------------------

**Expected result / evidence:** Two distinct runbooks and rollback
conditions.

**Explanation to give participants:** Do not conflate datapatch with
AutoUpgrade; major upgrades require a supported target home and explicit
plan.

## 65 \| Supported upgrade paths

*Execution: Read-only*

**Learning outcome:** Assess upgrade path and database readiness.

**Trainer procedure:** Collect 19c version, compatibility and
object-status inventory; optionally run current AutoUpgrade Analyze if
target tools exist.

  ---------------------------------------------------------------------------------------------
  SHOW PARAMETER compatible\
  SELECT COUNT(\*) AS invalid_objects FROM dba_objects WHERE status=\'INVALID\';\
  SELECT comp_name,status,version FROM dba_registry ORDER BY comp_name;\
  \-- Optional instructor command: java -jar autoupgrade.jar -config config.cfg -mode analyze

  ---------------------------------------------------------------------------------------------

**Expected result / evidence:** Assessment lists blockers and
target-specific compatibility questions.

**Explanation to give participants:** AutoUpgrade Analyze is a precheck,
not an upgrade. A qualified target release and supported OS/home are
required.

# 10. Upgrade in High Availability Environments 

**Day 3 \| HA upgrade concepts:** These require a standby topology and
supported upgrade sequence. On one instance use architecture worksheets,
not simulated success claims.

## 66 \| Upgrade in Data Guard configurations

*Execution: Conceptual worksheet*

**Learning outcome:** Understand upgrade in Data Guard configurations.

**Trainer procedure:** Using architecture diagram, assign
primary/standby roles and identify expected redo transport, apply and
switchover checkpoints.

  ----------------------------------------------------------------------------
  SELECT database_role,open_mode,protection_mode FROM v\$database;\
  \-- On an actual broker-configured pair only: DGMGRL\> SHOW CONFIGURATION;

  ----------------------------------------------------------------------------

**Expected result / evidence:** Single instance shows its current role;
no actual standby is demonstrated on one instance.

**Explanation to give participants:** Full Data Guard operations require
a second database. Two same-host instances are an HA simulation, not
server-level DR.

## 67 \| Standby-first patching

*Execution: Conceptual worksheet*

**Learning outcome:** Assess standby-first patch eligibility.

**Trainer procedure:** Inspect patch README and verify certification;
build an ordered readiness checklist on paper.

  -----------------------------------------------------------------------------
  \-- Worksheet: patch README says standby-first eligible? YES / NO\
  \-- Record standby health, transport/apply lag, backups, test and fallback.

  -----------------------------------------------------------------------------

**Expected result / evidence:** Participants identify that not every RU
or option is eligible for standby-first patching.

**Explanation to give participants:** Never apply a patch to a standby
based on a generic procedure; follow version-specific Oracle
instructions.

## 68 \| Rolling upgrade strategies

*Execution: Conceptual worksheet*

**Learning outcome:** Explain rolling upgrade strategy and downtime
envelope.

**Trainer procedure:** Build a staged upgrade diagram including redo
apply, logical transitions if applicable and application validation.

  ----------------------------------------------------------------------------
  \-- Worksheet: prepare -\> verify -\> standby-first/rolling mechanism -\>\
  \-- switchover -\> post-upgrade -\> reconcile -\> rollback decision

  ----------------------------------------------------------------------------

**Expected result / evidence:** A runbook indicates topology, licensing
constraints, testing and RPO/RTO.

**Explanation to give participants:** DBMS_ROLLING, logical standby and
Active Data Guard are specialized workflows; do not promise a live
rolling-upgrade demo on one database.

# 11. Oracle Spatial Database

**Day 4 \| Spatial basics:** Confirm SDO component and SRID rules, then
inspect sample geodetic point data.

## 69 \| Module 1. Oracle Spatial Fundamentals

*Execution: Observation / discussion*

**Learning outcome:** Introduce geospatial use cases.

**Trainer procedure:** Have participants formulate a telecom-tower
proximity query; use prepared training_sites after lab setup.

  -----------------------------------------------------------------------------
  SELECT site_id,site_name FROM training_app.training_sites ORDER BY site_id;
  -----------------------------------------------------------------------------

**Expected result / evidence:** List of candidate locations prepared; no
spatial claims until metadata/index validation.

**Explanation to give participants:** Explain geometry and relationship
operations and real-world mobile tower/site planning.

## 70 \| Introduction to Oracle Spatial

*Execution: Read-only*

**Learning outcome:** Confirm Oracle Spatial component availability.

**Trainer procedure:** Check Spatial component registration and
available MDSYS types.

  ------------------------------------------------------------
  SELECT comp_id,comp_name,status,version FROM dba_registry\
  WHERE comp_id=\'SDO\';\
  SELECT owner,type_name FROM dba_types\
  WHERE owner=\'MDSYS\' AND type_name=\'SDO_GEOMETRY\';

  ------------------------------------------------------------

**Expected result / evidence:** SDO component shows VALID when installed
correctly; geometry type exists.

**Explanation to give participants:** Availability is distinct from
whether the current training user has CREATE TABLE, INDEX and tablespace
quota.

## 71 \| Spatial data types and concepts

*Execution: Writable lab*

**Learning outcome:** Inspect geometry values and geometry-type codes.

**Trainer procedure:** Retrieve SDO_GTYPE, SRID and point coordinates
for sample sites.

  --------------------------------------------------------
  SELECT site_name, t.location.sdo_gtype AS gtype,\
  t.location.sdo_srid AS srid,\
  t.location.sdo_point.x AS longitude,\
  t.location.sdo_point.y AS latitude\
  FROM training_app.training_sites t ORDER BY site_name;

  --------------------------------------------------------

**Expected result / evidence:** GTYPE=2001 for 2D points and SRID=4326
for WGS84 sample.

**Explanation to give participants:** Spatial geometry is an object
value; coordinate axis order is longitude X, latitude Y for these
points.

## 72 \| Coordinate systems and reference systems

*Execution: Read-only*

**Learning outcome:** Explain coordinate reference systems.

**Trainer procedure:** Compare lat/long values and identify SRID=4326;
discuss why distances cannot be interpreted as degrees.

  --------------------------------------------------------------
  SELECT DISTINCT t.location.sdo_srid AS srid\
  FROM training_app.training_sites t;\
  SELECT srid,coord_ref_sys_name FROM mdsys.sdo_coord_ref_sys\
  WHERE srid=4326;

  --------------------------------------------------------------

**Expected result / evidence:** SRID 4326 identified as WGS 84;
exercises use geodetic units.

**Explanation to give participants:** Longitude/latitude are angular
coordinates; distance calculations require appropriate geodetic logic
and units.

# 12. Spatial Data Management

**Day 4 \| Spatial workshop:** Create and index a spatial table in the
approved TRAINING_APP schema. Use one-time setup and expected-result
checks.

## 73 \| Creating spatial tables

*Execution: Writable lab*

**Learning outcome:** Create a spatial table in the isolated PDB.

**Trainer procedure:** As TRAINING_APP, create TRAINING_SITES and insert
points from the sample setup script.

  ----------------------------------------------------------------
  CREATE TABLE training_sites\
  (site_id NUMBER PRIMARY KEY, site_name VARCHAR2(80) NOT NULL,\
  location MDSYS.SDO_GEOMETRY);\
  \-- Continue with the companion spatial setup file.

  ----------------------------------------------------------------

**Expected result / evidence:** Training_sites exists with SDO_GEOMETRY
column.

**Explanation to give participants:** CREATE TABLE requires storage
quota; run only once or in a fresh schema.

## 74 \| Inserting and managing spatial data

*Execution: Writable lab*

**Learning outcome:** Insert and inspect spatial point data.

**Trainer procedure:** Use MDSYS constructors for points then query
their geometry attributes.

  ----------------------------------------------------------
  INSERT INTO training_sites VALUES\
  (1,\'Bengaluru\',MDSYS.SDO_GEOMETRY(2001,4326,\
  MDSYS.SDO_POINT_TYPE(77.5946,12.9716,NULL),NULL,NULL));\
  COMMIT;

  ----------------------------------------------------------

**Expected result / evidence:** One Bangalore site inserted; object
fields can be inspected.

**Explanation to give participants:** SDO_POINT_TYPE X is longitude and
Y latitude. Use synthetic training coordinates only.

## 75 \| Spatial metadata registration

*Execution: Writable lab*

**Learning outcome:** Register spatial metadata and build an index.

**Trainer procedure:** As TRAINING_APP, register column dimension bounds
and create spatial index with companion script; then inspect index
status.

  ------------------------------------------------------------------
  SELECT table_name,column_name,srid FROM user_sdo_geom_metadata;\
  SELECT index_name,status,ityp_owner,ityp_name FROM user_indexes\
  WHERE table_name=\'TRAINING_SITES\';

  ------------------------------------------------------------------

**Expected result / evidence:** USER_SDO_GEOM_METADATA contains
TRAINING_SITES.LOCATION and index status is VALID.

**Explanation to give participants:** Spatial indexes may fail if the
component is invalid or geometry metadata is missing; do not add
duplicate metadata records.

# 13. Hot Reload / Online Configuration Change

**Day 5 \| Online operations:** Session-level change is suitable for all
participants. System-wide parameter changes and online DDL are
instructor-authorized exercises.

## 76 \| 1. Understanding online and offline database configuration change

*Execution: Read-only*

**Learning outcome:** Differentiate online configuration from
near-zero-downtime schema change.

**Trainer procedure:** Sort examples into session-level settings,
dynamic system settings, static settings and online DDL.

  ------------------------------------------------------------------------------------------
  SELECT name,issys_modifiable,isses_modifiable,ispdb_modifiable\
  FROM v\$parameter WHERE name IN (\'optimizer_mode\',\'db_block_size\',\'open_cursors\');

  ------------------------------------------------------------------------------------------

**Expected result / evidence:** Participants distinguish live parameter
changes from application upgrades or online table redefinition.

**Explanation to give participants:** Hot reload is not one named Oracle
19c feature; procedure-specific downtime and privileges matter.

## 77 \| 2. Dynamic versus static initialization parameters

*Execution: Read-only*

**Learning outcome:** Classify dynamic and static parameters.

**Trainer procedure:** Read v\$parameter flags and relate
IMMEDIATE/DEFERRED/FALSE to restart behavior.

  --------------------------------------------------------------------------------------
  SELECT name,value,issys_modifiable,isses_modifiable\
  FROM v\$parameter WHERE name IN (\'processes\',\'open_cursors\',\'optimizer_mode\');

  --------------------------------------------------------------------------------------

**Expected result / evidence:** PROCESSES is typically static; other
parameters may be dynamic depending on scope.

**Explanation to give participants:** Do not automatically change any
parameter on a customer server; record original values and testing
requirements.

## 78 \| 3. ALTER SYSTEM and ALTER SESSION

*Execution: Writable lab*

**Learning outcome:** Use ALTER SESSION safely; explain ALTER SYSTEM
scope.

**Trainer procedure:** As TRAINING_APP change a session-only display
format, verify it, then disconnect; separately explain SCOPE values.

  -------------------------------------------------------------------------------------------------------
  ALTER SESSION SET NLS_DATE_FORMAT=\'YYYY-MM-DD\';\
  SELECT TO_CHAR(SYSDATE,\'YYYY-MM-DD\') AS today_text, SYSDATE AS session_date FROM dual;\
  \-- Instructor-only sandbox: ALTER SYSTEM SET \<supported_dynamic_parameter\>=\<value\> SCOPE=MEMORY;

  -------------------------------------------------------------------------------------------------------

**Expected result / evidence:** Session display changes immediately; no
instance-wide setting is modified.

**Explanation to give participants:** SCOPE=MEMORY is temporary, SPFILE
takes effect on restart, BOTH persists and applies to dynamic settings;
examples must respect PDB eligibility.

# 14. Backup/Restore

**Day 5 \| RMAN:** Backup operations are state-changing and consume
storage; isolate them. Never delete or damage production files for a
recovery demonstration.

## 79 \| Physical vs logical backups, cold vs hot backups, RPO/RTO

*Execution: Read-only*

**Learning outcome:** Differentiate logical/physical and online/offline
backup, RPO/RTO.

**Trainer procedure:** Record log_mode and current RMAN configuration,
then draw a restore timeline for RPO=15 min and RTO=2 hours.

  -----------------------------------------
  SELECT name,log_mode FROM v\$database;\
  SHOW PARAMETER db_recovery_file_dest\
  \-- In RMAN prompt: SHOW ALL;

  -----------------------------------------

**Expected result / evidence:** A requirements worksheet identifies data
loss and time to restore targets.

**Explanation to give participants:** Data Pump logical export is not a
substitute for physical RMAN backups. ARCHIVELOG plus backups are
required for many online recovery scenarios.

## 80 \| Complete database backup using RMAN

*Execution: Instructor-controlled*

**Learning outcome:** Perform and validate a complete RMAN backup.

**Trainer procedure:** On an approved disposable ARCHIVELOG-configured
database with sufficient disk, connect RMAN and run the script. Do not
run against customer production.

  ---------------------------------------------------------
  \-- Windows CMD: rman target /\
  CONFIGURE CONTROLFILE AUTOBACKUP ON;\
  BACKUP DATABASE PLUS ARCHIVELOG TAG \'TRAINING_FULL\';\
  LIST BACKUP SUMMARY;\
  RESTORE DATABASE VALIDATE;

  ---------------------------------------------------------

**Expected result / evidence:** Backup pieces and successful RMAN
validation reported; warnings are investigated.

**Explanation to give participants:** Do not use DELETE OBSOLETE or
delete archived logs for the training. Backup success is not full proof
until an actual restore drill.

## 81 \| Backup/restore an individual PDB

*Execution: Instructor-controlled*

**Learning outcome:** Back up and explain PDB recovery workflow.

**Trainer procedure:** From CDB\$ROOT in RMAN back up ORCLPDB1, record
archived redo dependencies, and validate; actual restore only on
isolated recovery clone.

  -----------------------------------------------------------
  \-- In RMAN connected to CDB root\
  BACKUP PLUGGABLE DATABASE ORCLPDB1 TAG \'TRAINING_PDB\';\
  LIST BACKUP SUMMARY;\
  RESTORE PLUGGABLE DATABASE ORCLPDB1 VALIDATE;

  -----------------------------------------------------------

**Expected result / evidence:** PDB backup and restore validation return
successful status.

**Explanation to give participants:** BACKUP PLUGGABLE DATABASE does not
by itself include archived redo logs; complete recovery requires
appropriate archived logs and root metadata.

# Trainer extensions: missing capabilities from earlier agreed scope

**Why included:** The uploaded plan does not explicitly include Data
Guard implementation, GoldenGate, Data Pump migration, user/role
privileges as a core module, or tested RMAN restore/recover. These were
part of the earlier five-day objectives and should be separately
contracted or added by rebalancing time.

## EXT-A \| User privileges and schema administration (45--60 min)

**Purpose and steps:** Preflight user in ORCLPDB1; query SESSION_PRIVS
and DBA_TS_QUOTAS; demonstrate controlled ORA-01031 and ORA-01950
troubleshooting; discuss identity/sequence grants.

  -------------------------------------------------------------------------------------------------
  SHOW USER\
  SHOW CON_NAME\
  SELECT privilege FROM session_privs WHERE privilege IN (\'CREATE TABLE\',\'CREATE SEQUENCE\');\
  SELECT username,tablespace_name,max_bytes FROM dba_ts_quotas\
  WHERE username=\'TRAINING_APP\';

  -------------------------------------------------------------------------------------------------

**Expected evidence / constraint:** Individual TRAINING_APP permissions
and tablespace quota are verified. Do not grant privileges from an
unprivileged account.

## EXT-B \| Performance and day-2 operational diagnostics (45--60 min)

**Purpose and steps:** Inspect V\$SESSION, V\$SYSTEM_EVENT and
statistics; identify blocked session in controlled sandbox; explain
AWR/ASH licensing and use only approved views.

  ----------------------------------------------------------------
  SELECT sid,serial\#,username,status,event,blocking_session\
  FROM v\$session WHERE username=\'TRAINING_APP\';\
  SELECT name,value FROM v\$sysstat WHERE name=\'user commits\';

  ----------------------------------------------------------------

**Expected evidence / constraint:** Record an evidence-based session
health report; do not access Diagnostics Pack reports unless licensed.

## EXT-C \| Data Pump logical backup/migration on 19c (60--90 min)

**Purpose and steps:** Create a real Windows directory on the database
host (instructor), grant directory object access, run expdp and impdp
with safe schema remapping in an isolated PDB.

  -----------------------------------------------------------------------------------------------------------------------------------------------------
  \-- SYSDBA in PDB: CREATE OR REPLACE DIRECTORY TRAINING_DP AS \'D:\\OracleLabs\\Dumps\';\
  \-- GRANT READ, WRITE ON DIRECTORY TRAINING_DP TO TRAINING_APP;\
  \-- CMD: expdp TRAINING_APP@//127.0.0.1:1521/orclpdb1 schemas=TRAINING_APP directory=TRAINING_DP dumpfile=training_app.dmp logfile=training_exp.log

  -----------------------------------------------------------------------------------------------------------------------------------------------------

**Expected evidence / constraint:** Export log and dump file appear on
database host, not necessarily participant workstation. Import requires
a target user, quota and remap plan.

## EXT-D \| GoldenGate logical replication (2--3 hours; separate licensed setup)

**Purpose and steps:** Use a prebuilt, supported GoldenGate deployment
and two logical endpoint databases; demonstrate Extract/Replicat health,
commit source record, verify target and compare lag.

  -------------------------------------------------------------------
  \-- Instructor worksheet: Source commit time = \_\_\_\_\_\_\
  \-- Extract status = \_\_\_\_\_\_ Replicat status = \_\_\_\_\_\_\
  \-- Target row count = \_\_\_\_\_\_ Measured lag = \_\_\_\_\_\_

  -------------------------------------------------------------------

**Expected evidence / constraint:** Requires separate GoldenGate
installation, product entitlement and a compatible source/target
configuration; not a feature bundled into 19c EE.

## EXT-E \| Data Guard primary/standby (2--3 hours with second database)

**Purpose and steps:** Demonstrate database roles and broker SHOW
CONFIGURATION on two prepared 19c instances; identify transport/apply
state and undertake switchover only on isolated lab with approved
rollback.

  ---------------------------------------------------------------------
  SELECT database_role,open_mode,switchover_status FROM v\$database;\
  \-- DGMGRL (broker configured only): SHOW CONFIGURATION;

  ---------------------------------------------------------------------

**Expected evidence / constraint:** One Oracle instance alone cannot
serve as a functioning primary and physical standby. Two instances on
one host are educational only, not host-level DR.

## EXT-F \| Cross-version 19c and 21c Data Pump (1.5--2 hours)

**Purpose and steps:** Export schema 19c to 21c; export compatible 21c
schema with VERSION=19 to 19c; validate invalid objects, row counts,
metadata and unsupported features.

  ----------------------------------------------------------------------------------------------------------------------------------------------------
  \-- CMD on 21c source, compatible subset only:\
  expdp TRAINING_APP@//HOST21:1521/pdb21 schemas=TRAINING_APP directory=TRAINING_DP dumpfile=app_compat19.dmp logfile=export_compat19.log version=19

  ----------------------------------------------------------------------------------------------------------------------------------------------------

**Expected evidence / constraint:** Requires installed 21c target/source
and compatible feature set. VERSION does not automatically down-convert
arbitrary 21c objects.

## EXT-G \| RMAN restore and recovery rehearsal (2--3 hours, clone only)

**Purpose and steps:** From known-good backup, restore a disposable
training database or PDB into an isolated clone; recover archived logs
and validate data. Never destroy the only working customer database.

  ----------------------------------------------------------------
  \-- RMAN (isolate clone, trainer controls exact commands):\
  LIST BACKUP SUMMARY;\
  RESTORE DATABASE VALIDATE;\
  \-- Complete RESTORE/RECOVER sequence is environment-specific.

  ----------------------------------------------------------------

**Expected evidence / constraint:** A successful BACKUP and VALIDATE
prove less than an end-to-end tested restore; training completion should
record recovery evidence.

# Troubleshooting quick reference

  **Symptom**             **Likely cause**                              **Safe trainer response**
  ----------------------- --------------------------------------------- -------------------------------------------------------------------------------------
  ORA-12154                                                             
                          TNS alias not resolved                        
                                                                        Use Easy Connect; validate actual service name with lsnrctl status.
  ORA-12514 / ORA-12504                                                 
                          Unknown/missing service                       
                                                                        Check PDB open state, service registration, and correct //host:port/service syntax.
  ORA-01031                                                             
                          Missing system/object privileges              
                                                                        Check SESSION_PRIVS, ownership and container; escalate only required GRANT.
  ORA-01950                                                             
                          No quota on selected tablespace               
                                                                        Check DBA_TS_QUOTAS and authorized per-user quota.
  ORA-02291                                                             
                          Foreign key parent not found                  
                                                                        Show constraints, confirm parent record, do not disable FK for demo.
  ORA-00001                                                             
                          Unique/PK violation                           
                                                                        Use new key or rollback intentional duplicate insert.
  RMAN backup fails                                                     
                          Space, permissions, log mode or destination   
                                                                        Check RMAN log, FRA usage and storage; do not delete logs blindly.
  Spatial index errors                                                  
                          Invalid metadata/component or privileges      
                                                                        Check DBA_REGISTRY, USER_SDO_GEOM_METADATA, geometry validity.

# Instructor assessment and evidence checklist

□ Participant connected to correct PDB (ORCLPDB1) and can distinguish
CDB\$ROOT from a local schema.

□ Participant queried V\$INSTANCE/V\$DATABASE and located diagnostic
paths without modifying files.

□ Participant created/query sample objects and demonstrated one
constraint violation safely.

□ Participant demonstrated COMMIT/ROLLBACK or a two-session isolation
observation.

□ Participant identified datafiles, redo groups, control files, SGA/PGA
and background-process roles.

□ Participant inspected installed version and RU without attempting a
production upgrade.

□ Participant built or inspected SDO geometry, metadata and spatial
index.

□ Participant executed ALTER SESSION and explained dynamic versus static
parameters.

□ Participant recorded RMAN backup/validation evidence on approved
backup-capable lab.

□ Participant distinguished concept-only HA/GoldenGate/21c exercises
from completed live demonstrations.

# Trainer cleanup, evidence retention and rollback

**Cleanup sequence:** Export logs and screenshot evidence after
redacting connection details, then rollback remaining DML in each
training session. Do not automatically DROP accounts or databases on the
customer host. If an isolated disposable environment is used, revert the
VM snapshot after verification and consent.

  -----------------------------------------------------------------
  \-- TRAINING_APP session (if testing left an open transaction)\
  ROLLBACK;\
  \-- SQL\*Plus\
  SPOOL OFF\
  EXIT

  -----------------------------------------------------------------

**Repeatability:** The accompanying scripts provide read-only inventory,
deterministic sample schema creation for the isolated PDB and Spatial
setup. They intentionally omit automated DROP DATABASE, archivelog
removal, instance restart, restore, patch and failover commands.

# Oracle documentation and trainer references

-   Oracle 19c Database Concepts:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/cncpt/

-   Oracle 19c Database Administrator's Guide:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/

-   Starting Up and Shutting Down:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/starting-up-and-shutting-down.html

-   Managing initialization parameters:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/admin/creating-and-configuring-an-oracle-database.html

-   Oracle 19c Backup and Recovery Guide:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/

-   Backing up CDBs and PDBs:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/bradv/backing-up-database.html

-   Oracle 19c Data Guard Concepts:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/sbydb/

-   Oracle Spatial Developer's Guide:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/spatl/

-   Oracle 19c Database Upgrade Guide:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/

-   AutoUpgrade analyze mode:
    https://docs.oracle.com/en/database/oracle/oracle-database/19/upgrd/autoupgrade-command-line-parameters.html
