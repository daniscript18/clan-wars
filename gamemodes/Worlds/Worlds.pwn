enum E_WORLD_DATA
{
    wDatabaseId,
    wVirtualWorld,
    wPrivacy,
    wStatus,
    wRoundsToWin,
    wPointsToWin,
    wMaxPlayers,
    wInterior,
    wDefaultMapId,
    wDefaultLoadoutId,
    wName[WORLD_NAME_LENGTH + 1],
    wPasswordHash[WORLD_PASSWORD_HASH_LENGTH],
    wTeamAlphaName[WORLD_TEAM_NAME_LENGTH + 1],
    wTeamBravoName[WORLD_TEAM_NAME_LENGTH + 1],
    wMapName[WORLD_NAME_LENGTH + 1],
    wLoadoutName[WORLD_NAME_LENGTH + 1],
    Float:wSpectatorX,
    Float:wSpectatorY,
    Float:wSpectatorZ,
    Float:wSpectatorA,
    Float:wAlphaX,
    Float:wAlphaY,
    Float:wAlphaZ,
    Float:wAlphaA,
    Float:wBravoX,
    Float:wBravoY,
    Float:wBravoZ,
    Float:wBravoA
};

new g_World[MAX_RUNTIME_WORLDS][E_WORLD_DATA];
new g_WorldCount = 0;
new g_WorldWeaponId[MAX_RUNTIME_WORLDS][MAX_LOADOUT_SLOTS];
new g_WorldWeaponAmmo[MAX_RUNTIME_WORLDS][MAX_LOADOUT_SLOTS];
new g_PlayerPendingWorld[MAX_PLAYERS];

World_ResetAll()
{
    g_WorldCount = 0;
    for(new worldSlot = 0; worldSlot < MAX_RUNTIME_WORLDS; worldSlot++)
    {
        g_World[worldSlot][wDatabaseId] = 0;
        g_World[worldSlot][wVirtualWorld] = 0;
        g_World[worldSlot][wPrivacy] = WORLD_PRIVACY_PUBLIC;
        g_World[worldSlot][wStatus] = WORLD_STATUS_IDLE;
        g_World[worldSlot][wRoundsToWin] = 0;
        g_World[worldSlot][wPointsToWin] = 0;
        g_World[worldSlot][wMaxPlayers] = 0;
        g_World[worldSlot][wInterior] = 0;
        g_World[worldSlot][wDefaultMapId] = 0;
        g_World[worldSlot][wDefaultLoadoutId] = 0;
        g_World[worldSlot][wName][0] = EOS;
        g_World[worldSlot][wPasswordHash][0] = EOS;
        g_World[worldSlot][wTeamAlphaName][0] = EOS;
        g_World[worldSlot][wTeamBravoName][0] = EOS;
        g_World[worldSlot][wMapName][0] = EOS;
        g_World[worldSlot][wLoadoutName][0] = EOS;
        g_World[worldSlot][wSpectatorX] = 0.0;
        g_World[worldSlot][wSpectatorY] = 0.0;
        g_World[worldSlot][wSpectatorZ] = 0.0;
        g_World[worldSlot][wSpectatorA] = 0.0;
        g_World[worldSlot][wAlphaX] = 0.0;
        g_World[worldSlot][wAlphaY] = 0.0;
        g_World[worldSlot][wAlphaZ] = 0.0;
        g_World[worldSlot][wAlphaA] = 0.0;
        g_World[worldSlot][wBravoX] = 0.0;
        g_World[worldSlot][wBravoY] = 0.0;
        g_World[worldSlot][wBravoZ] = 0.0;
        g_World[worldSlot][wBravoA] = 0.0;
        for(new slot = 0; slot < MAX_LOADOUT_SLOTS; slot++)
        {
            g_WorldWeaponId[worldSlot][slot] = 0;
            g_WorldWeaponAmmo[worldSlot][slot] = 0;
        }
    }
    return 1;
}

bool:World_IsValidSlot(worldSlot)
{
    return worldSlot >= 0 && worldSlot < g_WorldCount && g_World[worldSlot][wDatabaseId] > 0;
}

World_FindByDatabaseId(databaseId)
{
    for(new worldSlot = 0; worldSlot < g_WorldCount; worldSlot++)
    {
        if(g_World[worldSlot][wDatabaseId] == databaseId) return worldSlot;
    }
    return INVALID_WORLD_SLOT;
}

