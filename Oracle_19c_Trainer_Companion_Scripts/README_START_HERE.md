# Oracle 19c Windows Trainer Companion Pack

**Matches** the topic-aligned Trainer Practical Workbook; primary target `ORCLCDB` and PDB `ORCLPDB1`.

## Important controls

- This pack has NOT been executed on your Oracle host. Validate against your Oracle 19c RU, licensing, user grants, file locations, and lab snapshot.
- Never run writable scripts in a production database. Use a separate isolated PDB or disposable VM and confirm `SHOW CON_NAME` before every change.
- Each script is labeled with its executor: PowerShell, SQL*Plus as SYSDBA, SQL*Plus as TRAINING_APP, or RMAN.
- SQL*Plus commands like `SHOW CON_NAME` will not work in a generic SQL Developer worksheet; use the corresponding query there.
- Use interactive password prompts. Replace all `REPLACE_...` placeholders locally; never add credentials to shared source files.
- No script deletes database files, archived logs, backups, users, or databases. One-time create scripts may fail if run twice.
- The primary customer database might run in `NOARCHIVELOG`; physical backup scripts require a **preconfigured isolated ARCHIVELOG test database**.

## Order of operations

1. `00_windows_preflight.ps1` (read-only)
2. `01_inventory_sysdba.sql` (read-only, connect to CDB$ROOT)
3. `02_trainer_create_schema_SYS.sql` (writable, run only in isolated ORCLPDB1; trainer approval)
4. `03_training_app_seed.sql` (writable, run as TRAINING_APP; generates customer/order tables)
5. `04_training_app_transactions.sql` (writable, run as TRAINING_APP; use 2 sessions for concurrency section)
6. `05_architecture_sysdba.sql` (read-only)
7. `06_administration_sysdba.sql` (read-only)
8. `07_spatial_create_training_app.sql` (writable, TRAINING_APP only; run once)
9. `08_spatial_verify_training_app.sql` (read-only)
10. `09_rman_backup_approved_clone.rman` (changes backup state, lab clone only)
11. `10_rman_validate.rman` (backup validation, reads from RMAN backup)
12. `11_upgrade_precheck_sysdba.sql` (read-only inventory)
13. `12_parameter_session_training_app.sql` (session-only changes)
14. `13_optional_privilege_checks.sql` (read-only as privileged admin in PDB)

## In the Windows Command Prompt or PowerShell

```
# Open an OSDBA-capable terminal:
sqlplus / as sysdba
# Within SQL*Plus:
@01_inventory_sysdba.sql
```

For the application user:

```
sqlplus TRAINING_APP@//127.0.0.1:1521/orclpdb1
# Then enter password interactively and run @03_training_app_seed.sql
```

In RMAN (on approved clone only): `rman target /` followed by `@09_rman_backup_approved_clone.rman`.

## Database restore note

The actual `RESTORE` and `RECOVER` sequence is intentionally not automated: file destinations, storage setup, archived redo coverage and control file state are environment-specific. Record them in the instructor recovery runbook and perform only on a disposable recovery clone.
