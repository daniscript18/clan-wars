public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    if(result == -1)
    {
        SendClientMessage(playerid, -1, "Ese comando no existe.");
        return false;
    }
    return true;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    if(flags != 0 && PlayerInfo[playerid][pAdmin] < flags) {
        SendClientMessage(playerid, -1, "Ese comando no existe.");
        return false;
    }
    return true;
}

flags:user(ADMIN_LEVEL_BOSS)
flags:world(ADMIN_LEVEL_BOSS)

alias:user("users", "usuario", "usuarios")
alias:world("worlds", "mundo", "mundos")