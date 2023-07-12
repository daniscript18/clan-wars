#define MAX_WORLDS 50
#define MAX_MAPS 50
#define MAX_WEAPONS 50

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

enum _:E_WORLDS_TEAMS {
    WORLD_TEAM_SPECTATOR,
    WORLD_TEAM_ONE,
    WORLD_TEAM_TWO
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
    wWeapons,
    wMap,

    wTeamOneRounds,
    wTeamTwoRounds,
    wTeamOnePoints,
    wTeamTwoPoints
};

enum E_MAP_INFO {
    mId,
    mName,
    Float:mSpecX,
    Float:mSpecY,
    Float:mSpecZ,
    Float:mSpecA,
    Float:mTeamOneX,
    Float:mTeamOneY,
    Float:mTeamOneZ,
    Float:mTeamOneA,
    Float:mTeamTwoX,
    Float:mTeamTwoY,
    Float:mTeamTwoZ,
    Float:mTeamTwoA
};

enum E_WEAPON_INFO {
    wId,
    wName[24],
    wWeapon1,
    wWeapon2,
    wWeapon3,
    wWeapon4,
    wAmmo1,
    wAmmo2,
    wAmmo3,
    wAmmo4
};

new WorldInfo[MAX_WORLDS][E_WORLD_INFO];
new MapsInfo[MAX_MAPS][E_MAP_INFO];
new WeaponInfo[MAX_WEAPONS][E_WEAPON_INFO];

ClearMaps() {
    for(new i = 0; i < MAX_MAPS; i++) {
        MapsInfo[i][mId] = -1;
        MapsInfo[i][mName] = -1;
        MapsInfo[i][mSpecX] = -1;
        MapsInfo[i][mSpecY] = -1;
        MapsInfo[i][mSpecZ] = -1;
        MapsInfo[i][mSpecA] = -1;
        MapsInfo[i][mTeamOneX] = -1;
        MapsInfo[i][mTeamOneY] = -1;
        MapsInfo[i][mTeamOneZ] = -1;
        MapsInfo[i][mTeamOneA] = -1;
        MapsInfo[i][mTeamTwoX] = -1;
        MapsInfo[i][mTeamTwoY] = -1;
        MapsInfo[i][mTeamTwoZ] = -1;
        MapsInfo[i][mTeamTwoA] = -1;
    }
    return true;
}

ClearWeapons() {
    for(new i = 0; i < MAX_WEAPONS; i++) {
        WeaponInfo[i][wId] = -1;
        WeaponInfo[i][wName] = -1;
        WeaponInfo[i][wWeapon1] = -1;
        WeaponInfo[i][wWeapon2] = -1;
        WeaponInfo[i][wWeapon3] = -1;
        WeaponInfo[i][wWeapon4] = -1;
        WeaponInfo[i][wAmmo1] = -1;
        WeaponInfo[i][wAmmo2] = -1;
        WeaponInfo[i][wAmmo3] = -1;
        WeaponInfo[i][wAmmo4] = -1;
    }
    return true;
}

ClearWorld(worldId = -1) {
    if(worldId == -1) {
        ClearMaps();
        ClearWeapons();
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
            WorldInfo[i][wWeapons] = -1;
            WorldInfo[i][wMap] = -1;

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
        WorldInfo[worldId][wWeapons] = -1;
        WorldInfo[worldId][wMap] = -1;

        WorldInfo[worldId][wTeamOneRounds] = 0;
        WorldInfo[worldId][wTeamTwoRounds] = 0;
        WorldInfo[worldId][wTeamOnePoints] = 0;
        WorldInfo[worldId][wTeamTwoPoints] = 0;
    }
    return true;
}

