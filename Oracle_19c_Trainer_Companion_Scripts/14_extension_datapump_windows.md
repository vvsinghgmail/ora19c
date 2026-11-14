# Optional Data Pump lab (requires approved filesystem path)

**Prerequisites:** Oracle DB host Windows directory physically exists and Oracle DB service account has read/write access. The path below is **illustrative** and must be changed. Import needs a separate prepared target schema/quotas.

In PDB as privileged administrator:

```sql
CREATE OR REPLACE DIRECTORY TRAINING_DP AS 'D:\OracleLabs\Dumps';
GRANT READ, WRITE ON DIRECTORY TRAINING_DP TO TRAINING_APP;
```

From **Windows CMD or PowerShell**, use an interactive password prompt:

```powershell
expdp TRAINING_APP@//127.0.0.1:1521/orclpdb1 schemas=TRAINING_APP directory=TRAINING_DP dumpfile=training_app.dmp logfile=training_exp.log
```

Version-specific export from 21c to 19c may use `VERSION=19` for compatible objects, but newer object types may require remediation. The standalone 19c server cannot exercise both directions without access to Oracle 21c.
