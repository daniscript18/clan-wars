#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <sscanf2>

main() {                                 
    return true;
}

enum _:E_DIALOGS {
    DIALOG_NO_USE,
    DIALOG_LOGIN,
    DIALOG_REGISTER,
    DIALOG_WORLDS,
    DIALOG_TEAMS,
    DIALOG_CONFIG_WORLD
};

new MySQL:Database;

#include "Modules/Players.pwn"
#include "Modules/Worlds.pwn"
#include "Modules/Commands.pwn"

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

public OnGameModeInit() {
    ClearMaps();
    ClearWeapons();
    ClearWorlds();

    mysql_log(ALL);
    Database = mysql_connect_file();
    if(mysql_errno(Database) == 0) print("Base de datos conectada.");
    else {
        print("No se pudo conectar a la base de datos.");
        return SendRconCommand("exit");
    }

    LoadMaps();
    LoadWeapons();
    LoadWorlds();

    UsePlayerPedAnims();
    return true;
}

public OnGameModeExit() {
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i)) {
            SSCANF_OnPlayerDisconnect(i, 1);
        }
    }
    SaveWorlds();
    mysql_close(Database);
    return true;
}

public OnPlayerConnect(playerid) {
    new Query[80];
    ClearPlayer(playerid);
    SetPlayerColor(playerid, -1);
    GetPlayerName(playerid, PlayerInfo[playerid][pUsername], 24);
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s' LIMIT 1", PlayerInfo[playerid][pUsername]);
    mysql_tquery(Database, Query, "ExistPlayer", "d", playerid);
    return true;
}

public OnPlayerSpawn(playerid)
{
    if(GetPVarInt(playerid, "EnteredPlayer") == 0) SetPVarInt(playerid, "EnteredPlayer", 1);
    SpawnPlayerEx(playerid);
	return 1;
}

WorldChat(playerid, const text[]) {
    new Str[512];
    if(text[0] == '!') format(Str, sizeof(Str), "%s: %s", GetPlayerNameEx(playerid), text[1]);
    else format(Str, sizeof(Str), "%s: %s", GetPlayerNameEx(playerid), text);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == PlayerInfo[playerid][pWorld]) {
            SendClientMessage(i, -1, Str);
        }
    }
    return false;
}

TeamChat(playerid, const text[]) {
    new Str[512];
    if(text[0] == '#') format(Str, sizeof(Str), "%s: %s", GetPlayerNameEx(playerid), text[1]);
    else format(Str, sizeof(Str), "%s: %s", GetPlayerNameEx(playerid), text);
    for(new i = 0; i < MAX_PLAYERS; i++) {
        if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == PlayerInfo[playerid][pWorld] && PlayerInfo[i][pTeam] == PlayerInfo[playerid][pTeam]) {
            SendClientMessage(i, -1, Str);
        }
    }
    return false;
}

public OnPlayerText(playerid, text[])
{
    if(GetPVarInt(playerid, "EnteredPlayer") == 0 ||
       PlayerInfo[playerid][pWorld] <= 0 ||
       PlayerInfo[playerid][pTeam] <= 0)
    return SendClientMessage(playerid, -1, "No puedes usar el chat en estos momentos.");

    if(text[0] == '!') return WorldChat(playerid, text);
    else if(text[0] == '#') return TeamChat(playerid, text);
    else return WorldChat(playerid, text);
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    PlayerPlaySound(issuerid, 17802, 0.0, 0.0, 0.0);
    return true;
}

public OnPlayerDisconnect(playerid, reason) {
    SavePlayer(playerid);
    return true;
}

cmd:createworld(playerid) {
    new Result = CreateWorld(), Str[100];
    format(Str, sizeof(Str), "Se creó un mundo nuevo (%d)", Result);
    SendClientMessage(playerid, -1, Str);
    return true;
}

cmd:deleteworld(playerid, params[]) {
    new Result, worldId, Str[100];
    if(sscanf(params, "d", worldId)) return SendClientMessage(playerid, -1, "Uso correcto: /deleteworld [worldId]");
    Result = DeleteWorld(worldId);
    if(Result) format(Str, sizeof(Str), "El mundo %d fue eliminado con éxito.", worldId);
    else if(!Result) format(Str, sizeof(Str), "El mundo %d no existe.", worldId);
    SendClientMessage(playerid, -1, Str);
    return true;
}

cmd:world(playerid, params[]) {
    new playerId;
    if(!sscanf(params, "d", playerId) && PlayerInfo[playerid][pAdmin] >= ADMIN_LEVEL_HELPER) {
        ShowConfigWorld(playerId);
    } else {
        ShowConfigWorld(playerid);
    }
    return true;
}

cmd:worlds(playerid, params[]) {
    new playerId;
    if(!sscanf(params, "d", playerId) && PlayerInfo[playerid][pAdmin] >= ADMIN_LEVEL_HELPER) {
        ShowWorlds(playerId);
        SetPVarInt(playerId, "NoResponseEfect", 1);
    } else {
        ShowWorlds(playerid);
        SetPVarInt(playerid, "NoResponseEfect", 1);
    }
    return true;
}