LoadMaps() {
    new Query[90];
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds_maps` LIMIT %d", MAX_MAPS);
    mysql_query(Database, Query);
    if(cache_num_rows() == 0) return false; 
    for(new i = 0; i < cache_num_rows(); i++) {
        new mapId; cache_get_value_name_int(i, "Id", mapId);
        cache_get_value_name_int(i, "Id", MapsInfo[mapId][mId]);
        cache_get_value_name(i, "Name", MapsInfo[mapId][mName]);
        cache_get_value_name_float(i, "SpecX", MapsInfo[mapId][mSpecX]);
        cache_get_value_name_float(i, "SpecY", MapsInfo[mapId][mSpecY]);
        cache_get_value_name_float(i, "SpecZ", MapsInfo[mapId][mSpecZ]);
        cache_get_value_name_float(i, "SpecA", MapsInfo[mapId][mSpecA]);
        cache_get_value_name_float(i, "TeamOneX", MapsInfo[mapId][mTeamOneX]);
        cache_get_value_name_float(i, "TeamOneY", MapsInfo[mapId][mTeamOneY]);
        cache_get_value_name_float(i, "TeamOneZ", MapsInfo[mapId][mTeamOneZ]);
        cache_get_value_name_float(i, "TeamOneA", MapsInfo[mapId][mTeamOneA]);
        cache_get_value_name_float(i, "TeamTwoX", MapsInfo[mapId][mTeamTwoX]);
        cache_get_value_name_float(i, "TeamTwoY", MapsInfo[mapId][mTeamTwoY]);
        cache_get_value_name_float(i, "TeamTwoZ", MapsInfo[mapId][mTeamTwoZ]);
        cache_get_value_name_float(i, "TeamTwoA", MapsInfo[mapId][mTeamTwoA]);
    }
    return true;
}

LoadWeapons() {
    new Query[90];
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds_weapons` LIMIT %d", MAX_WEAPONS);
    mysql_query(Database, Query);
    if(cache_num_rows() == 0) return false; 
    for(new i = 0; i < cache_num_rows(); i++) {
        new mapId; cache_get_value_name_int(i, "Id", mapId);
        cache_get_value_name_int(i, "Id", WeaponInfo[mapId][wId]);
        cache_get_value_name(i, "Name", WeaponInfo[mapId][wName]);
        cache_get_value_name_int(i, "Weapon1", WeaponInfo[mapId][wWeapon1]);
        cache_get_value_name_int(i, "Weapon2", WeaponInfo[mapId][wWeapon2]);
        cache_get_value_name_int(i, "Weapon3", WeaponInfo[mapId][wWeapon3]);
        cache_get_value_name_int(i, "Weapon4", WeaponInfo[mapId][wWeapon4]);
        cache_get_value_name_int(i, "Ammo1", WeaponInfo[mapId][wAmmo1]);
        cache_get_value_name_int(i, "Ammo2", WeaponInfo[mapId][wAmmo2]);
        cache_get_value_name_int(i, "Ammo3", WeaponInfo[mapId][wAmmo3]);
        cache_get_value_name_int(i, "Ammo4", WeaponInfo[mapId][wAmmo4]);
    }
    return true;
}

LoadWorld(worldId = -1) {
    if(worldId == -1) {
        LoadMaps();
        LoadWeapons();
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
            cache_get_value_name_int(i, "Weapons", WorldInfo[worldId][wWeapons]);
            cache_get_value_name_int(i, "Map", WorldInfo[worldId][wMap]);
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
            cache_get_value_name_int(0, "Weapons", WorldInfo[worldId][wWeapons]);
            cache_get_value_name_int(0, "Map", WorldInfo[worldId][wMap]);
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
            mysql_format(Database, Query, sizeof(Query), "UPDATE `worlds` SET `Name` = '%s', `Password` = '%s', `World` = %d, `State` = %d, `Privacy` = %d, `TeamOneName` = '%s', `TeamTwoName` = '%s', `MaxRounds` = %d, `MaxPoints` = %d, `Weapons` = %d, `Map` = %d WHERE `Id` = %d",
                WorldInfo[worldId][wName],
                WorldInfo[worldId][wPassword],
                WorldInfo[worldId][wWorld],
                WorldInfo[worldId][wState],
                WorldInfo[worldId][wPrivacy],
                WorldInfo[worldId][wTeamOneName],
                WorldInfo[worldId][wTeamTwoName],
                WorldInfo[worldId][wMaxRounds],
                WorldInfo[worldId][wMaxPoints],
                WorldInfo[worldId][wWeapons],
                WorldInfo[worldId][wMap],
                WorldInfo[worldId][wId]
            );
            mysql_query(Database, Query, false);
        }
    } else {
        new Query[356];
        mysql_format(Database, Query, sizeof(Query), "UPDATE `worlds` SET `Name` = '%s', `Password` = '%s', `World` = %d, `State` = %d, `Privacy` = %d, `TeamOneName` = '%s', `TeamTwoName` = '%s', `MaxRounds` = %d, `MaxPoints` = %d, `Weapons` = %d, `Map` = %d WHERE `Id` = %d",
            WorldInfo[worldId][wName],
            WorldInfo[worldId][wPassword],
            WorldInfo[worldId][wWorld],
            WorldInfo[worldId][wState],
            WorldInfo[worldId][wPrivacy],
            WorldInfo[worldId][wTeamOneName],
            WorldInfo[worldId][wTeamTwoName],
            WorldInfo[worldId][wMaxRounds],
            WorldInfo[worldId][wMaxPoints],
            WorldInfo[worldId][wWeapons],
            WorldInfo[worldId][wMap],
            WorldInfo[worldId][wId]
        );
        mysql_query(Database, Query, false);
    }
    return true;
}

