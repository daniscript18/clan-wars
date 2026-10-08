Auth_Begin(playerid)
{
    new sessionId = Player_BeginSession(playerid);

    TogglePlayerSpectating(playerid, true);
    InterpolateCameraPos(playerid, 1481.0, -1750.0, 60.0, 1540.0, -1675.0, 80.0, 15000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, 1481.0, -1750.0, 20.0, 1540.0, -1675.0, 20.0, 15000, CAMERA_MOVE);

    new query[1536], tail[256];
    format(query, sizeof(query), "SELECT p.`id`,p.`password_hash`,p.`admin_level`,p.`skin`,p.`failed_login_count`,COALESCE(UNIX_TIMESTAMP(p.`locked_until`),0) AS `locked_until`,");
    strcat(query, "COALESCE(s.`kills`,0) AS `kills`,COALESCE(s.`deaths`,0) AS `deaths`,COALESCE(s.`wins`,0) AS `wins`,COALESCE(s.`losses`,0) AS `losses`,", sizeof(query));
    strcat(query, "COALESCE((SELECT CASE WHEN pu.`expires_at` IS NULL THEN 2147483647 ELSE UNIX_TIMESTAMP(pu.`expires_at`) END FROM `punishments` pu WHERE pu.`player_id`=p.`id` AND pu.`type`='mute' AND pu.`revoked_at` IS NULL AND (pu.`expires_at` IS NULL OR pu.`expires_at`>UTC_TIMESTAMP()) ORDER BY pu.`id` DESC LIMIT 1),0) AS `mute_until`,", sizeof(query));
    strcat(query, "COALESCE((SELECT pu.`reason` FROM `punishments` pu WHERE pu.`player_id`=p.`id` AND pu.`type`='ban' AND pu.`revoked_at` IS NULL AND (pu.`expires_at` IS NULL OR pu.`expires_at`>UTC_TIMESTAMP()) ORDER BY pu.`id` DESC LIMIT 1),'') AS `ban_reason` ", sizeof(query));
    mysql_format(g_Database, tail, sizeof(tail), "FROM `players` p LEFT JOIN `player_stats` s ON s.`player_id`=p.`id` WHERE p.`username`='%e' LIMIT 1", g_Player[playerid][pUsername]);
    strcat(query, tail, sizeof(query));
    mysql_tquery(g_Database, query, "Auth_OnAccountLoaded", "dd", playerid, sessionId);
    return 1;
}

forward Auth_OnAccountLoaded(playerid, sessionId);
public Auth_OnAccountLoaded(playerid, sessionId)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;

    if(cache_num_rows() == 0)
    {
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Crear cuenta",
            "No existe una cuenta con este nombre.\n\nCrea una contrasena de al menos 8 caracteres:",
            "Registrar", "Salir"
        );
        return 1;
    }

    new banReason[128];
    cache_get_value_name_int(0, "id", g_Player[playerid][pDatabaseId]);
    cache_get_value_name(0, "password_hash", g_Player[playerid][pPasswordHash], BCRYPT_HASH_LENGTH);
    cache_get_value_name_int(0, "admin_level", g_Player[playerid][pAdminLevel]);
    cache_get_value_name_int(0, "skin", g_Player[playerid][pSkin]);
    cache_get_value_name_int(0, "failed_login_count", g_Player[playerid][pLoginFailures]);
    cache_get_value_name_int(0, "locked_until", g_Player[playerid][pLoginLockedUntil]);
    cache_get_value_name_int(0, "kills", g_Player[playerid][pKills]);
    cache_get_value_name_int(0, "deaths", g_Player[playerid][pDeaths]);
    cache_get_value_name_int(0, "wins", g_Player[playerid][pWins]);
    cache_get_value_name_int(0, "losses", g_Player[playerid][pLosses]);
    cache_get_value_name_int(0, "mute_until", g_Player[playerid][pMuteUntil]);
    cache_get_value_name(0, "ban_reason", banReason, sizeof(banReason));

    if(strlen(banReason) > 0)
    {
        new message[192];
        format(message, sizeof(message), "Estas expulsado del servidor. Motivo: %s", banReason);
        SendError(playerid, message);
        KickPlayerDelayed(playerid);
        return 1;
    }

    if(g_Player[playerid][pLoginLockedUntil] > gettime())
    {
        new message[192];
        format(message, sizeof(message), "Demasiados intentos fallidos. Intenta de nuevo en %d segundos.", g_Player[playerid][pLoginLockedUntil] - gettime());
        SendError(playerid, message);
        KickPlayerDelayed(playerid, 900);
        return 1;
    }

    if(g_Player[playerid][pLoginLockedUntil] > 0)
    {
        g_Player[playerid][pLoginLockedUntil] = 0;
        g_Player[playerid][pLoginFailures] = 0;
        new resetQuery[192];
        mysql_format(g_Database, resetQuery, sizeof(resetQuery), "UPDATE `players` SET `failed_login_count`=0,`locked_until`=NULL WHERE `id`=%d LIMIT 1", g_Player[playerid][pDatabaseId]);
        mysql_tquery(g_Database, resetQuery);
    }

    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Iniciar sesion", "Introduce la contrasena de tu cuenta:", "Entrar", "Salir");
    return 1;
}

