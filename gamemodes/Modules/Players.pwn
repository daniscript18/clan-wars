enum _:E_ADMIN_LEVELS {
    ADMIN_LEVEL_NONE,
    ADMIN_LEVEL_HELPER,
    ADMIN_LEVEL_MODERATOR,
    ADMIN_LEVEL_ADMINISTRADOR,
    ADMIN_LEVEL_BOSS
};

new AdminLevels[5][2][24] = {
    { "Usuario", "usuario" },
    { "Ayudante", "ayudante" },
    { "Moderador", "moderador" },
    { "Administrador", "administrador" },
    { "Líder", "líder" }
};

enum E_PLAYER_INFO {
    pId,
    pIp[15],
    pUsername[24],
    pPassword[18],
    pAdmin,

    pWorld,
    pTeam
};

new PlayerInfo[MAX_PLAYERS][E_PLAYER_INFO];

ClearPlayer(playerid) {
    PlayerInfo[playerid][pId] = -1;
    PlayerInfo[playerid][pIp] = -1;
    PlayerInfo[playerid][pUsername] = -1,
    PlayerInfo[playerid][pPassword] = -1,
    PlayerInfo[playerid][pAdmin] = ADMIN_LEVEL_NONE;
    
    PlayerInfo[playerid][pWorld] = -1;
    PlayerInfo[playerid][pTeam] = -1;
    SetPVarInt(playerid, "EnteredPlayer", 0);
    SetPVarInt(playerid, "Mute", -1);
    return true;
}

forward ExistPlayer(playerid);
public ExistPlayer(playerid) {
    new Str[256];
    if(cache_num_rows() != 0) {
        cache_get_value_name_int(0, "Id", PlayerInfo[playerid][pId]);
        cache_get_value_name(0, "Password", PlayerInfo[playerid][pPassword], 18);
        if(!IsBanned(PlayerInfo[playerid][pId])) {
            format(Str, sizeof(Str), "La cuenta (%s) fue encontrada en la base de datos.\nPor favor escribe tu contraseña para entrar.", PlayerInfo[playerid][pUsername]);
            ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Cuenta encontrada", Str, "Entrar", "Salir");
        } else {
            new Query[128], time, reason[32], datetime[32], id[2];
            mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `bans` WHERE `PlayerId` = %d", PlayerInfo[playerid][pId]);
            mysql_query(Database, Query);
            cache_get_value_name_int(0, "PlayerId", id[0]);
            cache_get_value_name_int(0, "AdminId", id[1]);
            cache_get_value_name(0, "Reason", reason);
            cache_get_value_name(0, "DateTime", datetime);
            cache_get_value_name_int(0, "Time", time);
            if(time > 0 && gettime() >= time) {
                format(Str, sizeof(Str), "La cuenta (%s) fue encontrada en la base de datos.\nPor favor escribe tu contraseña para entrar.", PlayerInfo[playerid][pUsername]);
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Cuenta encontrada", Str, "Entrar", "Salir");
                mysql_format(Database, Query, sizeof(Query), "DELETE FROM `bans` WHERE `PlayerId` = %d", PlayerInfo[playerid][pId]);
                mysql_query(Database, Query, false);
            } else {
                format(Str, sizeof(Str), "Razón: %s\n", reason);
                format(Str, sizeof(Str), "%sAdministrador: %s\n", Str, GetPlayerNameDB(id[1]));
                format(Str, sizeof(Str), "%sFecha de bloqueo: %s\n", Str, datetime);
                if(time == -1) format(Str, sizeof(Str), "%sTiempo restante: Bloqueo permanente", Str);
                else format(Str, sizeof(Str), "%sTiempo restante: %s", Str, FormatTimeLeft(gettime(), time));
                ShowPlayerDialog(playerid, DIALOG_NO_USE, DIALOG_STYLE_MSGBOX, "Tu cuenta está bloqueada", Str, "Cerrar", "");
                SetTimerEx("KickEx", 1000, false, "d", playerid);
            }
        }
    } else {
        format(Str, sizeof(Str), "La cuenta (%s) no fue encontrada en la base de datos.\nPor favor escribe una contraseña para entrar.", PlayerInfo[playerid][pUsername]);
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cuenta no encontrada", Str, "Entrar", "Salir");
    }
    PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/s/icpjs24wznu79p2wcyswn/Wasted.mp3?rlkey=mxpfqwi1a5ewo6bf1ti8wmrj3&dl=0");
    ClearChat(playerid);
    return true;
}

