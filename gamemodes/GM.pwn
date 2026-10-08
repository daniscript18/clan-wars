#include <a_samp>
#include <a_mysql>
#include <Pawn.CMD>
#include <sscanf2>
#include <samp_bcrypt>
#include <YSI_Data\y_iterate>

#include "Core/Constants.pwn"
#include "Core/Database.pwn"
#include "Core/Utils.pwn"
#include "Players/Players.pwn"

forward bool:Match_CanSelectTeam(playerid, team);
forward bool:Match_CanLeaveWorld(playerid);

#include "Worlds/Worlds.pwn"
#include "Matches/Matches.pwn"
#include "Core/Migrations.pwn"
#include "Players/Auth.pwn"
#include "Admin/Admin.pwn"
#include "Commands/PlayerCommands.pwn"
#include "Commands/AdminCommands.pwn"
#include "Core/Dialogs.pwn"
#include "Core/Server.pwn"

main() {}
