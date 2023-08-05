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
    DIALOG_CONFIG_WORLD,
    DIALOG_CONFIG_WORLD_NAME,
    DIALOG_CONFIG_WORLD_PASSWORD,
    DIALOG_CONFIG_WORLD_TEAM_ONE,
    DIALOG_CONFIG_WORLD_TEAM_TWO,
    DIALOG_CONFIG_WORLD_MAX_ROUNDS,
    DIALOG_CONFIG_WORLD_MAX_POINTS,
    DIALOG_CONFIG_WORLD_WEAPONS,
    DIALOG_CONFIG_WORLD_MAPS
};

new MySQL:Database;

#include "Modules/Players.pwn"
#include "Modules/Worlds.pwn"
#include "Modules/Commands.pwn"
#include "Modules/Utils.pwn"

public OnGameModeInit() {
    ClearMaps();
    ClearWeapons();
    ClearWorlds();

    mysql_log(ALL);
    Database = mysql_connect_file();
    if(mysql_errno(Database) == 0) print("Database connected");
    else {
        print("Could not connect to the database");
        return SendRconCommand("exit");
    }

    LoadMaps();
    LoadWeapons();
    LoadWorlds();

    UsePlayerPedAnims();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
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
    TogglePlayerSpectating(playerid, 1);
    
    InterpolateCameraPos(playerid, 0.0, 0.0, 10.0, 1000.0, 1000.0, 30.0, 30000, CAMERA_MOVE);
    InterpolateCameraLookAt(playerid, 50.0, 50.0, 10.0, -50.0, 50.0, 10.0, 30000, CAMERA_MOVE);
    mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s' LIMIT 1", PlayerInfo[playerid][pUsername]);
    mysql_tquery(Database, Query, "ExistPlayer", "d", playerid);
    return true;
}