forward LoadPlayer(playerid);
public LoadPlayer(playerid) {
    if(cache_num_rows() != 0) {
        new Ip[15];

        GetPlayerIp(playerid, Ip, sizeof(Ip));
        format(PlayerInfo[playerid][pIp], 15, "%s", Ip);
        GetPlayerName(playerid, PlayerInfo[playerid][pUsername], 24);
        cache_get_value_name_int(0, "Admin", PlayerInfo[playerid][pAdmin]);

        new Query[128];
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `mutes` WHERE `PlayerId` = %d", PlayerInfo[playerid][pId]);
        mysql_query(Database, Query);
        if(cache_num_rows() != 0) {
            new Mute;
            cache_get_value_name_int(0, "Time", Mute);
            SetPVarInt(playerid, "Mute", Mute);
        } else SetPVarInt(playerid, "Mute", -1);

	    ShowWorlds(playerid);
    }
    return true;
}

CreatePlayer(playerid) {
    new Query[180], Ip[15];

    GetPlayerIp(playerid, Ip, sizeof(Ip));
    GetPlayerName(playerid, PlayerInfo[playerid][pUsername], 24);
    PlayerInfo[playerid][pAdmin] = 0;

    mysql_format(Database, Query, sizeof(Query), "INSERT INTO `players` (`Ip`, `Username`, `Password`, `Admin`) VALUES ('%s', '%s', '%s', %d)", Ip, PlayerInfo[playerid][pUsername], PlayerInfo[playerid][pPassword], PlayerInfo[playerid][pAdmin]);
    mysql_query(Database, Query);

    PlayerInfo[playerid][pId] = cache_insert_id();
    format(PlayerInfo[playerid][pIp], 15, "%s", Ip);

	ShowWorlds(playerid);
    return true;
}

SavePlayer(playerid) {
    new Query[180];
    mysql_format(Database, Query, sizeof(Query), "UPDATE `players` SET `Ip` = '%s', `Admin` = %d WHERE `Username` = '%s'", PlayerInfo[playerid][pIp], PlayerInfo[playerid][pAdmin], PlayerInfo[playerid][pUsername]);
    mysql_query(Database, Query, false);
    return true;
}

GetPlayerNameEx(playerid) {
    new Name[24];
    GetPlayerName(playerid, Name, sizeof(Name));
    return Name;
}

GetPlayerNameDB(databaseId) {
    new Name[24], Query[128];
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Id` = %d", databaseId);
    mysql_query(Database, Query);
    cache_get_value_name(0, "Username", Name);
    return Name;
}

AdminChat(playerid, const text[]) {
    new Str[512];
    if(text[0] == '@') format(Str, sizeof(Str), "@ %s: %s", GetPlayerNameEx(playerid), text[1]);
    else format(Str, sizeof(Str), "@ %s: %s", GetPlayerNameEx(playerid), text);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[playerid][pAdmin] > ADMIN_LEVEL_NONE || IsPlayerAdmin(playerid)) {
            SendClientMessage(i, -1, Str);
        }
    }
    return false;
}

WorldChat(playerid, const text[]) {
    new Str[512];
    if(text[0] == '!') format(Str, sizeof(Str), "! %s: %s", GetPlayerNameEx(playerid), text[1]);
    else format(Str, sizeof(Str), "! %s: %s", GetPlayerNameEx(playerid), text);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == PlayerInfo[playerid][pWorld]) {
            SendClientMessage(i, -1, Str);
        }
    }
    return false;
}

TeamChat(playerid, const text[]) {
    new Str[512];
    if(text[0] == '#') format(Str, sizeof(Str), "# %s: %s", GetPlayerNameEx(playerid), text[1]);
    else format(Str, sizeof(Str), "# %s: %s", GetPlayerNameEx(playerid), text);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == PlayerInfo[playerid][pWorld] && PlayerInfo[i][pTeam] == PlayerInfo[playerid][pTeam]) {
            SendClientMessage(i, -1, Str);
        }
    }
    return false;
}

IsBanned(databaseId) {
    new Query[128];
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `bans` WHERE `PlayerId` = %d", databaseId);
    mysql_query(Database, Query);
    if(cache_num_rows() != 0) return true;
    return false;
}

IsPlayerConnectedEx(const username[]) {
    new playerid = -1;
    for(new i = 0; playerid == -1; i++) {
        if(i >= MAX_PLAYERS) playerid = -2;
        if(IsPlayerConnected(i)) {
            if(!strcmp(GetPlayerNameEx(i), username)) playerid = i;
        }
    }
    return playerid;
}

IsMuted(databaseId) {
    new Query[128];
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `mutes` WHERE `PlayerId` = %d", databaseId);
    mysql_query(Database, Query);
    if(cache_num_rows() != 0) return true;
    return false;
}