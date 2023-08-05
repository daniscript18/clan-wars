GivePlayerWeaponEx(playerid) {
    if(PlayerInfo[playerid][pTeam] == WORLD_TEAM_SPECTATOR) return false;
    new weaponId = WorldInfo[PlayerInfo[playerid][pWorld]][wWeapons];
    ResetPlayerWeapons(playerid);
    if(WeaponInfo[weaponId][wWeapon1] != -1) GivePlayerWeapon(playerid, WeaponInfo[weaponId][wWeapon1], WeaponInfo[weaponId][wAmmo1]);
    if(WeaponInfo[weaponId][wWeapon2] != -1) GivePlayerWeapon(playerid, WeaponInfo[weaponId][wWeapon2], WeaponInfo[weaponId][wAmmo2]);
    if(WeaponInfo[weaponId][wWeapon3] != -1) GivePlayerWeapon(playerid, WeaponInfo[weaponId][wWeapon3], WeaponInfo[weaponId][wAmmo3]);
    if(WeaponInfo[weaponId][wWeapon4] != -1) GivePlayerWeapon(playerid, WeaponInfo[weaponId][wWeapon4], WeaponInfo[weaponId][wAmmo4]);
    return true;
}

SpawnPlayerEx(playerid) {
    new worldId = PlayerInfo[playerid][pWorld];
    new mapId = WorldInfo[worldId][wMap];
    SetPlayerHealth(playerid, 100);
    switch(PlayerInfo[playerid][pTeam]) {
        case WORLD_TEAM_SPECTATOR: {
            SetPlayerSkin(playerid, 124);
            SetPlayerVirtualWorld(playerid, WorldInfo[worldId][wWorld]);
            SetPlayerPos(playerid, MapInfo[mapId][mSpecX], MapInfo[mapId][mSpecY], MapInfo[mapId][mSpecZ]);
            SetPlayerFacingAngle(playerid, MapInfo[mapId][mSpecA]);
        }
        case WORLD_TEAM_ONE: {
            SetPlayerSkin(playerid, 124);
            SetPlayerVirtualWorld(playerid, WorldInfo[worldId][wWorld]);
            SetPlayerPos(playerid, MapInfo[mapId][mTeamOneX], MapInfo[mapId][mTeamOneY], MapInfo[mapId][mTeamOneZ]);
            SetPlayerFacingAngle(playerid, MapInfo[mapId][mTeamOneA]);
            GivePlayerWeaponEx(playerid);
        }
        case WORLD_TEAM_TWO: {
            SetPlayerSkin(playerid, 124);
            SetPlayerVirtualWorld(playerid, WorldInfo[worldId][wWorld]);
            SetPlayerPos(playerid, MapInfo[mapId][mTeamTwoX], MapInfo[mapId][mTeamTwoY], MapInfo[mapId][mTeamTwoZ]);
            SetPlayerFacingAngle(playerid, MapInfo[mapId][mTeamTwoA]);
            GivePlayerWeaponEx(playerid);
        }
    }
	
	SetCameraBehindPlayer(playerid);
    return true;
}

ClearChat(playerid) {
    for(new i = 0; i < 20; i++) SendClientMessage(playerid, -1, " ");
    return true;
}

forward KickEx(playerid);
public KickEx(playerid) {
    return Kick(playerid);
}

FormatTimeLeft(start, end) {
	new Time = end - start, Str[356], DateTime[4] = 0;
    if(floatround(Time / 86400) > 0) {
        DateTime[3] = floatround(Time / 86400);
        Time -= (DateTime[3] * 86400);
    }
    if(floatround(Time / 3600) > 0) {
        DateTime[2] = floatround(Time / 3600);
        Time -= (DateTime[2] * 3600);
    }
    if(floatround(Time / 60) > 0) {
        DateTime[1] = floatround(Time / 60);
        Time -= (DateTime[1] * 60);
    }
    DateTime[0] = Time;
    if(DateTime[3] > 0) format(Str, sizeof(Str), "%dd ", DateTime[3]);
    if(DateTime[2] > 0) format(Str, sizeof(Str), "%s%dh ", Str, DateTime[2]);
    if(DateTime[1] > 0) format(Str, sizeof(Str), "%s%dm ", Str, DateTime[1]);
    if(DateTime[0] > 0) format(Str, sizeof(Str), "%s%ds ", Str, DateTime[0]);
	return Str;
}

FormatCurrentTime() {
    new Str[32], day, month, year, hour, minute, second;
    getdate(year, month, day);
    gettime(hour, minute, second);
    format(Str, sizeof(Str), "%d/%d/%d %d:%d:%d", day, month, year, hour, minute, second);
    return Str;
}