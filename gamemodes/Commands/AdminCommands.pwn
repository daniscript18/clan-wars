cmd:setadmin(playerid, params[])
{
    if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_ROOT)) return SendError(playerid, "No tienes permisos para usar este comando.");

    new targetid, level;
    if(sscanf(params, "ui", targetid, level)) return SendInfo(playerid, "Uso: /setadmin [jugador] [0-4]");
    if(!IsPlayerConnected(targetid) || !Player_IsAuthenticated(targetid)) return SendError(playerid, "Jugador no disponible.");
    if(level < ADMIN_LEVEL_NONE || level > ADMIN_LEVEL_ROOT) return SendError(playerid, "Nivel invalido.");

    g_Player[targetid][pAdminLevel] = level;
    new query[192];
    mysql_format(g_Database, query, sizeof(query), "UPDATE `players` SET `admin_level`=%d WHERE `id`=%d LIMIT 1", level, g_Player[targetid][pDatabaseId]);
    mysql_tquery(g_Database, query);
    return SendSuccess(playerid, "Nivel administrativo actualizado.");
}

cmd:kick(playerid, params[])
{
    if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_MODERATOR)) return SendError(playerid, "No tienes permisos para usar este comando.");

    new targetid, reason[96];
    if(sscanf(params, "uS(Sin especificar)[96]", targetid, reason)) return SendInfo(playerid, "Uso: /kick [jugador] [motivo]");
    if(!IsPlayerConnected(targetid)) return SendError(playerid, "Jugador no disponible.");

    new message[192], adminName[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1];
    GetPlayerNameSafe(playerid, adminName, sizeof(adminName));
    GetPlayerNameSafe(targetid, targetName, sizeof(targetName));
    format(message, sizeof(message), "%s expulso a %s. Motivo: %s", adminName, targetName, reason);
    SendClientMessageToAll(0xE67E22FF, message);
    KickPlayerDelayed(targetid, 650);
    return 1;
}

cmd:ban(playerid, params[])
{
    if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_ADMIN)) return SendError(playerid, "No tienes permisos para usar este comando.");

    new targetid, minutes, reason[96];
    if(sscanf(params, "uiS(Sin especificar)[96]", targetid, minutes, reason)) return SendInfo(playerid, "Uso: /ban [jugador] [minutos, 0=permanente] [motivo]");
    if(!IsPlayerConnected(targetid)) return SendError(playerid, "Jugador no disponible.");
    if(minutes < 0) return SendError(playerid, "La duracion no puede ser negativa.");

    return Admin_IssuePunishment(playerid, targetid, "ban", minutes <= 0 ? 0 : minutes * 60, reason);
}

cmd:mute(playerid, params[])
{
    if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_MODERATOR)) return SendError(playerid, "No tienes permisos para usar este comando.");

    new targetid, minutes, reason[96];
    if(sscanf(params, "uiS(Sin especificar)[96]", targetid, minutes, reason)) return SendInfo(playerid, "Uso: /mute [jugador] [minutos, 0=permanente] [motivo]");
    if(!IsPlayerConnected(targetid)) return SendError(playerid, "Jugador no disponible.");
    if(minutes < 0) return SendError(playerid, "La duracion no puede ser negativa.");

    return Admin_IssuePunishment(playerid, targetid, "mute", minutes <= 0 ? 0 : minutes * 60, reason);
}

cmd:unmute(playerid, params[])
{
    if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_MODERATOR)) return SendError(playerid, "No tienes permisos para usar este comando.");

    new targetid;
    if(sscanf(params, "u", targetid)) return SendInfo(playerid, "Uso: /unmute [jugador]");
    if(!IsPlayerConnected(targetid)) return SendError(playerid, "Jugador no disponible.");
    return Admin_RevokeActiveMute(playerid, targetid);
}


cmd:cancelmatch(playerid, params[])
{
    if(!Player_HasAdminLevel(playerid, ADMIN_LEVEL_ADMIN)) return SendError(playerid, "No tienes permisos para usar este comando.");

    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return SendError(playerid, "Debes estar dentro del mundo que quieres administrar.");
    if(!Match_IsWorldActive(worldSlot)) return SendError(playerid, "No hay una partida activa en este mundo.");

    new reason[96];
    if(sscanf(params, "S(Cancelada por un administrador)[96]", reason)) return 0;
    return Match_Cancel(worldSlot, reason);
}
