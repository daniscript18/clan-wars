public OnGameModeInit()
{
    print("----------------------------------------");
    print(" Clan Wars - booting");
    print("----------------------------------------");

    bcrypt_set_thread_limit(2);
    UsePlayerPedAnims();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    EnableStuntBonusForAll(false);
    DisableInteriorEnterExits();

    if(!Database_Connect())
    {
        SendRconCommand("exit");
        return 0;
    }

    Database_RunMigrations();
    return 1;
}

public OnGameModeExit()
{
    foreach(new playerid : Player)
    {
        Player_EndSession(playerid);
    }
    Database_Disconnect();
    return 1;
}

public OnPlayerConnect(playerid)
{
    if(!Database_IsReady())
    {
        Player_BeginSession(playerid);
        SendError(playerid, "El servidor todavia esta iniciando la base de datos. Reconecta en unos segundos.");
        KickPlayerDelayed(playerid, 900);
        return 1;
    }

    Auth_Begin(playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason
    Match_OnPlayerDisconnect(playerid);
    Player_EndSession(playerid);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if(!Player_IsAuthenticated(playerid)) return 1;
    if(!World_IsValidSlot(g_Player[playerid][pWorldSlot])) return 1;
    World_SpawnPlayer(playerid);
    Match_OnPlayerSpawn(playerid);
    return 1;
}

public OnPlayerText(playerid, text[])
{
    if(!Player_IsAuthenticated(playerid)) return 0;

    if(g_Player[playerid][pMuteUntil] > 0)
    {
        if(g_Player[playerid][pMuteUntil] == 2147483647 || g_Player[playerid][pMuteUntil] > gettime())
        {
            SendError(playerid, "Estas silenciado y no puedes usar el chat.");
            return 0;
        }
        g_Player[playerid][pMuteUntil] = 0;
    }

    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return 0;

    new playerName[MAX_PLAYER_NAME + 1], message[256], content[144];
    GetPlayerNameSafe(playerid, playerName, sizeof(playerName));

    if(text[0] == '@')
    {
        if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_MODERATOR)) return 0;
        strmid(content, text, 1, strlen(text), sizeof(content));
        format(message, sizeof(message), "[ADMIN] %s: %s", playerName, content);
        foreach(new adminid : Player)
        {
            if(Player_IsAuthenticated(adminid) && Player_HasAdminLevel(adminid, ADMIN_LEVEL_MODERATOR))
                SendClientMessage(adminid, 0xF39C12FF, message);
        }
        return 0;
    }

    if(text[0] == '#')
    {
        if(g_Player[playerid][pTeam] == WORLD_TEAM_SPECTATOR) return 0;
        strmid(content, text, 1, strlen(text), sizeof(content));
        format(message, sizeof(message), "[EQUIPO] %s: %s", playerName, content);
        World_SendTeamMessage(worldSlot, g_Player[playerid][pTeam], 0xAED6F1FF, message);
        return 0;
    }

    if(text[0] == '!')
    {
        strmid(content, text, 1, strlen(text), sizeof(content));
        format(message, sizeof(message), "%s: %s", playerName, content);
    }
    else format(message, sizeof(message), "%s: %s", playerName, text);

    World_SendMessage(worldSlot, 0xFFFFFFFF, message);
    return 0;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    #pragma unused reason
    if(Match_OnPlayerDeath(playerid, killerid)) return 1;

    if(Player_IsAuthenticated(playerid) && World_IsValidSlot(g_Player[playerid][pWorldSlot]) && g_Player[playerid][pTeam] != WORLD_TEAM_SPECTATOR)
        SetTimerEx("Server_RespawnPlayer", MATCH_RESPAWN_DELAY_MS, false, "dd", playerid, Player_GetSession(playerid));
    return 1;
}

forward Server_RespawnPlayer(playerid, sessionId);
public Server_RespawnPlayer(playerid, sessionId)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;
    if(!Player_IsAuthenticated(playerid)) return 1;
    if(!World_IsValidSlot(g_Player[playerid][pWorldSlot])) return 1;
    if(g_Player[playerid][pTeam] == WORLD_TEAM_SPECTATOR) return 1;
    SpawnPlayer(playerid);
    return 1;
}
