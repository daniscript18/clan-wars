enum _:E_ADMIN_LEVELS {
    ADMIN_LEVEL_NONE,
    ADMIN_LEVEL_HELPER,
    ADMIN_LEVEL_MODERATOR,
    ADMIN_LEVEL_ADMINISTRADOR,
    ADMIN_LEVEL_BOSS
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
    return true;
}

forward ExistPlayer(playerid);
public ExistPlayer(playerid) {
    new Str[130];
    if(cache_num_rows() != 0) {
        cache_get_value_name(0, "Password", PlayerInfo[playerid][pPassword], 18);
        format(Str, sizeof(Str), "La cuenta (%s) fue encontrada en la base de datos.\nPor favor escribe tu contraseña para entrar.", PlayerInfo[playerid][pUsername]);
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Cuenta encontrada", Str, "Entrar", "Salir");
    } else {
        format(Str, sizeof(Str), "La cuenta (%s) no fue encontrada en la base de datos.\nPor favor escribe una contraseña para entrar.", PlayerInfo[playerid][pUsername]);
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cuenta no encontrada", Str, "Entrar", "Salir");
    }
    return true;
}

forward LoadPlayer(playerid);
public LoadPlayer(playerid) {
    if(cache_num_rows() != 0) {
        new Ip[15];

        cache_get_value_name_int(0, "Id", PlayerInfo[playerid][pId]);
        GetPlayerIp(playerid, Ip, sizeof(Ip));
        format(PlayerInfo[playerid][pIp], 15, "%s", Ip);
        GetPlayerName(playerid, PlayerInfo[playerid][pUsername], 24);
        cache_get_value_name_int(0, "Admin", PlayerInfo[playerid][pAdmin]);

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