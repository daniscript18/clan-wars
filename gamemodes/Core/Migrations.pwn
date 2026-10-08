#define CORE_MIGRATION_VERSION "0001_core"
#define CORE_MIGRATION_FILE    "migrations/0001_core.sql"

new bool:g_MigrationRunning = false;
new bool:g_MigrationFailed = false;

Database_RunMigrations()
{
    g_MigrationRunning = true;
    g_MigrationFailed = false;

    mysql_tquery(g_Database,
        "CREATE TABLE IF NOT EXISTS `schema_migrations` (`version` VARCHAR(64) NOT NULL, `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (`version`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci",
        "Migration_OnRegistryReady"
    );
    return 1;
}

forward Migration_OnRegistryReady();
public Migration_OnRegistryReady()
{
    if(g_MigrationFailed) return Migration_Abort();

    new query[192];
    mysql_format(g_Database, query, sizeof(query), "SELECT 1 FROM `schema_migrations` WHERE `version`='%e' LIMIT 1", CORE_MIGRATION_VERSION);
    mysql_tquery(g_Database, query, "Migration_OnCoreChecked");
    return 1;
}

forward Migration_OnCoreChecked();
public Migration_OnCoreChecked()
{
    if(g_MigrationFailed) return Migration_Abort();

    if(cache_num_rows() > 0)
    {
        print("[migrations] Core schema already applied.");
        return Migration_Finish();
    }

    printf("[migrations] Applying %s...", CORE_MIGRATION_VERSION);
    if(!mysql_tquery_file(g_Database, CORE_MIGRATION_FILE, "Migration_OnCoreApplied"))
    {
        print("[migrations] Could not queue core migration file.");
        return Migration_Abort();
    }
    return 1;
}

forward Migration_OnCoreApplied();
public Migration_OnCoreApplied()
{
    if(g_MigrationFailed) return Migration_Abort();

    new query[192];
    mysql_format(g_Database, query, sizeof(query), "INSERT INTO `schema_migrations` (`version`) VALUES ('%e')", CORE_MIGRATION_VERSION);
    mysql_tquery(g_Database, query, "Migration_OnCoreRecorded");
    return 1;
}

forward Migration_OnCoreRecorded();
public Migration_OnCoreRecorded()
{
    if(g_MigrationFailed) return Migration_Abort();
    printf("[migrations] Applied %s.", CORE_MIGRATION_VERSION);
    return Migration_Finish();
}

Migration_Finish()
{
    g_MigrationRunning = false;
    g_MigrationFailed = false;
    Match_RecoverInterrupted();
    return 1;
}

Migration_Abort()
{
    g_MigrationRunning = false;
    print("[migrations] Migration failed. Server startup aborted.");
    SendRconCommand("exit");
    return 0;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle)
{
    printf("[mysql] Error %d in callback '%s': %s", errorid, callback, error);
    printf("[mysql] Query: %s", query);

    if(handle == g_Database && g_MigrationRunning)
    {
        g_MigrationFailed = true;
    }
    return 1;
}