World_GetPlayerCount(worldSlot)
{
    new count = 0;
    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pAuthenticated] && g_Player[playerid][pWorldSlot] == worldSlot) count++;
    }
    return count;
}

World_LoadAll()
{
    World_ResetAll();
    print("[worlds] Loading worlds...");

    new query[2048], tail[256];
    format(query, sizeof(query), "SELECT w.`id`,w.`virtual_world_id`,w.`name`,COALESCE(w.`password_hash`,'') AS `password_hash`,w.`privacy`,w.`status`,w.`team_alpha_name`,w.`team_bravo_name`,w.`rounds_to_win`,w.`points_to_win`,w.`max_players`,");
    strcat(query, "COALESCE(d.`map_id`,0) AS `default_map_id`,COALESCE(d.`loadout_id`,0) AS `default_loadout_id`,COALESCE(m.`name`,'') AS `map_name`,COALESCE(m.`interior`,0) AS `interior`,COALESCE(m.`spectator_x`,0) AS `spectator_x`,COALESCE(m.`spectator_y`,0) AS `spectator_y`,COALESCE(m.`spectator_z`,10) AS `spectator_z`,COALESCE(m.`spectator_a`,0) AS `spectator_a`,", sizeof(query));
    strcat(query, "COALESCE(m.`alpha_x`,0) AS `alpha_x`,COALESCE(m.`alpha_y`,0) AS `alpha_y`,COALESCE(m.`alpha_z`,3) AS `alpha_z`,COALESCE(m.`alpha_a`,0) AS `alpha_a`,COALESCE(m.`bravo_x`,5) AS `bravo_x`,COALESCE(m.`bravo_y`,0) AS `bravo_y`,COALESCE(m.`bravo_z`,3) AS `bravo_z`,COALESCE(m.`bravo_a`,180) AS `bravo_a`,COALESCE(l.`name`,'') AS `loadout_name` ", sizeof(query));
    format(tail, sizeof(tail), "FROM `worlds` w LEFT JOIN `world_defaults` d ON d.`world_id`=w.`id` LEFT JOIN `maps` m ON m.`id`=d.`map_id` LEFT JOIN `loadouts` l ON l.`id`=d.`loadout_id` WHERE w.`enabled`=1 ORDER BY w.`id` ASC LIMIT %d", MAX_RUNTIME_WORLDS);
    strcat(query, tail, sizeof(query));
    mysql_tquery(g_Database, query, "World_OnLoaded");
    return 1;
}

forward World_OnLoaded();
public World_OnLoaded()
{
    new rows = cache_num_rows();
    if(rows > MAX_RUNTIME_WORLDS) rows = MAX_RUNTIME_WORLDS;

    for(new row = 0; row < rows; row++)
    {
        cache_get_value_name_int(row, "id", g_World[row][wDatabaseId]);
        cache_get_value_name_int(row, "virtual_world_id", g_World[row][wVirtualWorld]);
        cache_get_value_name(row, "name", g_World[row][wName], WORLD_NAME_LENGTH + 1);
        cache_get_value_name(row, "password_hash", g_World[row][wPasswordHash], WORLD_PASSWORD_HASH_LENGTH);
        cache_get_value_name_int(row, "privacy", g_World[row][wPrivacy]);
        cache_get_value_name_int(row, "status", g_World[row][wStatus]);
        cache_get_value_name(row, "team_alpha_name", g_World[row][wTeamAlphaName], WORLD_TEAM_NAME_LENGTH + 1);
        cache_get_value_name(row, "team_bravo_name", g_World[row][wTeamBravoName], WORLD_TEAM_NAME_LENGTH + 1);
        cache_get_value_name_int(row, "rounds_to_win", g_World[row][wRoundsToWin]);
        cache_get_value_name_int(row, "points_to_win", g_World[row][wPointsToWin]);
        cache_get_value_name_int(row, "max_players", g_World[row][wMaxPlayers]);
        cache_get_value_name_int(row, "default_map_id", g_World[row][wDefaultMapId]);
        cache_get_value_name_int(row, "default_loadout_id", g_World[row][wDefaultLoadoutId]);
        cache_get_value_name(row, "map_name", g_World[row][wMapName], WORLD_NAME_LENGTH + 1);
        cache_get_value_name(row, "loadout_name", g_World[row][wLoadoutName], WORLD_NAME_LENGTH + 1);
        cache_get_value_name_int(row, "interior", g_World[row][wInterior]);
        cache_get_value_name_float(row, "spectator_x", g_World[row][wSpectatorX]);
        cache_get_value_name_float(row, "spectator_y", g_World[row][wSpectatorY]);
        cache_get_value_name_float(row, "spectator_z", g_World[row][wSpectatorZ]);
        cache_get_value_name_float(row, "spectator_a", g_World[row][wSpectatorA]);
        cache_get_value_name_float(row, "alpha_x", g_World[row][wAlphaX]);
        cache_get_value_name_float(row, "alpha_y", g_World[row][wAlphaY]);
        cache_get_value_name_float(row, "alpha_z", g_World[row][wAlphaZ]);
        cache_get_value_name_float(row, "alpha_a", g_World[row][wAlphaA]);
        cache_get_value_name_float(row, "bravo_x", g_World[row][wBravoX]);
        cache_get_value_name_float(row, "bravo_y", g_World[row][wBravoY]);
        cache_get_value_name_float(row, "bravo_z", g_World[row][wBravoZ]);
        cache_get_value_name_float(row, "bravo_a", g_World[row][wBravoA]);
    }

    g_WorldCount = rows;
    mysql_tquery(g_Database,
        "SELECT w.`id` AS `world_id`,li.`slot`,li.`weapon_id`,li.`ammo` FROM `worlds` w INNER JOIN `world_defaults` d ON d.`world_id`=w.`id` INNER JOIN `loadout_items` li ON li.`loadout_id`=d.`loadout_id` WHERE w.`enabled`=1 ORDER BY w.`id`,li.`slot`",
        "World_OnLoadoutsLoaded"
    );
    return 1;
}