public OnPlayerSpawn(playerid)
{
    if(GetPVarInt(playerid, "EnteredPlayer") == 0) {
        TogglePlayerSpectating(playerid, 0);
        SetCameraBehindPlayer(playerid);
        StopAudioStreamForPlayer(playerid);
        SetPVarInt(playerid, "EnteredPlayer", 1);
        ClearChat(playerid);
    }
    SpawnPlayerEx(playerid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
    if(GetPVarInt(playerid, "EnteredPlayer") == 0 ||
       PlayerInfo[playerid][pWorld] <= 0 ||
       PlayerInfo[playerid][pTeam] == -1)
    return SendClientMessage(playerid, -1, "No puedes usar el chat en estos momentos.");
    if(GetPVarInt(playerid, "Mute") >= -1 && gettime() >= GetPVarInt(playerid, "Mute")) {
        new Query[128];
        mysql_format(Database, Query, sizeof(Query), "DELETE FROM `mutes` WHERE `PlayerId` = %d", PlayerInfo[playerid][pId]);
        mysql_query(Database, Query, false);
    } else {
        new Str[256];
        if(GetPVarInt(playerid, "Mute") == -2) Str = "No puedes hablar por el chat hasta que un admin te lo permita.";
        else format(Str, sizeof(Str), "No puedes hablar por el chat durante %s", FormatTimeLeft(gettime(), GetPVarInt(playerid, "Mute")));
        SendClientMessage(playerid, -1, Str);
        return false;
    }

    if(text[0] == '@' && PlayerInfo[playerid][pAdmin] > ADMIN_LEVEL_NONE || IsPlayerAdmin(playerid)) return AdminChat(playerid, text);
    else if(text[0] == '!') return WorldChat(playerid, text);
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
    new worldId;
    if(!sscanf(params, "d", worldId)) {
        if(!ExistWorld(worldId)) return SendClientMessage(playerid, -1, "Ese mundo no existe.");
        ShowConfigWorld(playerid, worldId);
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

cmd:setadmin(playerid, params[]) {
    new id[2], adminLevel, name[24]; id[0] = playerid;
    if(!sscanf(params, "dd", id[1], adminLevel)) {
        if(!IsPlayerConnected(id[1])) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]d", name, adminLevel)) {
        id[1] = IsPlayerConnectedEx(name);
        if(id[1] <= -1) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /setadmin [playerid/name] [adminLevel (0 - 4)]");
    if(!IsPlayerAdmin(id[0]) && id[0] == id[1]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(adminLevel > 4 || adminLevel < 0) return SendClientMessage(id[0], -1, "El nivel mínimo es 0 y el nivel máximo es 4.");
    if(!IsPlayerAdmin(id[0]) && PlayerInfo[id[1]][pAdmin] >= PlayerInfo[id[0]][pAdmin] || IsPlayerAdmin(id[1])) return SendClientMessage(playerid, -1, "No puedes hacer eso.");
    new oldLevel = PlayerInfo[id[1]][pAdmin], newLevel = adminLevel, Str[128];
    if(oldLevel == newLevel) return SendClientMessage(id[0], -1, "Esa persona ya tiene ese nivel administrativo.");
    if(oldLevel > newLevel) format(Str, sizeof(Str), "Fuiste descendido a %s.", AdminLevels[newLevel][1]);
    if(oldLevel < newLevel) format(Str, sizeof(Str), "Fuiste ascendido a %s.", AdminLevels[newLevel][1]);
    if(newLevel == 0) format(Str, sizeof(Str), "Fuiste expulsado de la administración.");
    PlayerInfo[id[1]][pAdmin] = newLevel;
    SendClientMessage(id[0], -1, "Se cambió el nivel administrativo del jugador.");
    SendClientMessage(id[1], -1, Str);
    return true;
}

cmd:setadmindb(playerid, params[]) {
    new id[3], admin, adminLevel, name[24], Query[128]; id[0] = playerid;
    if(!sscanf(params, "dd", id[1], adminLevel)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Id` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "El jugador no está en la base de datos o pusiste mal su id.");
        cache_get_value_name_int(0, "Admin", admin);
    } else if(!sscanf(params, "s[24]d", name, adminLevel)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s'", name);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "El jugador no está en la base de datos o pusiste mal su nombre.");
        cache_get_value_name_int(0, "Id", id[1]);
        cache_get_value_name_int(0, "Admin", admin);
    } else return SendClientMessage(id[0], -1, "Uso correcto: /setadmindb [id/name] [adminLevel (0 - 4)]");
    if(!IsPlayerAdmin(id[0]) && id[1] == PlayerInfo[id[0]][pId]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(adminLevel > 4 || adminLevel < 0) return SendClientMessage(id[0], -1, "El nivel mínimo es 0 y el nivel máximo es 4.");
    if(!IsPlayerAdmin(id[0]) && admin >= PlayerInfo[id[0]][pAdmin]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(admin == adminLevel) return SendClientMessage(id[0], -1, "Esa persona ya tiene ese nivel administrativo.");
    mysql_format(Database, Query, sizeof(Query), "UPDATE `players` SET `Admin` = %d WHERE `Id` = %d", adminLevel, id[1]);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "Se cambió el nivel administrativo del jugador.");
    id[2] = IsPlayerConnectedEx(GetPlayerNameDB(id[1]));
    if(id[2] > -1) {
        new Str[128];
        if(admin > adminLevel) format(Str, sizeof(Str), "Fuiste descendido a %s.", AdminLevels[adminLevel][1]);
        if(admin < adminLevel) format(Str, sizeof(Str), "Fuiste ascendido a %s.", AdminLevels[adminLevel][1]);
        if(adminLevel == 0) format(Str, sizeof(Str), "Fuiste expulsado de la administración.");
        SendClientMessage(id[2], -1, Str);
    }
    return true;
}

cmd:ban(playerid, params[]) {
    new id[2], reason[32], time[24], name[24], Query[256]; id[0] = playerid;
    if(!sscanf(params, "dS(none)[24]S(Sin especificar)[32]", id[1], time, reason)) {
        if(!IsPlayerConnected(id[1])) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]S(none)[24]S(Sin especificar)[32]", name, time, reason)) {
        id[1] = IsPlayerConnectedEx(name);
        if(id[1] <= -1) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /ban [playerid/name] (time(s,m,h,d,none)) (reason)");
    new newTime, CurrentTime[32], Str[256];
    if(strcmp(time, "none")) {
        new del[4];
        del[0] = strfind(time, "s", true);
        del[1] = strfind(time, "m", true);
        del[2] = strfind(time, "h", true);
        del[3] = strfind(time, "d", true);
        if(del[0] != -1 || del[1] != -1 || del[2] != -1 || del[3] != -1) {
            if(del[0] != -1 && del[1] != -1 && del[2] != -1 && del[3] != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
            if(del[0] != -1) {
                strdel(time, del[0], del[0]+1);
                if(strfind(time, "s", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + strval(time);
            }
            if(del[1] != -1) {
                strdel(time, del[1], del[1]+1);
                if(strfind(time, "m", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 60);
            }
            if(del[2] != -1) {
                strdel(time, del[2], del[2]+1);
                if(strfind(time, "h", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 3600);
            }
            if(del[3] != -1) {
                strdel(time, del[3], del[3]+1);
                if(strfind(time, "d", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 86400);
            }
        } else return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
    } else newTime = -1;
    if(IsBanned(PlayerInfo[id[1]][pId])) return SendClientMessage(id[0], -1, "Esa cuenta ya está baneada.");
    if(!IsPlayerAdmin(id[0]) && id[0] == id[1]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(!IsPlayerAdmin(id[0]) && PlayerInfo[id[1]][pAdmin] >= PlayerInfo[id[0]][pAdmin] || IsPlayerAdmin(id[1])) return SendClientMessage(playerid, -1, "No puedes hacer eso.");
    format(CurrentTime, sizeof(CurrentTime), "%s", FormatCurrentTime());
    mysql_format(Database, Query, sizeof(Query), "INSERT INTO `bans` (`PlayerId`, `AdminId`, `Reason`, `DateTime`, `Time`) VALUES (%d, %d, '%s', '%s', %d)", PlayerInfo[id[1]][pId], PlayerInfo[id[0]][pId], reason, CurrentTime, newTime);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "El usuario ha sido bloqueado del servidor.");
    format(Str, sizeof(Str), "Razón: %s\n", reason);
    format(Str, sizeof(Str), "%sAdministrador: %s\n", Str, GetPlayerNameEx(id[0]));
    format(Str, sizeof(Str), "%sFecha de bloqueo: %s\n", Str, CurrentTime);
    if(newTime == -1) format(Str, sizeof(Str), "%sTiempo restante: Bloqueo permanente", Str);
    else format(Str, sizeof(Str), "%sTiempo restante: %s", Str, FormatTimeLeft(gettime(), newTime));
    ShowPlayerDialog(id[1], DIALOG_NO_USE, DIALOG_STYLE_MSGBOX, "Tu cuenta fue bloqueada", Str, "Cerrar", "");
    SetTimerEx("KickEx", 1000, false, "d", id[1]);
    return true;
}

cmd:bandb(playerid, params[]) {
    new id[3], admin, reason[32], time[24], name[24], Query[256]; id[0] = playerid, id[1] = -1;
    if(!sscanf(params, "dS(none)[24]S(Sin especificar)[32]", id[1], time, reason)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Id` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "El jugador no está en la base de datos o pusiste mal su id.");
        cache_get_value_name_int(0, "Admin", admin);
    } else if(!sscanf(params, "s[24]S(none)[24]S(Sin especificar)[32]", name, time, reason)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s'", name);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "El jugador no está en la base de datos o pusiste mal su nombre.");
        cache_get_value_name_int(0, "Id", id[1]);
        cache_get_value_name_int(0, "Admin", admin);
    } else return SendClientMessage(id[0], -1, "Uso correcto: /bandb [id/name] (time(s,m,h,d,none)) (reason)");
    new newTime, CurrentTime[32], Str[256];
    if(strcmp(time, "none")) {
        new del[4];
        del[0] = strfind(time, "s", true);
        del[1] = strfind(time, "m", true);
        del[2] = strfind(time, "h", true);
        del[3] = strfind(time, "d", true);
        if(del[0] != -1 || del[1] != -1 || del[2] != -1 || del[3] != -1) {
            if(del[0] != -1 && del[1] != -1 && del[2] != -1 && del[3] != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
            if(del[0] != -1) {
                strdel(time, del[0], del[0]+1);
                if(strfind(time, "s", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + strval(time);
            }
            if(del[1] != -1) {
                strdel(time, del[1], del[1]+1);
                if(strfind(time, "m", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 60);
            }
            if(del[2] != -1) {
                strdel(time, del[2], del[2]+1);
                if(strfind(time, "h", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 3600);
            }
            if(del[3] != -1) {
                strdel(time, del[3], del[3]+1);
                if(strfind(time, "d", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 86400);
            }
        } else return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
    } else newTime = -1;
    if(IsBanned(id[1])) return SendClientMessage(id[0], -1, "Esa cuenta ya está baneada.");
    if(!IsPlayerAdmin(id[0]) && PlayerInfo[id[0]][pId] == id[1]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(!IsPlayerAdmin(id[0]) && admin >= PlayerInfo[id[0]][pAdmin]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    format(CurrentTime, sizeof(CurrentTime), "%s", FormatCurrentTime());
    mysql_format(Database, Query, sizeof(Query), "INSERT INTO `bans` (`PlayerId`, `AdminId`, `Reason`, `DateTime`, `Time`) VALUES (%d, %d, '%s', '%s', %d)", id[1], PlayerInfo[id[0]][pId], reason, CurrentTime, newTime);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "El usuario ha sido bloqueado del servidor.");
    id[2] = IsPlayerConnectedEx(GetPlayerNameDB(id[1]));
    if(id[2] > -1) {
        format(Str, sizeof(Str), "Razón: %s\n", reason);
        format(Str, sizeof(Str), "%sAdministrador: %s\n", Str, GetPlayerNameEx(id[0]));
        format(Str, sizeof(Str), "%sFecha de bloqueo: %s\n", Str, CurrentTime);
        if(newTime == -1) format(Str, sizeof(Str), "%sTiempo restante: Bloqueo permanente", Str);
        else format(Str, sizeof(Str), "%sTiempo restante: %s", Str, FormatTimeLeft(gettime(), newTime));
        ShowPlayerDialog(id[2], DIALOG_NO_USE, DIALOG_STYLE_MSGBOX, "Tu cuenta fue bloqueada", Str, "Cerrar", "");
        SetTimerEx("KickEx", 1000, false, "d", id[2]);
    }
    return true;
}

cmd:unban(playerid, params[]) {
    new id[2], name[24], Query[256]; id[0] = playerid, id[1] = -1;
    if(!sscanf(params, "d", id[1])) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `bans` WHERE `PlayerId` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "La cuenta no está bloqueada o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]", name)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s'", name);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "La cuenta no está bloqueada o pusiste mal su nombre.");
        cache_get_value_name_int(0, "Id", id[1]);
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `bans` WHERE `PlayerId` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "La cuenta no está bloqueada o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /unban [id/name]");
    mysql_format(Database, Query, sizeof(Query), "DELETE FROM `bans` WHERE `PlayerId` = %d", id[1]);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "La cuenta fue desbloqueada.");
    return true;
}

cmd:kick(playerid, params[]) {
    new id[2], reason[32], name[24], Str[128]; id[0] = playerid;
    if(!sscanf(params, "dS(Sin especificar)[32]", id[1], reason)) {
        if(!IsPlayerConnected(id[1])) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]S(Sin especificar)[32]", name, reason)) {
        id[1] = IsPlayerConnectedEx(name);
        if(id[1] <= -1) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /kick [playerid/name] (reason)");
    if(!IsPlayerAdmin(id[0]) && id[0] == id[1]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(!IsPlayerAdmin(id[0]) && PlayerInfo[id[1]][pAdmin] >= PlayerInfo[id[0]][pAdmin] || IsPlayerAdmin(id[1])) return SendClientMessage(playerid, -1, "No puedes hacer eso.");
    SendClientMessage(id[0], -1, "El usuario ha sido expulsado del servidor.");
    format(Str, sizeof(Str), "Razón: %s\n", reason);
    format(Str, sizeof(Str), "%sAdministrador: %s\n", Str, GetPlayerNameEx(id[0]));
    format(Str, sizeof(Str), "%sFecha de expulsión: %s", Str, FormatCurrentTime());
    ShowPlayerDialog(id[1], DIALOG_NO_USE, DIALOG_STYLE_MSGBOX, "Tu cuenta fue expulsada", Str, "Cerrar", "");
    SetTimerEx("KickEx", 1000, false, "d", id[1]);
    return true;
}

cmd:mute(playerid, params[]) {
    new id[2], reason[32], time[24], name[24], Query[256]; id[0] = playerid;
    if(!sscanf(params, "dS(none)[24]S(Sin especificar)[32]", id[1], time, reason)) {
        if(!IsPlayerConnected(id[1])) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]S(none)[24]S(Sin especificar)[32]", name, time, reason)) {
        id[1] = IsPlayerConnectedEx(name);
        if(id[1] <= -1) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /mute [playerid/name] (time(s,m,h,d,none)) (reason)");
    new newTime, CurrentTime[32], Str[256];
    if(strcmp(time, "none")) {
        new del[4];
        del[0] = strfind(time, "s", true);
        del[1] = strfind(time, "m", true);
        del[2] = strfind(time, "h", true);
        del[3] = strfind(time, "d", true);
        if(del[0] != -1 || del[1] != -1 || del[2] != -1 || del[3] != -1) {
            if(del[0] != -1 && del[1] != -1 && del[2] != -1 && del[3] != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
            if(del[0] != -1) {
                strdel(time, del[0], del[0]+1);
                if(strfind(time, "s", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + strval(time);
            }
            if(del[1] != -1) {
                strdel(time, del[1], del[1]+1);
                if(strfind(time, "m", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 60);
            }
            if(del[2] != -1) {
                strdel(time, del[2], del[2]+1);
                if(strfind(time, "h", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 3600);
            }
            if(del[3] != -1) {
                strdel(time, del[3], del[3]+1);
                if(strfind(time, "d", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 86400);
            }
        } else return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
    } else newTime = -2;
    if(IsMuted(PlayerInfo[id[1]][pId])) return SendClientMessage(id[0], -1, "Esa cuenta ya está silenciada.");
    if(!IsPlayerAdmin(id[0]) && id[0] == id[1]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(!IsPlayerAdmin(id[0]) && PlayerInfo[id[1]][pAdmin] >= PlayerInfo[id[0]][pAdmin] || IsPlayerAdmin(id[1])) return SendClientMessage(playerid, -1, "No puedes hacer eso.");
    format(CurrentTime, sizeof(CurrentTime), "%s", FormatCurrentTime());
    mysql_format(Database, Query, sizeof(Query), "INSERT INTO `mutes` (`PlayerId`, `AdminId`, `Reason`, `DateTime`, `Time`) VALUES (%d, %d, '%s', '%s', %d)", PlayerInfo[id[1]][pId], PlayerInfo[id[0]][pId], reason, CurrentTime, newTime);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "El usuario ha sido silenciado.");
    format(Str, sizeof(Str), "Razón: %s\n", reason);
    format(Str, sizeof(Str), "%sAdministrador: %s\n", Str, GetPlayerNameEx(id[0]));
    format(Str, sizeof(Str), "%sFecha de silencio: %s\n", Str, CurrentTime);
    if(newTime == -2) format(Str, sizeof(Str), "%sTiempo restante: Silencio permanente", Str);
    else format(Str, sizeof(Str), "%sTiempo restante: %s", Str, FormatTimeLeft(gettime(), newTime));
    ShowPlayerDialog(id[1], DIALOG_NO_USE, DIALOG_STYLE_MSGBOX, "Tu cuenta fue silenciada", Str, "Cerrar", "");
    SetPVarInt(id[1], "Mute", newTime);
    return true;
}

cmd:mutedb(playerid, params[]) {
    new id[3], admin, reason[32], time[24], name[24], Query[256]; id[0] = playerid, id[1] = -1;
    if(!sscanf(params, "dS(none)[24]S(Sin especificar)[32]", id[1], time, reason)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Id` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "El jugador no está en la base de datos o pusiste mal su id.");
        cache_get_value_name_int(0, "Admin", admin);
    } else if(!sscanf(params, "s[24]S(none)[24]S(Sin especificar)[32]", name, time, reason)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s'", name);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "El jugador no está en la base de datos o pusiste mal su nombre.");
        cache_get_value_name_int(0, "Id", id[1]);
        cache_get_value_name_int(0, "Admin", admin);
    } else return SendClientMessage(id[0], -1, "Uso correcto: /mutedb [id/name] (time(s,m,h,d,none)) (reason)");
    new newTime, CurrentTime[32], Str[256];
    if(strcmp(time, "none")) {
        new del[4];
        del[0] = strfind(time, "s", true);
        del[1] = strfind(time, "m", true);
        del[2] = strfind(time, "h", true);
        del[3] = strfind(time, "d", true);
        if(del[0] != -1 || del[1] != -1 || del[2] != -1 || del[3] != -1) {
            if(del[0] != -1 && del[1] != -1 && del[2] != -1 && del[3] != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
            if(del[0] != -1) {
                strdel(time, del[0], del[0]+1);
                if(strfind(time, "s", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + strval(time);
            }
            if(del[1] != -1) {
                strdel(time, del[1], del[1]+1);
                if(strfind(time, "m", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 60);
            }
            if(del[2] != -1) {
                strdel(time, del[2], del[2]+1);
                if(strfind(time, "h", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 3600);
            }
            if(del[3] != -1) {
                strdel(time, del[3], del[3]+1);
                if(strfind(time, "d", true) != -1) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                if(strval(time) <= 0) return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
                newTime = gettime() + (strval(time) * 86400);
            }
        } else return SendClientMessage(id[0], -1, "Estás poniendo mal el tiempo, ejemplo de uso: 1d = 1 día, 1h = 1 hora, 1m = 1 minuto, 1s = 1 segundo");
    } else newTime = -2;
    if(IsMuted(id[1])) return SendClientMessage(id[0], -1, "Esa cuenta ya está silenciada.");
    if(!IsPlayerAdmin(id[0]) && PlayerInfo[id[0]][pId] == id[1]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    if(!IsPlayerAdmin(id[0]) && admin >= PlayerInfo[id[0]][pAdmin]) return SendClientMessage(id[0], -1, "No puedes hacer eso.");
    format(CurrentTime, sizeof(CurrentTime), "%s", FormatCurrentTime());
    mysql_format(Database, Query, sizeof(Query), "INSERT INTO `mutes` (`PlayerId`, `AdminId`, `Reason`, `DateTime`, `Time`) VALUES (%d, %d, '%s', '%s', %d)", id[1], PlayerInfo[id[0]][pId], reason, CurrentTime, newTime);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "El usuario ha sido silenciado.");
    id[2] = IsPlayerConnectedEx(GetPlayerNameDB(id[1]));
    if(id[2] > -1) {
        format(Str, sizeof(Str), "Razón: %s\n", reason);
        format(Str, sizeof(Str), "%sAdministrador: %s\n", Str, GetPlayerNameEx(id[0]));
        format(Str, sizeof(Str), "%sFecha de bloqueo: %s\n", Str, CurrentTime);
        if(newTime == -2) format(Str, sizeof(Str), "%sTiempo restante: Silencio permanente", Str);
        else format(Str, sizeof(Str), "%sTiempo restante: %s", Str, FormatTimeLeft(gettime(), newTime));
        ShowPlayerDialog(id[2], DIALOG_NO_USE, DIALOG_STYLE_MSGBOX, "Tu cuenta fue silenciada", Str, "Cerrar", "");
        SetPVarInt(id[2], "Mute", newTime);
    }
    return true;
}

cmd:unmute(playerid, params[]) {
    new id[2], name[24], Query[256]; id[0] = playerid, id[1] = -1;
    if(!sscanf(params, "d", id[1])) {
        if(!IsPlayerConnected(id[1])) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]", name)) {
        id[1] = IsPlayerConnectedEx(name);
        if(id[1] <= -1) return SendClientMessage(id[0], -1, "El jugador no está conectado o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /unmute [playerid/name]");
    if(!IsMuted(id[1])) return SendClientMessage(id[0], -1, "Esa cuenta no está silenciada.");
    mysql_format(Database, Query, sizeof(Query), "DELETE FROM `mutes` WHERE `PlayerId` = %d", PlayerInfo[id[1]][pId]);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "La cuenta fue desilenciada.");
    SendClientMessage(id[1], -1, "Tu cuenta fue desilenciada.");
    SetPVarInt(id[1], "Mute", -1);
    return true;
}

cmd:unmutedb(playerid, params[]) {
    new id[3], name[24], Query[256]; id[0] = playerid, id[1] = -1;
    if(!sscanf(params, "d", id[1])) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `mutes` WHERE `PlayerId` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "La cuenta no está bloqueada o pusiste mal su id.");
    } else if(!sscanf(params, "s[24]", name)) {
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `players` WHERE `Username` = '%s'", name);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "La cuenta no está bloqueada o pusiste mal su nombre.");
        cache_get_value_name_int(0, "Id", id[1]);
        mysql_format(Database, Query, sizeof(Query), "SELECT * FROM `mutes` WHERE `PlayerId` = %d", id[1]);
        mysql_query(Database, Query);
        if(cache_num_rows() == 0) return SendClientMessage(id[0], -1, "La cuenta no está bloqueada o pusiste mal su nombre.");
    } else return SendClientMessage(id[0], -1, "Uso correcto: /unmutedb [id/name]");
    mysql_format(Database, Query, sizeof(Query), "DELETE FROM `mutes` WHERE `PlayerId` = %d", id[1]);
    mysql_query(Database, Query, false);
    SendClientMessage(id[0], -1, "La cuenta fue desilenciada.");
    id[2] = IsPlayerConnectedEx(GetPlayerNameDB(id[1]));
    if(id[2] > -1) {
        SendClientMessage(id[2], -1, "Tu cuenta fue desilenciada.");
        SetPVarInt(id[2], "Mute", -1);
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
            new style, caption[128], info[356], button1[32], button2[32];
            switch(listitem) {
                case 0: {
                    dialogid = DIALOG_CONFIG_WORLD_NAME; style = DIALOG_STYLE_INPUT; caption = "Configuración del mundo - Nombre";
                    info = "El nombre del mundo debe ir de 1 caracter a 24 caracteres"; button1 = "Cambiar"; button2 = "Atrás";
                }
                case 1: {
                    dialogid = DIALOG_CONFIG_WORLD_PASSWORD; style = DIALOG_STYLE_INPUT; caption = "Configuración del mundo - Contraseña";
                    info = "La contraseña del mundo debe ir de 1 caracter a 18 caracteres"; button1 = "Cambiar"; button2 = "Atrás";
                }
                case 2: {
                    new worldId = PlayerInfo[playerid][pWorld];
                    if(WorldInfo[worldId][wPrivacy] >= WORLD_PRIVACY_ADMIN_ONLY) {
                        WorldInfo[worldId][wPrivacy] = WORLD_PRIVACY_PRIVATE;
                        ShowConfigWorld(playerid);
                    } else {
                        WorldInfo[worldId][wPrivacy]++;
                        ShowConfigWorld(playerid);
                    }
                    return true;
                }
                case 3: {
                    dialogid = DIALOG_CONFIG_WORLD_TEAM_ONE; style = DIALOG_STYLE_INPUT; caption = "Configuración del mundo - Equipo uno";
                    info = "El nombre del equipo debe ir de 1 caracter a 24 caracteres"; button1 = "Cambiar"; button2 = "Atrás";
                }
                case 4: {
                    dialogid = DIALOG_CONFIG_WORLD_TEAM_TWO; style = DIALOG_STYLE_INPUT; caption = "Configuración del mundo - Equipo dos";
                    info = "El nombre del equipo debe ir de 1 caracter a 24 caracteres"; button1 = "Cambiar"; button2 = "Atrás";
                }
                case 5: {
                    dialogid = DIALOG_CONFIG_WORLD_MAX_ROUNDS; style = DIALOG_STYLE_INPUT; caption = "Configuración del mundo - Rondas máximas";
                    info = "Las rondas máximas deben ser mayor a 0"; button1 = "Cambiar"; button2 = "Atrás";
                }
                case 6: {
                    dialogid = DIALOG_CONFIG_WORLD_MAX_POINTS; style = DIALOG_STYLE_INPUT; caption = "Configuración del mundo - Puntos máximos";
                    info = "Los puntos máximos deben ser mayor a 0"; button1 = "Cambiar"; button2 = "Atrás";
                }
                case 7: return ShowConfigWorldWeapons(playerid);
                case 8: return ShowConfigWorldMaps(playerid);
            }
            if(listitem == 0 || listitem == 1 || listitem == 3 || listitem == 4 || listitem == 5 || listitem == 6) return ShowPlayerDialog(playerid, dialogid, style, caption, info, button1, button2);
            else return true;
        }
        case DIALOG_CONFIG_WORLD_NAME: {
            if(!response) return ShowConfigWorld(playerid);
            if(strlen(inputtext) == 0 || strlen(inputtext) < 1 || strlen(inputtext) > 24) {
                SendClientMessage(playerid, -1, "La longitud del texto es incorrecta.");
                return ShowConfigWorld(playerid);
            } else {
                new worldId = PlayerInfo[playerid][pWorld];
                SendClientMessage(playerid, -1, "Se ha cambiado el nombre del mundo.");
                format(WorldInfo[worldId][wName], 24, "%s", inputtext);
                SaveWorld(worldId);
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_PASSWORD: {
            if(!response) return ShowConfigWorld(playerid);
            if(strlen(inputtext) == 0 || strlen(inputtext) < 1 || strlen(inputtext) > 18) {
                SendClientMessage(playerid, -1, "La longitud del texto es incorrecta.");
                return ShowConfigWorld(playerid);
            } else {
                new worldId = PlayerInfo[playerid][pWorld];
                SendClientMessage(playerid, -1, "Se ha cambiado la contraseña del mundo.");
                format(WorldInfo[worldId][wPassword], 18, "%s", inputtext);
                SaveWorld(worldId);
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_TEAM_ONE: {
            if(!response) return ShowConfigWorld(playerid);
            if(strlen(inputtext) == 0 || strlen(inputtext) < 1 || strlen(inputtext) > 24) {
                SendClientMessage(playerid, -1, "La longitud del texto es incorrecta.");
                return ShowConfigWorld(playerid);
            } else {
                new worldId = PlayerInfo[playerid][pWorld];
                SendClientMessage(playerid, -1, "Se ha cambiado el nombre del equipo uno.");
                format(WorldInfo[worldId][wTeamOneName], 24, "%s", inputtext);
                SaveWorld(worldId);
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_TEAM_TWO: {
            if(!response) return ShowConfigWorld(playerid);
            if(strlen(inputtext) == 0 || strlen(inputtext) < 1 || strlen(inputtext) > 24) {
                SendClientMessage(playerid, -1, "La longitud del texto es incorrecta.");
                return ShowConfigWorld(playerid);
            } else {
                new worldId = PlayerInfo[playerid][pWorld];
                SendClientMessage(playerid, -1, "Se ha cambiado el nombre del equipo dos.");
                format(WorldInfo[worldId][wTeamTwoName], 24, "%s", inputtext);
                SaveWorld(worldId);
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_MAX_ROUNDS: {
            if(!response) return ShowConfigWorld(playerid);
            if(strval(inputtext) <= 0) {
                SendClientMessage(playerid, -1, "La longitud del texto es incorrecta.");
                return ShowConfigWorld(playerid);
            } else {
                new worldId = PlayerInfo[playerid][pWorld];
                SendClientMessage(playerid, -1, "Se han cambiado las rondas máximas.");
                WorldInfo[worldId][wMaxRounds] = strval(inputtext);
                SaveWorld(worldId);
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_MAX_POINTS: {
            if(!response) return ShowConfigWorld(playerid);
            if(strval(inputtext) <= 0) {
                SendClientMessage(playerid, -1, "La longitud del texto es incorrecta.");
                return ShowConfigWorld(playerid);
            } else {
                new worldId = PlayerInfo[playerid][pWorld];
                SendClientMessage(playerid, -1, "Se han cambiado los puntos máximos.");
                WorldInfo[worldId][wMaxPoints] = strval(inputtext);
                SaveWorld(worldId);
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_WEAPONS: {
            if(!response) return ShowConfigWorld(playerid);
            new worldId = PlayerInfo[playerid][pWorld];
            new weaponId = WorldInfo[worldId][wWeapons];
            if(strval(inputtext) == weaponId) {
                SendClientMessage(playerid, -1, "El mundo ya está usando este set de armas.");
                return ShowConfigWorld(playerid);
            } else {
                SendClientMessage(playerid, -1, "Se ha cambiado el set de armas del mundo.");
                WorldInfo[worldId][wWeapons] = strval(inputtext);
                weaponId = strval(inputtext);
                SaveWorld(worldId);
                for(new i = 0; i < MAX_PLAYERS; i++) {
                    if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == worldId) {
                        if(PlayerInfo[i][pTeam] == WORLD_TEAM_ONE || PlayerInfo[i][pTeam] == WORLD_TEAM_TWO) {
                            ResetPlayerWeapons(i);
                            GivePlayerWeapon(i, WeaponInfo[weaponId][wWeapon1], WeaponInfo[weaponId][wAmmo1]);
                            GivePlayerWeapon(i, WeaponInfo[weaponId][wWeapon2], WeaponInfo[weaponId][wAmmo2]);
                            GivePlayerWeapon(i, WeaponInfo[weaponId][wWeapon3], WeaponInfo[weaponId][wAmmo3]);
                        }
                    } 
                }
                return ShowConfigWorld(playerid);
            }
        }
        case DIALOG_CONFIG_WORLD_MAPS: {
            if(!response) return ShowConfigWorld(playerid);
            new worldId = PlayerInfo[playerid][pWorld];
            new mapId = WorldInfo[worldId][wMap];
            if(strval(inputtext) == mapId) {
                SendClientMessage(playerid, -1, "El mundo ya está usando este mapa.");
                return ShowConfigWorld(playerid);
            } else {
                SendClientMessage(playerid, -1, "Se ha cambiado el mapa del mundo.");
                WorldInfo[worldId][wMap] = strval(inputtext);
                SaveWorld(worldId);
                for(new i = 0; i < MAX_PLAYERS; i++) {
                    if(IsPlayerConnected(i) && PlayerInfo[i][pWorld] == worldId) {
                        SpawnPlayerEx(i);
                    } 
                }
                return ShowConfigWorld(playerid);
            }
        }
        default: return false;
    }
    return true;
}