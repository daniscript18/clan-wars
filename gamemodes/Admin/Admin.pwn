Admin_IssuePunishment(playerid, targetid, const type[], durationSeconds, const reason[])
{
    if(!Player_IsAuthenticated(targetid)) return SendError(playerid, "El jugador objetivo no esta autenticado.");

    new expiresSql[64];
    if(durationSeconds <= 0) format(expiresSql, sizeof(expiresSql), "NULL");
    else format(expiresSql, sizeof(expiresSql), "FROM_UNIXTIME(%d)", gettime() + durationSeconds);

    new query[1024];
    mysql_format(g_Database, query, sizeof(query),
        "INSERT INTO `punishments` (`player_id`,`issued_by_player_id`,`type`,`reason`,`expires_at`) VALUES (%d,%d,'%e','%e',%s)",
        g_Player[targetid][pDatabaseId],
        g_Player[playerid][pDatabaseId] > 0 ? g_Player[playerid][pDatabaseId] : 0,
        type,
        reason,
        expiresSql
    );
    mysql_tquery(g_Database, query);

    new adminName[MAX_PLAYER_NAME + 1], targetName[MAX_PLAYER_NAME + 1], message[256];
    GetPlayerNameSafe(playerid, adminName, sizeof(adminName));
    GetPlayerNameSafe(targetid, targetName, sizeof(targetName));
    format(message, sizeof(message), "%s aplico %s a %s. Motivo: %s", adminName, type, targetName, reason);
    SendClientMessageToAll(0xE67E22FF, message);

    if(!strcmp(type, "ban", true))
    {
        KickPlayerDelayed(targetid, 650);
    }
    else if(!strcmp(type, "mute", true))
    {
        g_Player[targetid][pMuteUntil] = durationSeconds <= 0 ? 2147483647 : gettime() + durationSeconds;
    }
    return 1;
}

Admin_RevokeActiveMute(playerid, targetid)
{
    if(!Player_IsAuthenticated(targetid)) return SendError(playerid, "El jugador objetivo no esta autenticado.");

    new query[512];
    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `punishments` SET `revoked_at`=UTC_TIMESTAMP(),`revoked_by_player_id`=%d WHERE `player_id`=%d AND `type`='mute' AND `revoked_at` IS NULL AND (`expires_at` IS NULL OR `expires_at`>UTC_TIMESTAMP())",
        g_Player[playerid][pDatabaseId], g_Player[targetid][pDatabaseId]
    );
    mysql_tquery(g_Database, query);
    g_Player[targetid][pMuteUntil] = 0;
    return SendSuccess(playerid, "Mute removido.");
}
