#define MAX_WORLDS 50

enum _:E_WORLDS_STATES {
    WORLD_STATE_NORMAL,
    WORLD_STATE_TRAINING,
    WORLD_STATE_CLAN_WARS
};

new WorldStates[][] = {
    "Normal",
    "Entrenamiento",
    "En partida"
};

enum _:E_WORLDS_PRIVACY {
    WORLD_PRIVACY_PRIVATE,
    WORLD_PRIVACY_PUBLIC,
    WORLD_PRIVACY_ADMIN_ONLY
};

enum E_WORLD_INFO {
    wId,
    wName[24],
    wPassword[18],
    wWorld,
    wState,
    wPrivacy,
    wTeamOneName[24],
    wTeamTwoName[24],
    wMaxRounds,
    wMaxPoints,

    wTeamOneRounds,
    wTeamTwoRounds,
    wTeamOnePoints,
    wTeamTwoPoints
};

new WorldInfo[MAX_WORLDS][E_WORLD_INFO];

ClearWorld(worldId = -1) {
    if(worldId == -1) {
        for(new i = 0; i < MAX_WORLDS; i++) {
            WorldInfo[i][wId] = -1;
            WorldInfo[i][wName] = -1;
            WorldInfo[i][wPassword] = -1;
            WorldInfo[i][wWorld] = -1;
            WorldInfo[i][wState] = -1;
            WorldInfo[i][wPrivacy] = -1;
            WorldInfo[i][wTeamOneName] = -1;
            WorldInfo[i][wTeamTwoName] = -1;
            WorldInfo[i][wMaxRounds] = -1;
            WorldInfo[i][wMaxPoints] = -1;

            WorldInfo[i][wTeamOneRounds] = 0;
            WorldInfo[i][wTeamTwoRounds] = 0;
            WorldInfo[i][wTeamOnePoints] = 0;
            WorldInfo[i][wTeamTwoPoints] = 0;
        }
    } else {
        WorldInfo[worldId][wId] = -1;
        WorldInfo[worldId][wName] = -1;
        WorldInfo[worldId][wPassword] = -1;
        WorldInfo[worldId][wWorld] = -1;
        WorldInfo[worldId][wState] = -1;
        WorldInfo[worldId][wPrivacy] = -1;
        WorldInfo[worldId][wTeamOneName] = -1;
        WorldInfo[worldId][wTeamTwoName] = -1;
        WorldInfo[worldId][wMaxRounds] = -1;
        WorldInfo[worldId][wMaxPoints] = -1;

        WorldInfo[worldId][wTeamOneRounds] = 0;
        WorldInfo[worldId][wTeamTwoRounds] = 0;
        WorldInfo[worldId][wTeamOnePoints] = 0;
        WorldInfo[worldId][wTeamTwoPoints] = 0;
    }
    return true;
}

LoadWorld(worldId = -1) {
    if(worldId == -1) {
        new Query[90];
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds` LIMIT %d", MAX_WORLDS);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return false; 
        for(new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_name_int(i, "Id", worldId);
            cache_get_value_name_int(i, "Id", WorldInfo[worldId][wId]);
            cache_get_value_name(i, "Name", WorldInfo[worldId][wName]);
            cache_get_value_name(i, "Password", WorldInfo[worldId][wPassword]);
            cache_get_value_name_int(i, "World", WorldInfo[worldId][wWorld]);
            cache_get_value_name_int(i, "State", WorldInfo[worldId][wState]);
            cache_get_value_name_int(i, "Privacy", WorldInfo[worldId][wPrivacy]);
            cache_get_value_name(i, "TeamOneName", WorldInfo[worldId][wTeamOneName]);
            cache_get_value_name(i, "TeamTwoName", WorldInfo[worldId][wTeamTwoName]);
            cache_get_value_name_int(i, "MaxRounds", WorldInfo[worldId][wMaxRounds]);
            cache_get_value_name_int(i, "MaxPoints", WorldInfo[worldId][wMaxPoints]);
        }
    } else {
        new Query[90];
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds` WHERE `Id` = %d", worldId);
        mysql_query(Database, Query);
        if(cache_num_rows() != 0) {
            cache_get_value_name_int(0, "Id", WorldInfo[worldId][wId]);
            cache_get_value_name(0, "Name", WorldInfo[worldId][wName]);
            cache_get_value_name(0, "Password", WorldInfo[worldId][wPassword]);
            cache_get_value_name_int(0, "World", WorldInfo[worldId][wWorld]);
            cache_get_value_name_int(0, "State", WorldInfo[worldId][wState]);
            cache_get_value_name_int(0, "Privacy", WorldInfo[worldId][wPrivacy]);
            cache_get_value_name(0, "TeamOneName", WorldInfo[worldId][wTeamOneName]);
            cache_get_value_name(0, "TeamTwoName", WorldInfo[worldId][wTeamTwoName]);
            cache_get_value_name_int(0, "MaxRounds", WorldInfo[worldId][wMaxRounds]);
            cache_get_value_name_int(0, "MaxPoints", WorldInfo[worldId][wMaxPoints]);
        }
    }
    return true;
}

