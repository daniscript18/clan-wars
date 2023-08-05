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
    if(flags != 0 && PlayerInfo[playerid][pAdmin] < flags && !IsPlayerAdmin(playerid)) {
        SendClientMessage(playerid, -1, "Ese comando no existe.");
        return false;
    }
    return true;
}

flags:createworld(ADMIN_LEVEL_BOSS)
flags:deleteworld(ADMIN_LEVEL_BOSS)
flags:world(ADMIN_LEVEL_ADMINISTRADOR)
flags:setadmin(ADMIN_LEVEL_BOSS)
flags:setadmindb(ADMIN_LEVEL_BOSS)
flags:ban(ADMIN_LEVEL_ADMINISTRADOR)
flags:bandb(ADMIN_LEVEL_ADMINISTRADOR)
flags:unban(ADMIN_LEVEL_ADMINISTRADOR)
flags:kick(ADMIN_LEVEL_MODERATOR)
flags:mute(ADMIN_LEVEL_MODERATOR)
flags:mutedb(ADMIN_LEVEL_MODERATOR)
flags:unmute(ADMIN_LEVEL_MODERATOR)
flags:unmutedb(ADMIN_LEVEL_MODERATOR)

alias:createworld("crearmundo")
alias:deleteworld("borrarmundo")
alias:worlds("mundos", "showworlds", "mostrarmundos")
alias:teams("equipos", "showteams", "mostrarequipos")
alias:world("mundo", "worldconfig", "mundoconfiguracion", "mundoconfiguración")
alias:setadmin("daradmin")
alias:setadmindb("setadmindatabase", "daradmindb", "daradminbasededatos")
alias:ban("bloquear")
alias:bandb("bandatabase", "bloqueardb", "bloquearbasededatos")
alias:unban("desbloquear")
alias:kick("expulsar")
alias:mute("silenciar")
alias:mutedb("mutedatabase", "silenciardb", "silenciarbasededatos")
alias:unmute("desilenciar")
alias:unmutedb("unmutedatabase", "desilenciardb", "desilenciarbasededatos")