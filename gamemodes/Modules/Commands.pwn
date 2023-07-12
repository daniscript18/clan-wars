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

flags:createworld(ADMIN_LEVEL_BOSS)
flags:deleteworld(ADMIN_LEVEL_BOSS)

alias:createworld("crearmundo")
alias:deleteworld("borrarmundo")
alias:worlds("mundos", "showworlds", "mostrarmundos")
alias:teams("equipos", "showteams", "mostrarequipos")