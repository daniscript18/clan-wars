public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(!IsPlayerConnected(playerid)) return 0;

    switch(dialogid)
    {
        case DIALOG_LOGIN:
        {
            if(!response)
            {
                KickPlayerDelayed(playerid);
                return 1;
            }
            return Auth_HandleLogin(playerid, inputtext);
        }
        case DIALOG_REGISTER:
        {
            if(!response)
            {
                KickPlayerDelayed(playerid);
                return 1;
            }
            return Auth_HandleRegister(playerid, inputtext);
        }
        case DIALOG_WORLDS:
        {
            if(!response) return 1;
            return World_RequestJoin(playerid, listitem);
        }
        case DIALOG_WORLD_PASSWORD:
        {
            if(!response) return World_ShowList(playerid);
            return World_VerifyPassword(playerid, inputtext);
        }
        case DIALOG_TEAMS:
        {
            if(!response) return World_ShowList(playerid);
            return World_SelectTeam(playerid, listitem);
        }
    }
    return 0;
}