forward World_OnLoadoutsLoaded();
public World_OnLoadoutsLoaded()
{
    new rows = cache_num_rows();
    for(new row = 0; row < rows; row++)
    {
        new databaseId, loadoutSlot, weaponId, ammo;
        cache_get_value_name_int(row, "world_id", databaseId);
        cache_get_value_name_int(row, "slot", loadoutSlot);
        cache_get_value_name_int(row, "weapon_id", weaponId);
        cache_get_value_name_int(row, "ammo", ammo);

        new worldSlot = World_FindByDatabaseId(databaseId);
        if(!World_IsValidSlot(worldSlot)) continue;
        if(loadoutSlot < 1 || loadoutSlot > MAX_LOADOUT_SLOTS) continue;

        g_WorldWeaponId[worldSlot][loadoutSlot - 1] = weaponId;
        g_WorldWeaponAmmo[worldSlot][loadoutSlot - 1] = ammo;
    }

    g_ServerReady = true;
    printf("[server] Ready. Loaded %d world(s).", g_WorldCount);
    return 1;
}

World_ShowList(playerid)
{
    if(!Player_IsAuthenticated(playerid)) return 0;

    if(g_WorldCount == 0)
    {
        SendInfo(playerid, "No hay mundos disponibles todavia.");
        return 1;
    }

    static body[4096];
    format(body, sizeof(body), "Mundo\tJugadores\tAcceso\n");
    new line[128], privacy[16];
    for(new worldSlot = 0; worldSlot < g_WorldCount; worldSlot++)
    {
        switch(g_World[worldSlot][wPrivacy])
        {
            case WORLD_PRIVACY_PRIVATE: format(privacy, sizeof(privacy), "Privado");
            case WORLD_PRIVACY_ADMIN_ONLY: format(privacy, sizeof(privacy), "Admins");
            default: format(privacy, sizeof(privacy), "Publico");
        }
        format(line, sizeof(line), "%s\t%d/%d\t%s\n",
            g_World[worldSlot][wName],
            World_GetPlayerCount(worldSlot),
            g_World[worldSlot][wMaxPlayers],
            privacy
        );
        strcat(body, line, sizeof(body));
    }

    ShowPlayerDialog(playerid, DIALOG_WORLDS, DIALOG_STYLE_TABLIST_HEADERS, "Mundos", body, "Entrar", "Cerrar");
    return 1;
}