CreateWorld() {
    mysql_query(Database, "INSERT INTO `worlds` (`State`, `Privacy`, `TeamOneName`, `TeamTwoName`, `MaxRounds`, `MaxPoints`, `Weapons`, `Map`) VALUES (0, 0, 'Team One', 'Team Two', 5, 10, 1, 1)");
    new worldId = cache_insert_id();
    WorldInfo[worldId][wId] = worldId;
    format(WorldInfo[worldId][wName], 24, "Mundo %d", worldId);
    format(WorldInfo[worldId][wPassword], 18, "NULL");
    WorldInfo[worldId][wWorld] = worldId*100;
    WorldInfo[worldId][wState] = WORLD_STATE_NORMAL;
    WorldInfo[worldId][wPrivacy] = WORLD_PRIVACY_PRIVATE;
    format(WorldInfo[worldId][wTeamOneName], 24, "Team One");
    format(WorldInfo[worldId][wTeamTwoName], 24, "Team Two");
    WorldInfo[worldId][wMaxRounds] = 5;
    WorldInfo[worldId][wMaxPoints] = 10;
    WorldInfo[worldId][wWeapons] = 1;
    WorldInfo[worldId][wMap] = 1;
    SaveWorld(worldId);
    LoadWorld(worldId);
    return worldId;
}

DeleteWorld(worldId) {
    new Query[90];
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `worlds` WHERE `Id` = %d", worldId);
    mysql_query(Database, Query);
    if(cache_num_rows() != 0) {
        mysql_format(Database, Query, sizeof(Query), "DELETE FROM `worlds` WHERE `Id` = %d", worldId);
        mysql_query(Database, Query, false);
        ClearWorld(worldId);
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i)) {
                ShowWorlds(i);
                SendClientMessage(i, -1, "El mundo en el que estabas ha sido eliminado");
            }
        }
        return true;
    }
    return false;
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

GetWorldTeamPlayers(worldId, teamId) {
    new Count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(PlayerInfo[i][pWorld] == worldId) {
            if(PlayerInfo[i][pTeam] == teamId) Count++;
        }
    }
    return Count;
}

ShowTeams(playerid) {
    new Str[356], worldId = PlayerInfo[playerid][pWorld];
    format(Str, sizeof(Str), "Nombre\tJugadores\n");
    format(Str, sizeof(Str), "%sEspectador\t%d\n", Str, GetWorldTeamPlayers(worldId, WORLD_TEAM_SPECTATOR));
    format(Str, sizeof(Str), "%s%s\t%d\n", Str, WorldInfo[worldId][wTeamOneName], GetWorldTeamPlayers(worldId, WORLD_TEAM_ONE));
    format(Str, sizeof(Str), "%s%s\t%d\n", Str, WorldInfo[worldId][wTeamTwoName], GetWorldTeamPlayers(worldId, WORLD_TEAM_TWO));
    return ShowPlayerDialog(playerid, DIALOG_TEAMS, DIALOG_STYLE_TABLIST_HEADERS, "Equipos disponibles", Str, "Entrar", "Atrás");
}

#define ClearWorlds() ClearWorld()
#define LoadWorlds() LoadWorld()
#define SaveWorlds() SaveWorld()