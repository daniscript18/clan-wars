stock SendError(playerid, const message[])
{
    return SendClientMessage(playerid, 0xE74C3CFF, message);
}

stock SendSuccess(playerid, const message[])
{
    return SendClientMessage(playerid, 0x2ECC71FF, message);
}

stock SendInfo(playerid, const message[])
{
    return SendClientMessage(playerid, 0xF1C40FFF, message);
}

stock GetPlayerNameSafe(playerid, dest[], size)
{
    dest[0] = EOS;
    if(!IsPlayerConnected(playerid)) return 0;
    GetPlayerName(playerid, dest, size);
    return 1;
}

forward Server_KickDelayed(playerid, sessionId);
public Server_KickDelayed(playerid, sessionId)
{
    if(!IsPlayerConnected(playerid)) return 1;
    if(Player_GetSession(playerid) != sessionId) return 1;
    Kick(playerid);
    return 1;
}

stock KickPlayerDelayed(playerid, delay = 350)
{
    SetTimerEx("Server_KickDelayed", delay, false, "dd", playerid, Player_GetSession(playerid));
    return 1;
}