World_RequestJoin(playerid, worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return SendError(playerid, "Ese mundo ya no esta disponible.");
    if(g_World[worldSlot][wStatus] == WORLD_STATUS_DISABLED) return SendError(playerid, "Ese mundo esta deshabilitado.");
    if(World_GetPlayerCount(worldSlot) >= g_World[worldSlot][wMaxPlayers]) return SendError(playerid, "El mundo esta lleno.");

    if(g_World[worldSlot][wPrivacy] == WORLD_PRIVACY_ADMIN_ONLY && !Player_HasAdminLevel(playerid, ADMIN_LEVEL_MODERATOR))
        return SendError(playerid, "Este mundo esta reservado para administradores.");

    if(g_World[worldSlot][wPrivacy] == WORLD_PRIVACY_PRIVATE && strlen(g_World[worldSlot][wPasswordHash]) > 0)
    {
        g_PlayerPendingWorld[playerid] = worldSlot;
        ShowPlayerDialog(playerid, DIALOG_WORLD_PASSWORD, DIALOG_STYLE_PASSWORD, "Mundo privado", "Introduce la contrasena del mundo:", "Entrar", "Volver");
        return 1;
    }

    return World_Join(playerid, worldSlot);
}

World_VerifyPassword(playerid, const password[])
{
    new worldSlot = g_PlayerPendingWorld[playerid];
    if(!World_IsValidSlot(worldSlot)) return World_ShowList(playerid);

    bcrypt_verify(playerid, "World_OnPasswordVerified", password, g_World[worldSlot][wPasswordHash], "dd", Player_GetSession(playerid), worldSlot);
    return 1;
}

forward World_OnPasswordVerified(playerid, bool:success, sessionId, worldSlot);
public World_OnPasswordVerified(playerid, bool:success, sessionId, worldSlot)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;
    if(!World_IsValidSlot(worldSlot)) return World_ShowList(playerid);

    if(!success)
    {
        SendError(playerid, "Contrasena incorrecta.");
        return World_ShowList(playerid);
    }

    return World_Join(playerid, worldSlot);
}

World_Join(playerid, worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return 0;

    new currentWorld = g_Player[playerid][pWorldSlot];
    if(World_IsValidSlot(currentWorld))
    {
        if(currentWorld == worldSlot) return World_ShowTeams(playerid);
        if(!Match_CanLeaveWorld(playerid)) return SendError(playerid, "No puedes cambiar de mundo durante una partida activa.");
        Match_OnPlayerLeaveWorld(playerid);
    }

    g_Player[playerid][pWorldSlot] = worldSlot;
    g_Player[playerid][pTeam] = WORLD_TEAM_SPECTATOR;
    SetPlayerVirtualWorld(playerid, g_World[worldSlot][wVirtualWorld]);
    SetPlayerInterior(playerid, g_World[worldSlot][wInterior]);
    SetPlayerColor(playerid, SPECTATOR_COLOR);
    TogglePlayerSpectating(playerid, true);
    InterpolateCameraPos(playerid,
        g_World[worldSlot][wSpectatorX], g_World[worldSlot][wSpectatorY], g_World[worldSlot][wSpectatorZ],
        g_World[worldSlot][wAlphaX], g_World[worldSlot][wAlphaY], g_World[worldSlot][wAlphaZ] + 10.0,
        2500, CAMERA_MOVE
    );
    InterpolateCameraLookAt(playerid,
        g_World[worldSlot][wAlphaX], g_World[worldSlot][wAlphaY], g_World[worldSlot][wAlphaZ],
        g_World[worldSlot][wBravoX], g_World[worldSlot][wBravoY], g_World[worldSlot][wBravoZ],
        2500, CAMERA_MOVE
    );
    World_ShowTeams(playerid);
    return 1;
}

World_ShowTeams(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return World_ShowList(playerid);

    new body[192];
    format(body, sizeof(body), "Espectador\n%s\n%s", g_World[worldSlot][wTeamAlphaName], g_World[worldSlot][wTeamBravoName]);
    ShowPlayerDialog(playerid, DIALOG_TEAMS, DIALOG_STYLE_LIST, "Selecciona equipo", body, "Seleccionar", "Mundos");
    return 1;
}

