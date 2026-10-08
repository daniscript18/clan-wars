new MySQL:g_Database = MYSQL_INVALID_HANDLE;
new bool:g_DatabaseConnected = false;
new bool:g_ServerReady = false;

bool:Database_Connect()
{
    mysql_log(ERROR | WARNING);
    g_Database = mysql_connect_file();

    if(g_Database == MYSQL_INVALID_HANDLE || mysql_errno(g_Database) != 0)
    {
        print("[database] Could not establish the MySQL connection.");
        return false;
    }

    g_DatabaseConnected = true;
    print("[database] Connection established.");
    return true;
}

Database_Disconnect()
{
    if(!g_DatabaseConnected) return 1;

    mysql_close(g_Database);
    g_Database = MYSQL_INVALID_HANDLE;
    g_DatabaseConnected = false;
    g_ServerReady = false;
    return 1;
}

bool:Database_IsReady()
{
    return g_DatabaseConnected && g_ServerReady;
}
