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
    DIALOG_WORLDS
};

new MySQL:Database;

#include "Modules/Players.pwn"
#include "Modules/Worlds.pwn"
#include "Modules/Commands.pwn"

public OnGameModeInit() {
    ClearWorlds();

    mysql_log(ALL);
    Database = mysql_connect_file();
    if(mysql_errno(Database) == 0) {
        print("Base de datos conectada.");
    } else {
        print("No se pudo conectar a la base de datos.");
        SendRconCommand("exit");
    }

    LoadWorlds();
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
    GetPlayerName(playerid, PlayerInfo[playerid][pUsername], 24);
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s' LIMIT 1", PlayerInfo[playerid][pUsername]);
    mysql_tquery(Database, Query, "ExistPlayer", "d", playerid);
    return true;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	SetPlayerFacingAngle(playerid, 270.1425);

	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    SavePlayer(playerid);
    return true;
}

cmd:user(playerid, params[]) {
    new Str[512], playerId;
    if(!sscanf(params, "d", playerId)) {
        format(Str, sizeof(Str), "PlayerInfo[%d][pId] = %d\n", playerId, PlayerInfo[playerId][pId]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pIp] = %s\n", Str, playerId, PlayerInfo[playerId][pIp]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pUsername] = %s\n", Str, playerId, PlayerInfo[playerId][pUsername]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pPassword] = %s\n", Str, playerId, PlayerInfo[playerId][pPassword]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pAdmin] = %d\n", Str, playerId, PlayerInfo[playerId][pAdmin]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pWorld] = %d", Str, playerId, PlayerInfo[playerId][pWorld]);
    } else {
        format(Str, sizeof(Str), "PlayerInfo[%d][pId] = %d\n", playerid, PlayerInfo[playerid][pId]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pIp] = %s\n", Str, playerid, PlayerInfo[playerid][pIp]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pUsername] = %s\n", Str, playerid, PlayerInfo[playerid][pUsername]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pPassword] = %s\n", Str, playerid, PlayerInfo[playerid][pPassword]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pAdmin] = %d\n", Str, playerid, PlayerInfo[playerid][pAdmin]);
        format(Str, sizeof(Str), "%sPlayerInfo[%d][pWorld] = %d", Str, playerid, PlayerInfo[playerid][pWorld]);
    }
    ShowPlayerDialog(playerid, DIALOG_NO_USE, DIALOG_STYLE_TABLIST, " ", Str, "Cerrar", "");
    return true;
}

cmd:world(playerid, params[]) {
    new Str[512], worldId = PlayerInfo[playerid][pWorld];
    if(!sscanf(params, "d", worldId)) {
        format(Str, sizeof(Str), "WorldInfo[%d][wId] = %d\n", worldId, WorldInfo[worldId][wId]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wName] = %s\n", Str, worldId, WorldInfo[worldId][wName]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wPassword] = %s\n", Str, worldId, WorldInfo[worldId][wPassword]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wWorld] = %d\n", Str, worldId, WorldInfo[worldId][wWorld]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wState] = %d\n", Str, worldId, WorldInfo[worldId][wState]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wPrivacy] = %d\n", Str, worldId, WorldInfo[worldId][wPrivacy]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamOneName] = %s\n", Str, worldId, WorldInfo[worldId][wTeamOneName]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamTwoName] = %s\n", Str, worldId, WorldInfo[worldId][wTeamTwoName]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wMaxRounds] = %d\n", Str, worldId, WorldInfo[worldId][wMaxRounds]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wMaxPoints] = %d\n", Str, worldId, WorldInfo[worldId][wMaxPoints]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamOneRounds] = %d\n", Str, worldId, WorldInfo[worldId][wTeamOneRounds]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamTwoRounds] = %d\n", Str, worldId, WorldInfo[worldId][wTeamTwoRounds]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamOnePoints] = %d\n", Str, worldId, WorldInfo[worldId][wTeamOnePoints]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamTwoPoints] = %d", Str, worldId, WorldInfo[worldId][wTeamTwoPoints]);
    } else {
        format(Str, sizeof(Str), "WorldInfo[%d][wId] = %d\n", worldId, WorldInfo[worldId][wId]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wName] = %s\n", Str, worldId, WorldInfo[worldId][wName]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wPassword] = %s\n", Str, worldId, WorldInfo[worldId][wPassword]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wWorld] = %d\n", Str, worldId, WorldInfo[worldId][wWorld]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wState] = %d\n", Str, worldId, WorldInfo[worldId][wState]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wPrivacy] = %d\n", Str, worldId, WorldInfo[worldId][wPrivacy]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamOneName] = %s\n", Str, worldId, WorldInfo[worldId][wTeamOneName]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamTwoName] = %s\n", Str, worldId, WorldInfo[worldId][wTeamTwoName]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wMaxRounds] = %d\n", Str, worldId, WorldInfo[worldId][wMaxRounds]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wMaxPoints] = %d\n", Str, worldId, WorldInfo[worldId][wMaxPoints]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamOneRounds] = %d\n", Str, worldId, WorldInfo[worldId][wTeamOneRounds]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamTwoRounds] = %d\n", Str, worldId, WorldInfo[worldId][wTeamTwoRounds]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamOnePoints] = %d\n", Str, worldId, WorldInfo[worldId][wTeamOnePoints]);
        format(Str, sizeof(Str), "%sWorldInfo[%d][wTeamTwoPoints] = %d", Str, worldId, WorldInfo[worldId][wTeamTwoPoints]);
    }
    ShowPlayerDialog(playerid, DIALOG_NO_USE, DIALOG_STYLE_TABLIST, " ", Str, "Cerrar", "");
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
            if(!response) return Kick(playerid);
            new worldId = strval(inputtext);
            PlayerInfo[playerid][pWorld] = WorldInfo[worldId][wId];
            SetPlayerVirtualWorld(playerid, WorldInfo[worldId][wWorld]);
            SetSpawnInfo(playerid, NO_TEAM, 124, 1958.3783, 1343.1572, 15.3746, 270.1425, 0, 0, 0, 0, 0, 0);
            SpawnPlayer(playerid);
        }
        default: return false;
    }
    return true;
}