World_SelectTeam(playerid, team)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return World_ShowList(playerid);
    if(team < WORLD_TEAM_SPECTATOR || team > WORLD_TEAM_BRAVO) return 0;
    if(!Match_CanSelectTeam(playerid, team)) return SendError(playerid, "No puedes cambiar de equipo durante una partida activa.");

    g_Player[playerid][pTeam] = team;
    Match_OnPlayerTeamChanged(playerid);
    if(team == WORLD_TEAM_SPECTATOR)
    {
        SetPlayerColor(playerid, SPECTATOR_COLOR);
        TogglePlayerSpectating(playerid, true);
        return 1;
    }

    TogglePlayerSpectating(playerid, false);
    World_SetSpawnInfo(playerid);
    SpawnPlayer(playerid);
    return 1;
}

World_Leave(playerid)
{
    if(!Match_CanLeaveWorld(playerid)) return SendError(playerid, "No puedes abandonar el mundo durante una partida activa.");
    Match_OnPlayerLeaveWorld(playerid);

    g_Player[playerid][pWorldSlot] = INVALID_WORLD_SLOT;
    g_Player[playerid][pTeam] = WORLD_TEAM_SPECTATOR;
    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    TogglePlayerSpectating(playerid, true);
    SetPlayerColor(playerid, DEFAULT_PLAYER_COLOR);
    return World_ShowList(playerid);
}

World_SetSpawnInfo(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return 0;

    if(g_Player[playerid][pTeam] == WORLD_TEAM_ALPHA)
    {
        SetSpawnInfo(playerid, NO_TEAM, g_Player[playerid][pSkin],
            g_World[worldSlot][wAlphaX], g_World[worldSlot][wAlphaY], g_World[worldSlot][wAlphaZ], g_World[worldSlot][wAlphaA],
            0, 0, 0, 0, 0, 0
        );
        return 1;
    }

    if(g_Player[playerid][pTeam] == WORLD_TEAM_BRAVO)
    {
        SetSpawnInfo(playerid, NO_TEAM, g_Player[playerid][pSkin],
            g_World[worldSlot][wBravoX], g_World[worldSlot][wBravoY], g_World[worldSlot][wBravoZ], g_World[worldSlot][wBravoA],
            0, 0, 0, 0, 0, 0
        );
        return 1;
    }
    return 0;
}

World_SpawnPlayer(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return 0;

    SetPlayerVirtualWorld(playerid, g_World[worldSlot][wVirtualWorld]);
    SetPlayerInterior(playerid, g_World[worldSlot][wInterior]);
    SetPlayerSkin(playerid, g_Player[playerid][pSkin]);
    ResetPlayerWeapons(playerid);
    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);

    if(g_Player[playerid][pTeam] == WORLD_TEAM_ALPHA)
    {
        SetPlayerColor(playerid, TEAM_ALPHA_COLOR);
        SetPlayerPos(playerid, g_World[worldSlot][wAlphaX], g_World[worldSlot][wAlphaY], g_World[worldSlot][wAlphaZ]);
        SetPlayerFacingAngle(playerid, g_World[worldSlot][wAlphaA]);
    }
    else if(g_Player[playerid][pTeam] == WORLD_TEAM_BRAVO)
    {
        SetPlayerColor(playerid, TEAM_BRAVO_COLOR);
        SetPlayerPos(playerid, g_World[worldSlot][wBravoX], g_World[worldSlot][wBravoY], g_World[worldSlot][wBravoZ]);
        SetPlayerFacingAngle(playerid, g_World[worldSlot][wBravoA]);
    }
    else
    {
        TogglePlayerSpectating(playerid, true);
        return 1;
    }

    for(new slot = 0; slot < MAX_LOADOUT_SLOTS; slot++)
    {
        if(g_WorldWeaponId[worldSlot][slot] > 0 && g_WorldWeaponAmmo[worldSlot][slot] > 0)
            GivePlayerWeapon(playerid, g_WorldWeaponId[worldSlot][slot], g_WorldWeaponAmmo[worldSlot][slot]);
    }
    SetCameraBehindPlayer(playerid);
    return 1;
}

World_SendMessage(worldSlot, color, const message[])
{
    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pAuthenticated] && g_Player[playerid][pWorldSlot] == worldSlot)
            SendClientMessage(playerid, color, message);
    }
    return 1;
}

World_SendTeamMessage(worldSlot, team, color, const message[])
{
    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pAuthenticated] && g_Player[playerid][pWorldSlot] == worldSlot && g_Player[playerid][pTeam] == team)
            SendClientMessage(playerid, color, message);
    }
    return 1;
}