cmd:teams(playerid, params[]) {
    new playerId;
    if(!sscanf(params, "d", playerId) && PlayerInfo[playerid][pAdmin] >= ADMIN_LEVEL_HELPER) {
        ShowTeams(playerId);
        SetPVarInt(playerId, "NoResponseEfect", 1);
    } else {
        ShowTeams(playerid);
        SetPVarInt(playerid, "NoResponseEfect", 1);
    }
    return true;
}

public OnPlayerDeath(playerid, killerid, reason) {
    SpawnPlayer(playerid);
    return true;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch(dialogid) {
        case DIALOG_NO_USE: return true;
        case DIALOG_LOGIN: {
            if(!response) return Kick(playerid);
            if(strlen(inputtext) != 0 && strlen(inputtext) >= 4 && strlen(inputtext) <= 18) {
                if(!strcmp(inputtext, PlayerInfo[playerid][pPassword])) {
                    new Query[80];
                    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s' LIMIT 1", PlayerInfo[playerid][pUsername]);
                    mysql_tquery(Database, Query, "LoadPlayer", "d", playerid);
                } else {
                    new Str[130];
                    format(Str, sizeof(Str), "La cuenta (%s) fue encontrada en la base de datos.\nPor favor escribe tu contraseña para entrar.", PlayerInfo[playerid][pUsername]);
                    ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Cuenta encontrada", Str, "Entrar", "Salir");
                    SendClientMessage(playerid, -1, "La contraseña que has escrito es incorrecta.");
                }
            } else {
                new Str[130];
                format(Str, sizeof(Str), "La cuenta (%s) fue encontrada en la base de datos.\nPor favor escribe tu contraseña para entrar.", PlayerInfo[playerid][pUsername]);
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Cuenta encontrada", Str, "Entrar", "Salir");
                SendClientMessage(playerid, -1, "La contraseña debe ser de 4 a 18 caracteres.");
            }
        }
        case DIALOG_REGISTER: {
            if(!response) return Kick(playerid);
            if(strlen(inputtext) != 0 && strlen(inputtext) >= 4 && strlen(inputtext) <= 18) {
                format(PlayerInfo[playerid][pPassword], 18, "%s", inputtext);
                CreatePlayer(playerid);
            } else {
                new Str[130];
                format(Str, sizeof(Str), "La cuenta (%s) no fue encontrada en la base de datos.\nPor favor escribe una contraseña para entrar.", PlayerInfo[playerid][pUsername]);
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Cuenta no encontrada", Str, "Entrar", "Salir");
                SendClientMessage(playerid, -1, "La contraseña debe ser de 4 a 18 caracteres.");
            }
        }
        case DIALOG_WORLDS: {
            if(!response) {
                if(GetPVarInt(playerid, "NoResponseEfect") == 1) {
                    DeletePVar(playerid, "NoResponseEfect");
                    return true;
                }
                else if(GetPVarInt(playerid, "NoResponseEfect") == 0) return Kick(playerid);
            }
            new worldId = strval(inputtext);
            PlayerInfo[playerid][pWorld] = WorldInfo[worldId][wId];
            SetPlayerVirtualWorld(playerid, WorldInfo[worldId][wWorld]);
            ShowTeams(playerid);
        }
        case DIALOG_TEAMS: {
            if(!response) {
                if(GetPVarInt(playerid, "NoResponseEfect") == 1) {
                    DeletePVar(playerid, "NoResponseEfect");
                    return true;
                }
                else if(GetPVarInt(playerid, "NoResponseEfect") == 0) return ShowWorlds(playerid);
            }
            new mapId = WorldInfo[PlayerInfo[playerid][pWorld]][wMap];
            switch(listitem) {
                case WORLD_TEAM_SPECTATOR: {
                    PlayerInfo[playerid][pTeam] = WORLD_TEAM_SPECTATOR;
                    SetSpawnInfo(playerid, NO_TEAM, 124, MapInfo[mapId][mSpecX], MapInfo[mapId][mSpecY], MapInfo[mapId][mSpecZ], MapInfo[mapId][mSpecA], 0, 0, 0, 0, 0, 0);
                    SpawnPlayer(playerid);
                }
                case WORLD_TEAM_ONE: {
                    PlayerInfo[playerid][pTeam] = WORLD_TEAM_ONE;
                    SetSpawnInfo(playerid, NO_TEAM, 124, MapInfo[mapId][mTeamOneX], MapInfo[mapId][mTeamOneY], MapInfo[mapId][mTeamOneZ], MapInfo[mapId][mTeamOneA], 0, 0, 0, 0, 0, 0);
                    SpawnPlayer(playerid);
                }
                case WORLD_TEAM_TWO: {
                    PlayerInfo[playerid][pTeam] = WORLD_TEAM_TWO;
                    SetSpawnInfo(playerid, NO_TEAM, 124, MapInfo[mapId][mTeamTwoX], MapInfo[mapId][mTeamTwoY], MapInfo[mapId][mTeamTwoZ], MapInfo[mapId][mTeamTwoA], 0, 0, 0, 0, 0, 0);
                    SpawnPlayer(playerid);
                }
            }
        }
        case DIALOG_CONFIG_WORLD: {
            if(!response) return true;
            return true;
        }
        default: return false;
    }
    return true;
}