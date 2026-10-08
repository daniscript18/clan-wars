public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
    #pragma unused cmd, params, flags
    if(!Player_IsAuthenticated(playerid))
    {
        SendError(playerid, "Debes iniciar sesion antes de usar comandos.");
        return 0;
    }
    return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
    #pragma unused params, flags
    if(result == -1)
    {
        new message[128];
        format(message, sizeof(message), "Comando desconocido: /%s. Usa /help.", cmd);
        SendError(playerid, message);
        return 0;
    }
    return 1;
}

cmd:help(playerid, params[])
{
    #pragma unused params
    ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_MSGBOX, "Ayuda",
        "/worlds - lista de mundos\n/world [id] - entrar por ID de base de datos\n/teams - seleccionar equipo\n/ready - listo/no listo\n/score - marcador actual\n/leave - salir del mundo\n/account - ver estadisticas\n\nPrefijos de chat: ! mundo, # equipo, @ administradores.",
        "Cerrar", ""
    );
    return 1;
}

cmd:account(playerid, params[])
{
    #pragma unused params
    return Player_ShowAccount(playerid);
}

cmd:worlds(playerid, params[])
{
    #pragma unused params
    return World_ShowList(playerid);
}

cmd:world(playerid, params[])
{
    new databaseId;
    if(sscanf(params, "i", databaseId)) return SendInfo(playerid, "Uso: /world [id]");

    new worldSlot = World_FindByDatabaseId(databaseId);
    if(!World_IsValidSlot(worldSlot)) return SendError(playerid, "No existe un mundo con ese ID.");
    return World_RequestJoin(playerid, worldSlot);
}

cmd:teams(playerid, params[])
{
    #pragma unused params
    return World_ShowTeams(playerid);
}

cmd:leave(playerid, params[])
{
    #pragma unused params
    return World_Leave(playerid);
}


cmd:ready(playerid, params[])
{
    #pragma unused params
    return Match_ToggleReady(playerid);
}

cmd:score(playerid, params[])
{
    #pragma unused params
    return Match_ShowStatus(playerid);
}