SaveWorld(worldId = -1) {
    if(worldId == -1) {
        new Query[356];
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds` LIMIT %d", MAX_WORLDS);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return false;
        for(new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_name_int(i, "Id", worldId);
            mysql_format(Database, Query, sizeof(Query), "UPDATE `worlds` SET `Name` = '%s', `Password` = '%s', `World` = %d, `State` = %d, `Privacy` = %d, `TeamOneName` = '%s', `TeamTwoName` = '%s', `MaxRounds` = %d, `MaxPoints` = %d WHERE `Id` = %d",
                WorldInfo[worldId][wName],
                WorldInfo[worldId][wPassword],
                WorldInfo[worldId][wWorld],
                WorldInfo[worldId][wState],
                WorldInfo[worldId][wPrivacy],
                WorldInfo[worldId][wTeamOneName],
                WorldInfo[worldId][wTeamTwoName],
                WorldInfo[worldId][wMaxRounds],
                WorldInfo[worldId][wMaxPoints],
                WorldInfo[worldId][wId]
            );
            mysql_query(Database, Query, false);
        }
    } else {
        new Query[356];
        mysql_format(Database, Query, sizeof(Query), "UPDATE `worlds` SET `Name` = '%s', `Password` = '%s', `World` = %d, `State` = %d, `Privacy` = %d, `TeamOneName` = '%s', `TeamTwoName` = '%s', `MaxRounds` = %d, `MaxPoints` = %d WHERE `Id` = %d",
            WorldInfo[worldId][wName],
            WorldInfo[worldId][wPassword],
            WorldInfo[worldId][wWorld],
            WorldInfo[worldId][wState],
            WorldInfo[worldId][wPrivacy],
            WorldInfo[worldId][wTeamOneName],
            WorldInfo[worldId][wTeamTwoName],
            WorldInfo[worldId][wMaxRounds],
            WorldInfo[worldId][wMaxPoints],
            WorldInfo[worldId][wId]
        );
        mysql_query(Database, Query, false);
    }
    return true;
}

GetWorldPlayers(worldId) {
    new Count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(PlayerInfo[i][pWorld] == worldId) Count++;
    }
    return Count;
}

ShowWorlds(playerid) {
    new Query[90], Str[512] = "Id\tNombre\tEstado\tJugadores\n";
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds` LIMIT %d", MAX_WORLDS);
    mysql_query(Database, Query);
    for(new i = 0; i < cache_num_rows(); i++) {
        new worldId;
        cache_get_value_name_int(i, "Id", worldId);
        format(Str, sizeof(Str), "%s%d\t%s\t%s\t%d\n", Str, WorldInfo[worldId][wId], WorldInfo[worldId][wName], WorldStates[WorldInfo[worldId][wState]], GetWorldPlayers(worldId));
    }
    return ShowPlayerDialog(playerid, DIALOG_WORLDS, DIALOG_STYLE_TABLIST_HEADERS, "Mundos disponibles", Str, "Entrar", "Salir");
}

#define ClearWorlds() ClearWorld()
#define LoadWorlds() LoadWorld()
#define SaveWorlds() SaveWorld()