-- READ-ONLY. Query current 19c before preparing any target release.
SELECT banner_full FROM v$version WHERE ROWNUM=1;
SHOW PARAMETER compatible
SELECT patch_id,action,status,action_time FROM dba_registry_sqlpatch
ORDER BY action_time DESC;
SELECT comp_name,status,version FROM dba_registry ORDER BY comp_name;
SELECT COUNT(*) invalid_objects FROM dba_objects WHERE status='INVALID';
SELECT name,open_mode,log_mode FROM v$database;
-- If a compatible target Oracle Home and current autoupgrade.jar have been prepared,
-- run analyze mode with a reviewed config. Analyze is a precheck, not upgrade.
