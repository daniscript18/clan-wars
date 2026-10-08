enum E_PLAYER_DATA
{
    pDatabaseId,
    pSessionId,
    bool:pAuthenticated,
    pAdminLevel,
    pSkin,
    pWorldSlot,
    pTeam,
    bool:pReady,
    pMatchDatabaseId,
    pMatchKills,
    pMatchDeaths,
    pKills,
    pDeaths,
    pWins,
    pLosses,
    pLoginFailures,
    pLoginLockedUntil,
    pMuteUntil,
    pUsername[MAX_PLAYER_NAME + 1],
    pIpAddress[46],
    pPasswordHash[BCRYPT_HASH_LENGTH]
};

new g_Player[MAX_PLAYERS][E_PLAYER_DATA];

Player_Reset(playerid, bool:increaseSession = false)
{
    if(increaseSession) g_Player[playerid][pSessionId]++;

    g_Player[playerid][pDatabaseId] = 0;
    g_Player[playerid][pAuthenticated] = false;
    g_Player[playerid][pAdminLevel] = ADMIN_LEVEL_NONE;
    g_Player[playerid][pSkin] = DEFAULT_PLAYER_SKIN;
    g_Player[playerid][pWorldSlot] = INVALID_WORLD_SLOT;
    g_Player[playerid][pTeam] = WORLD_TEAM_SPECTATOR;
    g_Player[playerid][pReady] = false;
    g_Player[playerid][pMatchDatabaseId] = 0;
    g_Player[playerid][pMatchKills] = 0;
    g_Player[playerid][pMatchDeaths] = 0;
    g_Player[playerid][pKills] = 0;
    g_Player[playerid][pDeaths] = 0;
    g_Player[playerid][pWins] = 0;
    g_Player[playerid][pLosses] = 0;
    g_Player[playerid][pLoginFailures] = 0;
    g_Player[playerid][pLoginLockedUntil] = 0;
    g_Player[playerid][pMuteUntil] = 0;
    g_Player[playerid][pUsername][0] = EOS;
    g_Player[playerid][pIpAddress][0] = EOS;
    g_Player[playerid][pPasswordHash][0] = EOS;
    return 1;
}

Player_BeginSession(playerid)
{
    Player_Reset(playerid, true);
    GetPlayerName(playerid, g_Player[playerid][pUsername], MAX_PLAYER_NAME + 1);
    GetPlayerIp(playerid, g_Player[playerid][pIpAddress], 46);
    SetPlayerColor(playerid, DEFAULT_PLAYER_COLOR);
    return g_Player[playerid][pSessionId];
}

Player_EndSession(playerid)
{
    if(g_Player[playerid][pAuthenticated] && g_Player[playerid][pDatabaseId] > 0 && g_DatabaseConnected)
    {
        new query[384];
        mysql_format(g_Database, query, sizeof(query),
            "UPDATE `players` SET `ip_address`='%e', `skin`=%d, `last_seen_at`=UTC_TIMESTAMP() WHERE `id`=%d LIMIT 1",
            g_Player[playerid][pIpAddress],
            g_Player[playerid][pSkin],
            g_Player[playerid][pDatabaseId]
        );
        mysql_tquery(g_Database, query);
    }

    Player_Reset(playerid, true);
    return 1;
}

Player_GetSession(playerid)
{
    return g_Player[playerid][pSessionId];
}

bool:Player_IsSessionValid(playerid, sessionId)
{
    return IsPlayerConnected(playerid) && g_Player[playerid][pSessionId] == sessionId;
}

bool:Player_IsAuthenticated(playerid)
{
    return g_Player[playerid][pAuthenticated];
}

bool:Player_HasAdminLevel(playerid, level)
{
    return IsPlayerAdmin(playerid) || g_Player[playerid][pAdminLevel] >= level;
}

Player_Authenticate(playerid)
{
    g_Player[playerid][pAuthenticated] = true;
    SetPlayerSkin(playerid, g_Player[playerid][pSkin]);
    SendSuccess(playerid, "Sesion iniciada correctamente.");
    Match_TryRestorePlayer(playerid);
    return 1;
}

Player_ShowAccount(playerid)
{
    new body[512];
    format(body, sizeof(body),
        "Cuenta\t%s\nID\t%d\nAdministrador\t%d\nKills\t%d\nDeaths\t%d\nVictorias\t%d\nDerrotas\t%d",
        g_Player[playerid][pUsername],
        g_Player[playerid][pDatabaseId],
        g_Player[playerid][pAdminLevel],
        g_Player[playerid][pKills],
        g_Player[playerid][pDeaths],
        g_Player[playerid][pWins],
        g_Player[playerid][pLosses]
    );
    ShowPlayerDialog(playerid, DIALOG_ACCOUNT, DIALOG_STYLE_TABLIST, "Cuenta", body, "Cerrar", "");
    return 1;
}
