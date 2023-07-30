#define MAX_WORLDS 1000
#define MAX_MAPS 1000
#define MAX_WEAPONS 1000

#define ClearMaps() ClearMap()
#define ClearWeapons() ClearWeapon()
#define ClearWorlds() ClearWorld()
#define LoadMaps() LoadMap()
#define LoadWeapons() LoadWeapon()
#define LoadWorlds() LoadWorld()
#define SaveWorlds() SaveWorld()
#define SaveMaps() SaveMap()
#define SaveWeapons() SaveWeapon()

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

new WorldPrivacy[][] = {
    "Privado",
    "Público",
    "Autorizado"
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
    mWorld,
    mName[24],
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
    wWorld,
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
new MapInfo[MAX_MAPS][E_MAP_INFO];
new WeaponInfo[MAX_WEAPONS][E_WEAPON_INFO];

ClearMap(mapId = -1) {
    if(mapId == -1) {
        for(new i = 0; i < MAX_MAPS; i++) {
            MapInfo[i][mId] = -1;
            MapInfo[i][mWorld] = -1;
            MapInfo[i][mName] = -1;
            MapInfo[i][mSpecX] = -1;
            MapInfo[i][mSpecY] = -1;
            MapInfo[i][mSpecZ] = -1;
            MapInfo[i][mSpecA] = -1;
            MapInfo[i][mTeamOneX] = -1;
            MapInfo[i][mTeamOneY] = -1;
            MapInfo[i][mTeamOneZ] = -1;
            MapInfo[i][mTeamOneA] = -1;
            MapInfo[i][mTeamTwoX] = -1;
            MapInfo[i][mTeamTwoY] = -1;
            MapInfo[i][mTeamTwoZ] = -1;
            MapInfo[i][mTeamTwoA] = -1;
        }
    } else {
        MapInfo[mapId][mId] = -1;
        MapInfo[mapId][mWorld] = -1;
        MapInfo[mapId][mName] = -1;
        MapInfo[mapId][mSpecX] = -1;
        MapInfo[mapId][mSpecY] = -1;
        MapInfo[mapId][mSpecZ] = -1;
        MapInfo[mapId][mSpecA] = -1;
        MapInfo[mapId][mTeamOneX] = -1;
        MapInfo[mapId][mTeamOneY] = -1;
        MapInfo[mapId][mTeamOneZ] = -1;
        MapInfo[mapId][mTeamOneA] = -1;
        MapInfo[mapId][mTeamTwoX] = -1;
        MapInfo[mapId][mTeamTwoY] = -1;
        MapInfo[mapId][mTeamTwoZ] = -1;
        MapInfo[mapId][mTeamTwoA] = -1;
    }
    return true;
}

ClearWeapon(weaponId = -1) {
    if(weaponId == -1) {
        for(new i = 0; i < MAX_WEAPONS; i++) {
            WeaponInfo[i][wId] = -1;
            WeaponInfo[i][wWorld] = -1;
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
    } else {
        WeaponInfo[weaponId][wId] = -1;
        WeaponInfo[weaponId][wWorld] = -1;
        WeaponInfo[weaponId][wName] = -1;
        WeaponInfo[weaponId][wWeapon1] = -1;
        WeaponInfo[weaponId][wWeapon2] = -1;
        WeaponInfo[weaponId][wWeapon3] = -1;
        WeaponInfo[weaponId][wWeapon4] = -1;
        WeaponInfo[weaponId][wAmmo1] = -1;
        WeaponInfo[weaponId][wAmmo2] = -1;
        WeaponInfo[weaponId][wAmmo3] = -1;
        WeaponInfo[weaponId][wAmmo4] = -1;
    }
    return true;
}

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

LoadMap(mapId = -1) {
    if(mapId == -1) {
        mysql_query(Database, "SELECT * FROM `maps`");
        if(cache_num_rows() == 0) return false; 
        for(new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_name_int(i, "Id", mapId);
            cache_get_value_name_int(i, "Id", MapInfo[mapId][mId]);
            cache_get_value_name_int(i, "World", MapInfo[mapId][mWorld]);
            cache_get_value_name(i, "Name", MapInfo[mapId][mName]);
            cache_get_value_name_float(i, "SpecX", MapInfo[mapId][mSpecX]);
            cache_get_value_name_float(i, "SpecY", MapInfo[mapId][mSpecY]);
            cache_get_value_name_float(i, "SpecZ", MapInfo[mapId][mSpecZ]);
            cache_get_value_name_float(i, "SpecA", MapInfo[mapId][mSpecA]);
            cache_get_value_name_float(i, "TeamOneX", MapInfo[mapId][mTeamOneX]);
            cache_get_value_name_float(i, "TeamOneY", MapInfo[mapId][mTeamOneY]);
            cache_get_value_name_float(i, "TeamOneZ", MapInfo[mapId][mTeamOneZ]);
            cache_get_value_name_float(i, "TeamOneA", MapInfo[mapId][mTeamOneA]);
            cache_get_value_name_float(i, "TeamTwoX", MapInfo[mapId][mTeamTwoX]);
            cache_get_value_name_float(i, "TeamTwoY", MapInfo[mapId][mTeamTwoY]);
            cache_get_value_name_float(i, "TeamTwoZ", MapInfo[mapId][mTeamTwoZ]);
            cache_get_value_name_float(i, "TeamTwoA", MapInfo[mapId][mTeamTwoA]);
        }
    } else {
        new Query[90];
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `maps` WHERE `Id` = %d", mapId);
        mysql_query(Database, Query);
        if(cache_num_rows() != 0) {
            cache_get_value_name_int(0, "Id", MapInfo[mapId][mId]);
            cache_get_value_name_int(0, "World", MapInfo[mapId][mWorld]);
            cache_get_value_name(0, "Name", MapInfo[mapId][mName]);
            cache_get_value_name_float(0, "SpecX", MapInfo[mapId][mSpecX]);
            cache_get_value_name_float(0, "SpecY", MapInfo[mapId][mSpecY]);
            cache_get_value_name_float(0, "SpecZ", MapInfo[mapId][mSpecZ]);
            cache_get_value_name_float(0, "SpecA", MapInfo[mapId][mSpecA]);
            cache_get_value_name_float(0, "TeamOneX", MapInfo[mapId][mTeamOneX]);
            cache_get_value_name_float(0, "TeamOneY", MapInfo[mapId][mTeamOneY]);
            cache_get_value_name_float(0, "TeamOneZ", MapInfo[mapId][mTeamOneZ]);
            cache_get_value_name_float(0, "TeamOneA", MapInfo[mapId][mTeamOneA]);
            cache_get_value_name_float(0, "TeamTwoX", MapInfo[mapId][mTeamTwoX]);
            cache_get_value_name_float(0, "TeamTwoY", MapInfo[mapId][mTeamTwoY]);
            cache_get_value_name_float(0, "TeamTwoZ", MapInfo[mapId][mTeamTwoZ]);
            cache_get_value_name_float(0, "TeamTwoA", MapInfo[mapId][mTeamTwoA]);
        }
    }
    return true;
}

LoadWeapon(weaponId = -1) {
    if(weaponId == -1) {
        mysql_query(Database, "SELECT * FROM `weapons`");
        if(cache_num_rows() == 0) return false; 
        for(new i = 0; i < cache_num_rows(); i++) {
            cache_get_value_name_int(i, "Id", weaponId);
            cache_get_value_name_int(i, "Id", WeaponInfo[weaponId][wId]);
            cache_get_value_name_int(i, "World", WeaponInfo[weaponId][wWorld]);
            cache_get_value_name(i, "Name", WeaponInfo[weaponId][wName]);
            cache_get_value_name_int(i, "Weapon1", WeaponInfo[weaponId][wWeapon1]);
            cache_get_value_name_int(i, "Weapon2", WeaponInfo[weaponId][wWeapon2]);
            cache_get_value_name_int(i, "Weapon3", WeaponInfo[weaponId][wWeapon3]);
            cache_get_value_name_int(i, "Weapon4", WeaponInfo[weaponId][wWeapon4]);
            cache_get_value_name_int(i, "Ammo1", WeaponInfo[weaponId][wAmmo1]);
            cache_get_value_name_int(i, "Ammo2", WeaponInfo[weaponId][wAmmo2]);
            cache_get_value_name_int(i, "Ammo3", WeaponInfo[weaponId][wAmmo3]);
            cache_get_value_name_int(i, "Ammo4", WeaponInfo[weaponId][wAmmo4]);
        }
    } else {
        new Query[90];
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `weapons` WHERE `Id` = %d", weaponId);
        mysql_query(Database, Query);
        if(cache_num_rows() != 0) {
            cache_get_value_name_int(0, "Id", WeaponInfo[weaponId][wId]);
            cache_get_value_name_int(0, "World", WeaponInfo[weaponId][wWorld]);
            cache_get_value_name(0, "Name", WeaponInfo[weaponId][wName]);
            cache_get_value_name_int(0, "Weapon1", WeaponInfo[weaponId][wWeapon1]);
            cache_get_value_name_int(0, "Weapon2", WeaponInfo[weaponId][wWeapon2]);
            cache_get_value_name_int(0, "Weapon3", WeaponInfo[weaponId][wWeapon3]);
            cache_get_value_name_int(0, "Weapon4", WeaponInfo[weaponId][wWeapon4]);
            cache_get_value_name_int(0, "Ammo1", WeaponInfo[weaponId][wAmmo1]);
            cache_get_value_name_int(0, "Ammo2", WeaponInfo[weaponId][wAmmo2]);
            cache_get_value_name_int(0, "Ammo3", WeaponInfo[weaponId][wAmmo3]);
            cache_get_value_name_int(0, "Ammo4", WeaponInfo[weaponId][wAmmo4]);
        }
    }
    return true;
}

LoadWorld(worldId = -1) {
    if(worldId == -1) {
        mysql_query(Database, "SELECT * FROM `worlds`");
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

SaveMap(mapId = -1) {
    new Query[356];
    if(mapId == -1) {
        for(new i = 0; i < MAX_MAPS; i++) {
            if(MapInfo[i][mId] != -1) {
                mysql_format(Database, Query, sizeof(Query), "UPDATE `maps` SET `World` = %d, `Name` = '%s', `SpecX` = %f, `SpecY` = %f, `SpecZ` = %f, `SpecA` = %f, `TeamOneX` = %f, `TeamOneY` = %f, `TeamOneZ` = %f, `TeamOneA` = %f, `TeamTwoX` = %f, `TeamTwoY` = %f, `TeamTwoZ` = %f, `TeamTwoA` = %f WHERE `Id` = %d",
                    MapInfo[i][mWorld],
                    MapInfo[i][mName],
                    MapInfo[i][mSpecX],
                    MapInfo[i][mSpecY],
                    MapInfo[i][mSpecZ],
                    MapInfo[i][mSpecA],
                    MapInfo[i][mTeamOneX],
                    MapInfo[i][mTeamOneY],
                    MapInfo[i][mTeamOneZ],
                    MapInfo[i][mTeamOneA],
                    MapInfo[i][mTeamTwoX],
                    MapInfo[i][mTeamTwoY],
                    MapInfo[i][mTeamTwoZ],
                    MapInfo[i][mTeamTwoA],
                    MapInfo[i][mId]
                );
                mysql_query(Database, Query, false);
            }
        }
    } else {
        mysql_format(Database, Query, sizeof(Query), "UPDATE `maps` SET `World` = %d, `Name` = '%s', `SpecX` = %f, `SpecY` = %f, `SpecZ` = %f, `SpecA` = %f, `TeamOneX` = %f, `TeamOneY` = %f, `TeamOneZ` = %f, `TeamOneA` = %f, `TeamTwoX` = %f, `TeamTwoY` = %f, `TeamTwoZ` = %f, `TeamTwoA` = %f WHERE `Id` = %d",
            MapInfo[mapId][mWorld],
            MapInfo[mapId][mName],
            MapInfo[mapId][mSpecX],
            MapInfo[mapId][mSpecY],
            MapInfo[mapId][mSpecZ],
            MapInfo[mapId][mSpecA],
            MapInfo[mapId][mTeamOneX],
            MapInfo[mapId][mTeamOneY],
            MapInfo[mapId][mTeamOneZ],
            MapInfo[mapId][mTeamOneA],
            MapInfo[mapId][mTeamTwoX],
            MapInfo[mapId][mTeamTwoY],
            MapInfo[mapId][mTeamTwoZ],
            MapInfo[mapId][mTeamTwoA],
            MapInfo[mapId][mId]
        );
        mysql_query(Database, Query, false);
    }
    return true;
}

SaveWeapon(weaponId = -1) {
    new Query[356];
    if(weaponId == -1) {
        for(new i = 0; i < MAX_WEAPONS; i++) {
            if(WeaponInfo[i][wId] != -1) {
                mysql_format(Database, Query, sizeof(Query), "UPDATE `weapons` SET `World` = %d, `Name` = '%s', `Weapon1` = %d, `Weapon2` = %d, `Weapon3` = %d, `Weapon4` = %d, `Ammo1` = %d, `Ammo2` = %d, `Ammo3` = %d, `Ammo4` = %d WHERE `Id` = %d",
                    WeaponInfo[i][wWorld],
                    WeaponInfo[i][wName],
                    WeaponInfo[i][wWeapon1],
                    WeaponInfo[i][wWeapon2],
                    WeaponInfo[i][wWeapon3],
                    WeaponInfo[i][wWeapon4],
                    WeaponInfo[i][wAmmo1],
                    WeaponInfo[i][wAmmo2],
                    WeaponInfo[i][wAmmo3],
                    WeaponInfo[i][wAmmo4],
                    WeaponInfo[i][wId]
                );
                mysql_query(Database, Query, false);
            }
        }
    } else {
        mysql_format(Database, Query, sizeof(Query), "UPDATE `weapons` SET `World` = %d, `Name` = '%s', `Weapon1` = %d, `Weapon2` = %d, `Weapon3` = %d, `Weapon4` = %d, `Ammo1` = %d, `Ammo2` = %d, `Ammo3` = %d, `Ammo4` = %d WHERE `Id` = %d",
            WeaponInfo[weaponId][wWorld],
            WeaponInfo[weaponId][wName],
            WeaponInfo[weaponId][wWeapon1],
            WeaponInfo[weaponId][wWeapon2],
            WeaponInfo[weaponId][wWeapon3],
            WeaponInfo[weaponId][wWeapon4],
            WeaponInfo[weaponId][wAmmo1],
            WeaponInfo[weaponId][wAmmo2],
            WeaponInfo[weaponId][wAmmo3],
            WeaponInfo[weaponId][wAmmo4],
            WeaponInfo[weaponId][wId]
        );
        mysql_query(Database, Query, false);
    }
    return true;
}

SaveWorld(worldId = -1) {
    new Query[356];
    if(worldId == -1) {
        SaveMaps();
        SaveWeapons();
        for(new i = 0; i < MAX_WORLDS; i++) {
            if(WorldInfo[i][wId] != -1) {
                mysql_format(Database, Query, sizeof(Query), "UPDATE `worlds` SET `Name` = '%s', `Password` = '%s', `World` = %d, `State` = %d, `Privacy` = %d, `TeamOneName` = '%s', `TeamTwoName` = '%s', `MaxRounds` = %d, `MaxPoints` = %d, `Weapons` = %d, `Map` = %d WHERE `Id` = %d",
                    WorldInfo[i][wName],
                    WorldInfo[i][wPassword],
                    WorldInfo[i][wWorld],
                    WorldInfo[i][wState],
                    WorldInfo[i][wPrivacy],
                    WorldInfo[i][wTeamOneName],
                    WorldInfo[i][wTeamTwoName],
                    WorldInfo[i][wMaxRounds],
                    WorldInfo[i][wMaxPoints],
                    WorldInfo[i][wWeapons],
                    WorldInfo[i][wMap],
                    WorldInfo[i][wId]
                );
                mysql_query(Database, Query, false);
            }
        }
    } else {
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

CreateMap(worldId, const name[] = "Map", Float:specX = -1.0, Float:specY = -1.0, Float:specZ = -1.0, Float:specA = -1.0, Float:teamOneX = -1.0, Float:teamOneY = -1.0, Float:teamOneZ = -1.0, Float:teamOneA = -1.0, Float:teamTwoX = -1.0, Float:teamTwoY = -1.0, Float:teamTwoZ = -1.0, Float:teamTwoA = -1.0) {
    new Query[512];
    if(specX == -1.0 && specY == -1.0 && specZ == -1.0 && specA == -1.0 && teamOneX == -1.0 && teamOneY == -1.0 && teamOneZ == -1.0 && teamOneA == -1.0 && teamTwoX == -1.0 && teamTwoY == -1.0 && teamTwoZ == -1.0 && teamTwoA == -1.0) {
        new result[3];
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `maps` (`World`, `Name`, `SpecX`, `SpecY`, `SpecZ`, `SpecA`, `TeamOneX`, `TeamOneY`, `TeamOneZ`, `TeamOneA`, `TeamTwoX`, `TeamTwoY`, `TeamTwoZ`, `TeamTwoA`) VALUES (%d, 'Aeropuerto LS', 2021.63, -2381.96, 26.4903, 89.9708, 1973.97, -2280.87, 13.5469, 169.816, 1969.04, -2422.62, 13.5469, 6.7741)", worldId);
        mysql_query(Database, Query);
        result[0] = cache_insert_id();
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `maps` (`World`, `Name`, `SpecX`, `SpecY`, `SpecZ`, `SpecA`, `TeamOneX`, `TeamOneY`, `TeamOneZ`, `TeamOneA`, `TeamTwoX`, `TeamTwoY`, `TeamTwoZ`, `TeamTwoA`) VALUES (%d, 'Aeropuerto LV', -1219.64, -69.6603, 28.9255, 310.17, -1341.99, -26.4392, 14.1484, 225.009, -1186.47, -182.016, 14.1484, 44.5505)", worldId);
        mysql_query(Database, Query);
        result[1] = cache_insert_id();
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `maps` (`World`, `Name`, `SpecX`, `SpecY`, `SpecZ`, `SpecA`, `TeamOneX`, `TeamOneY`, `TeamOneZ`, `TeamOneA`, `TeamTwoX`, `TeamTwoY`, `TeamTwoZ`, `TeamTwoA`) VALUES (%d, 'Aeropuerto SF', 1604.97, 1447.61, 33.4481, 93.7946, 1555.4, 1536.83, 10.8266, 179.97, 1547.58, 1364.82, 10.8672, 2.332)", worldId);
        mysql_query(Database, Query);
        result[2] = cache_insert_id();
        LoadMap(result[0]);
        LoadMap(result[1]);
        LoadMap(result[2]);
        return result[0];
    } else {
        new result;
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `maps` (`World`, `Name`, `SpecX`, `SpecY`, `SpecZ`, `SpecA`, `TeamOneX`, `TeamOneY`, `TeamOneZ`, `TeamOneA`, `TeamTwoX`, `TeamTwoY`, `TeamTwoZ`, `TeamTwoA`) VALUES (%d, '%s', %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)", worldId, name, specX, specY, specZ, specA, teamOneX, teamOneY, teamOneZ, teamOneA, teamTwoX, teamTwoY, teamTwoZ, teamTwoA);
        mysql_query(Database, Query);
        result = cache_insert_id();
        LoadMap(result);
        return result;  
    }
}

CreateWeapon(worldId, const name[] = "Weapons", weapon1 = -1, weapon2 = -1, weapon3 = -1, weapon4 = -1, ammo1 = -1, ammo2 = -1, ammo3 = -1, ammo4 = -1) {
    new Query[512];
    if(weapon1 == -1 && weapon2 == -1 && weapon3 == -1 && weapon4 == -1 && ammo1 == -1 && ammo2 == -1 && ammo3 == -1 && ammo4 == -1) {
        new result[3];
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `weapons` (`World`, `Name`, `Weapon1`, `Weapon2`, `Weapon3`, `Weapon4`, `Ammo1`, `Ammo2`, `Ammo3`, `Ammo4`) VALUES (%d, 'RW', 22, 26, 28, -1, 9999, 9999, 9999, -1)", worldId);
        mysql_query(Database, Query);
        result[0] = cache_insert_id();
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `weapons` (`World`, `Name`, `Weapon1`, `Weapon2`, `Weapon3`, `Weapon4`, `Ammo1`, `Ammo2`, `Ammo3`, `Ammo4`) VALUES (%d, 'WW', 24, 26, 29, 31, 9999, 9999, 9999, 9999)", worldId);
        mysql_query(Database, Query);
        result[1] = cache_insert_id();
        LoadWeapon(result[0]);
        LoadWeapon(result[1]);
        return result[0];
    } else {
        new result;
        mysql_format(Database, Query, sizeof(Query), "INSERT INTO `weapons` (`World`, `Name`, `Weapon1`, `Weapon2`, `Weapon3`, `Weapon4`, `Ammo1`, `Ammo2`, `Ammo3`, `Ammo4`) VALUES (%d, '%s', %d, %d, %d, %d, %d, %d, %d, %d)", worldId, name, weapon1, weapon2, weapon3, weapon4, ammo1, ammo2, ammo3, ammo4);
        mysql_query(Database, Query);
        result = cache_insert_id();
        LoadWeapon(result);
        return result;  
    }
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
    WorldInfo[worldId][wMap] = CreateMap(worldId);
    WorldInfo[worldId][wWeapons] = CreateWeapon(worldId);
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
        mysql_format(Database, Query, sizeof(Query), "DELETE FROM `weapons` WHERE `World` = %d", worldId);
        mysql_query(Database, Query);
        if(cache_num_rows() != 0) {
            for(new i = 0; i < cache_num_rows(); i++) {
                new weaponId;
                cache_get_value_name_int(i, "Id", weaponId);
                ClearWeapon(weaponId);
            }
        }
        mysql_format(Database, Query, sizeof(Query), "DELETE FROM `maps` WHERE `World` = %d", worldId);
        mysql_query(Database, Query);
        if(cache_num_rows() > 0) {
            for(new i = 0; i < cache_num_rows(); i++) {
                new mapId;
                cache_get_value_name_int(i, "Id", mapId);
                ClearMap(mapId);
            }
        }
        for(new i = 0; i < MAX_PLAYERS; i++) {
            if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == worldId) {
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
    new Str[512] = "Id\tNombre\tEstado\tJugadores\n";
    mysql_query(Database, "SELECT * FROM `worlds`", false);
    for(new i = 0; i < MAX_WORLDS; i++) {
        if(WorldInfo[i][wId] != -1) {
            format(Str, sizeof(Str), "%s%d\t%s\t%s\t%d\n", Str, WorldInfo[i][wId], WorldInfo[i][wName], WorldStates[WorldInfo[i][wState]], GetWorldPlayers(i));
        }
    }
    return ShowPlayerDialog(playerid, DIALOG_WORLDS, DIALOG_STYLE_TABLIST_HEADERS, "Mundos disponibles", Str, "Entrar", "Salir");
}

GetWorldTeamPlayers(worldId, teamId) {
    new Count = 0;
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(PlayerInfo[i][pWorld] == worldId &&
           PlayerInfo[i][pTeam] == teamId) Count++;
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

ShowConfigWorld(playerid) {
    new Str[356], Password[18], worldId = PlayerInfo[playerid][pWorld], weaponId = WorldInfo[worldId][wWeapons], mapId = WorldInfo[worldId][wMap];
    for(new i = 0; i < strlen(WorldInfo[worldId][wPassword]); i++) format(Password, sizeof(Password), "%s*", Password);
    format(Str, sizeof(Str), "Opción\tValor\n");
    format(Str, sizeof(Str), "%sNombre\t%s\n", Str, WorldInfo[worldId][wName]);
    format(Str, sizeof(Str), "%sContraseña\t%s\n", Str, Password);
    format(Str, sizeof(Str), "%sPrivacidad\t%s\n", Str, WorldPrivacy[WorldInfo[worldId][wPrivacy]]);
    format(Str, sizeof(Str), "%sEquipo Uno\t%s\n", Str, WorldInfo[worldId][wTeamOneName]);
    format(Str, sizeof(Str), "%sEquipo Dos\t%s\n", Str, WorldInfo[worldId][wTeamTwoName]);
    format(Str, sizeof(Str), "%sRondas Máximas\t%d\n", Str, WorldInfo[worldId][wMaxRounds]);
    format(Str, sizeof(Str), "%sPuntos Máximos\t%d\n", Str, WorldInfo[worldId][wMaxPoints]);
    format(Str, sizeof(Str), "%sArmas\t%s\n", Str, WeaponInfo[weaponId][wName]);
    format(Str, sizeof(Str), "%sMapa\t%s\n", Str, MapInfo[mapId][mName]);
    return ShowPlayerDialog(playerid, DIALOG_CONFIG_WORLD, DIALOG_STYLE_TABLIST_HEADERS, "Configuración del mundo", Str, "Entrar", "Salir");
}