Auth_HandleLogin(playerid, const password[])
{
    if(strlen(password) < 1 || strlen(password) > PLAYER_PASSWORD_MAX)
        return ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Iniciar sesion", "Contrasena invalida.\n\nIntentalo nuevamente:", "Entrar", "Salir");

    bcrypt_verify(playerid, "Auth_OnPasswordVerified", password, g_Player[playerid][pPasswordHash], "d", Player_GetSession(playerid));
    return 1;
}

forward Auth_OnPasswordVerified(playerid, bool:success, sessionId);
public Auth_OnPasswordVerified(playerid, bool:success, sessionId)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;

    if(!success)
    {
        g_Player[playerid][pLoginFailures]++;
        new query[512];

        if(g_Player[playerid][pLoginFailures] >= LOGIN_MAX_FAILURES)
        {
            g_Player[playerid][pLoginLockedUntil] = gettime() + LOGIN_LOCK_SECONDS;
            mysql_format(g_Database, query, sizeof(query),
                "UPDATE `players` SET `failed_login_count`=%d,`locked_until`=FROM_UNIXTIME(%d) WHERE `id`=%d LIMIT 1",
                g_Player[playerid][pLoginFailures], g_Player[playerid][pLoginLockedUntil], g_Player[playerid][pDatabaseId]
            );
            mysql_tquery(g_Database, query);
            SendError(playerid, "Demasiados intentos fallidos. La cuenta fue bloqueada temporalmente.");
            KickPlayerDelayed(playerid, 900);
            return 1;
        }

        mysql_format(g_Database, query, sizeof(query), "UPDATE `players` SET `failed_login_count`=%d WHERE `id`=%d LIMIT 1", g_Player[playerid][pLoginFailures], g_Player[playerid][pDatabaseId]);
        mysql_tquery(g_Database, query);

        new body[160];
        format(body, sizeof(body), "Contrasena incorrecta. Intentos: %d/%d\n\nIntentalo nuevamente:", g_Player[playerid][pLoginFailures], LOGIN_MAX_FAILURES);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Iniciar sesion", body, "Entrar", "Salir");
        return 1;
    }

    g_Player[playerid][pLoginFailures] = 0;
    g_Player[playerid][pLoginLockedUntil] = 0;

    new query[384];
    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `players` SET `ip_address`='%e',`failed_login_count`=0,`locked_until`=NULL,`last_login_at`=UTC_TIMESTAMP(),`last_seen_at`=UTC_TIMESTAMP() WHERE `id`=%d LIMIT 1",
        g_Player[playerid][pIpAddress], g_Player[playerid][pDatabaseId]
    );
    mysql_tquery(g_Database, query);
    return Player_Authenticate(playerid);
}

Auth_HandleRegister(playerid, const password[])
{
    new length = strlen(password);
    if(length < PLAYER_PASSWORD_MIN || length > PLAYER_PASSWORD_MAX)
    {
        new body[192];
        format(body, sizeof(body), "La contrasena debe tener entre %d y %d caracteres.\n\nIntentalo nuevamente:", PLAYER_PASSWORD_MIN, PLAYER_PASSWORD_MAX);
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, "Crear cuenta", body, "Registrar", "Salir");
        return 1;
    }

    bcrypt_hash(playerid, "Auth_OnPasswordHashed", password, BCRYPT_WORK_FACTOR, "d", Player_GetSession(playerid));
    return 1;
}

forward Auth_OnPasswordHashed(playerid, sessionId);
public Auth_OnPasswordHashed(playerid, sessionId)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;

    new hash[BCRYPT_HASH_LENGTH];
    bcrypt_get_hash(hash, sizeof(hash));

    new query[768];
    mysql_format(g_Database, query, sizeof(query),
        "INSERT INTO `players` (`username`,`password_hash`,`ip_address`,`skin`,`last_login_at`,`last_seen_at`) VALUES ('%e','%e','%e',%d,UTC_TIMESTAMP(),UTC_TIMESTAMP())",
        g_Player[playerid][pUsername], hash, g_Player[playerid][pIpAddress], DEFAULT_PLAYER_SKIN
    );
    mysql_tquery(g_Database, query, "Auth_OnAccountCreated", "dd", playerid, sessionId);
    return 1;
}

forward Auth_OnAccountCreated(playerid, sessionId);
public Auth_OnAccountCreated(playerid, sessionId)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;

    new databaseId = cache_insert_id();
    if(databaseId <= 0)
    {
        SendError(playerid, "No se pudo crear la cuenta. Reconecta e intentalo nuevamente.");
        KickPlayerDelayed(playerid, 900);
        return 1;
    }

    g_Player[playerid][pDatabaseId] = databaseId;
    g_Player[playerid][pSkin] = DEFAULT_PLAYER_SKIN;
    g_Player[playerid][pAdminLevel] = ADMIN_LEVEL_NONE;

    new query[160];
    mysql_format(g_Database, query, sizeof(query), "INSERT IGNORE INTO `player_stats` (`player_id`) VALUES (%d)", databaseId);
    mysql_tquery(g_Database, query);
    return Player_Authenticate(playerid);
}
