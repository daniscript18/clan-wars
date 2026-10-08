enum E_MATCH_STATE
{
    MATCH_STATE_WAITING = 0,
    MATCH_STATE_CREATING,
    MATCH_STATE_COUNTDOWN,
    MATCH_STATE_LIVE,
    MATCH_STATE_ROUND_END,
    MATCH_STATE_FINISHED,
    MATCH_STATE_CANCELLED
};

enum E_MATCH_RUNTIME
{
    mDatabaseId,
    E_MATCH_STATE:mState,
    mSerial,
    mRoundNumber,
    mAlphaRounds,
    mBravoRounds,
    mAlphaPoints,
    mBravoPoints,
    mPendingParticipantWrites
};

new g_Match[MAX_RUNTIME_WORLDS][E_MATCH_RUNTIME];

Match_ResetAll()
{
    for(new worldSlot = 0; worldSlot < MAX_RUNTIME_WORLDS; worldSlot++)
    {
        Match_ResetRuntime(worldSlot);
    }
    return 1;
}

Match_ResetRuntime(worldSlot)
{
    g_Match[worldSlot][mDatabaseId] = 0;
    g_Match[worldSlot][mState] = MATCH_STATE_WAITING;
    g_Match[worldSlot][mSerial]++;
    g_Match[worldSlot][mRoundNumber] = 0;
    g_Match[worldSlot][mAlphaRounds] = 0;
    g_Match[worldSlot][mBravoRounds] = 0;
    g_Match[worldSlot][mAlphaPoints] = 0;
    g_Match[worldSlot][mBravoPoints] = 0;
    g_Match[worldSlot][mPendingParticipantWrites] = 0;
    return 1;
}

bool:Match_IsActiveState(E_MATCH_STATE:matchState)
{
    return matchState == MATCH_STATE_CREATING ||
        matchState == MATCH_STATE_COUNTDOWN ||
        matchState == MATCH_STATE_LIVE ||
        matchState == MATCH_STATE_ROUND_END;
}

bool:Match_IsWorldActive(worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return false;
    return Match_IsActiveState(g_Match[worldSlot][mState]);
}

bool:Match_IsPlayerParticipant(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return false;
    if(g_Match[worldSlot][mDatabaseId] <= 0) return false;
    return g_Player[playerid][pMatchDatabaseId] == g_Match[worldSlot][mDatabaseId];
}

bool:Match_CanSelectTeam(playerid, team)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return false;

    if(g_Match[worldSlot][mState] == MATCH_STATE_WAITING) return true;
    if(Match_IsPlayerParticipant(playerid)) return false;
    return team == WORLD_TEAM_SPECTATOR;
}

bool:Match_CanLeaveWorld(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return true;
    if(!Match_IsPlayerParticipant(playerid)) return true;
    return !Match_IsActiveState(g_Match[worldSlot][mState]);
}

Match_OnPlayerTeamChanged(playerid)
{
    g_Player[playerid][pReady] = false;
    g_Player[playerid][pMatchDatabaseId] = 0;
    g_Player[playerid][pMatchKills] = 0;
    g_Player[playerid][pMatchDeaths] = 0;
    return 1;
}

Match_OnPlayerLeaveWorld(playerid)
{
    g_Player[playerid][pReady] = false;
    g_Player[playerid][pMatchDatabaseId] = 0;
    g_Player[playerid][pMatchKills] = 0;
    g_Player[playerid][pMatchDeaths] = 0;
    return 1;
}

Match_GetTeamCounts(worldSlot, &alphaCount, &bravoCount, &alphaReady, &bravoReady)
{
    alphaCount = 0;
    bravoCount = 0;
    alphaReady = 0;
    bravoReady = 0;

    foreach(new playerid : Player)
    {
        if(!Player_IsAuthenticated(playerid)) continue;
        if(g_Player[playerid][pWorldSlot] != worldSlot) continue;

        if(g_Player[playerid][pTeam] == WORLD_TEAM_ALPHA)
        {
            alphaCount++;
            if(g_Player[playerid][pReady]) alphaReady++;
        }
        else if(g_Player[playerid][pTeam] == WORLD_TEAM_BRAVO)
        {
            bravoCount++;
            if(g_Player[playerid][pReady]) bravoReady++;
        }
    }
    return 1;
}

bool:Match_HasStartRequirements(worldSlot)
{
    new alphaCount, bravoCount, alphaReady, bravoReady;
    Match_GetTeamCounts(worldSlot, alphaCount, bravoCount, alphaReady, bravoReady);

    if(alphaCount < MATCH_MIN_TEAM_PLAYERS || bravoCount < MATCH_MIN_TEAM_PLAYERS) return false;
    return alphaCount == alphaReady && bravoCount == bravoReady;
}

Match_ToggleReady(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return SendError(playerid, "Debes entrar a un mundo primero.");
    if(g_Player[playerid][pTeam] == WORLD_TEAM_SPECTATOR) return SendError(playerid, "Selecciona un equipo antes de marcarte listo.");
    if(g_Match[worldSlot][mState] != MATCH_STATE_WAITING) return SendError(playerid, "La partida ya esta en preparacion o en curso.");

    g_Player[playerid][pReady] = !g_Player[playerid][pReady];

    new playerName[MAX_PLAYER_NAME + 1], message[160];
    GetPlayerNameSafe(playerid, playerName, sizeof(playerName));
    if(g_Player[playerid][pReady]) format(message, sizeof(message), "%s esta listo.", playerName);
    else format(message, sizeof(message), "%s ya no esta listo.", playerName);
    World_SendMessage(worldSlot, g_Player[playerid][pReady] ? 0x2ECC71FF : 0xF1C40FFF, message);

    Match_ShowReadySummary(worldSlot);
    if(g_Player[playerid][pReady] && Match_HasStartRequirements(worldSlot))
    {
        Match_RequestStart(worldSlot);
    }
    return 1;
}

Match_ShowReadySummary(worldSlot)
{
    new alphaCount, bravoCount, alphaReady, bravoReady, message[160];
    Match_GetTeamCounts(worldSlot, alphaCount, bravoCount, alphaReady, bravoReady);
    format(message, sizeof(message), "Listos: %s %d/%d | %s %d/%d",
        g_World[worldSlot][wTeamAlphaName], alphaReady, alphaCount,
        g_World[worldSlot][wTeamBravoName], bravoReady, bravoCount
    );
    World_SendMessage(worldSlot, 0xBFC9CAFF, message);
    return 1;
}

Match_RequestStart(worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return 0;
    if(g_Match[worldSlot][mState] != MATCH_STATE_WAITING) return 0;
    if(!Match_HasStartRequirements(worldSlot)) return 0;

    Match_ResetRuntime(worldSlot);
    g_Match[worldSlot][mState] = MATCH_STATE_CREATING;
    new serial = g_Match[worldSlot][mSerial];

    new mapSql[24], loadoutSql[24];
    if(g_World[worldSlot][wDefaultMapId] > 0) format(mapSql, sizeof(mapSql), "%d", g_World[worldSlot][wDefaultMapId]);
    else format(mapSql, sizeof(mapSql), "NULL");
    if(g_World[worldSlot][wDefaultLoadoutId] > 0) format(loadoutSql, sizeof(loadoutSql), "%d", g_World[worldSlot][wDefaultLoadoutId]);
    else format(loadoutSql, sizeof(loadoutSql), "NULL");

    new query[1024];
    mysql_format(g_Database, query, sizeof(query),
        "INSERT INTO `matches` (`world_id`,`map_id`,`loadout_id`,`status`,`team_alpha_name`,`team_bravo_name`,`rounds_to_win`,`points_to_win`) VALUES (%d,%s,%s,'countdown','%e','%e',%d,%d)",
        g_World[worldSlot][wDatabaseId],
        mapSql,
        loadoutSql,
        g_World[worldSlot][wTeamAlphaName],
        g_World[worldSlot][wTeamBravoName],
        g_World[worldSlot][wRoundsToWin],
        g_World[worldSlot][wPointsToWin]
    );
    mysql_tquery(g_Database, query, "Match_OnCreated", "dd", worldSlot, serial);
    World_SendMessage(worldSlot, 0xF1C40FFF, "Todos estan listos. Preparando la partida...");
    return 1;
}

forward Match_OnCreated(worldSlot, serial);
public Match_OnCreated(worldSlot, serial)
{
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(g_Match[worldSlot][mSerial] != serial || g_Match[worldSlot][mState] != MATCH_STATE_CREATING) return 1;

    new matchId = cache_insert_id();
    if(matchId <= 0)
    {
        Match_ResetRuntime(worldSlot);
        World_SendMessage(worldSlot, 0xE74C3CFF, "No se pudo crear la partida en la base de datos.");
        return 1;
    }

    g_Match[worldSlot][mDatabaseId] = matchId;

    if(!Match_HasStartRequirements(worldSlot))
    {
        Match_Cancel(worldSlot, "Los equipos cambiaron durante la preparacion.");
        return 1;
    }

    Match_SetWorldMatchStatus(worldSlot, true);
    if(!Match_PersistParticipants(worldSlot))
    {
        Match_Cancel(worldSlot, "No se encontraron participantes validos.");
    }
    return 1;
}

Match_PersistParticipants(worldSlot)
{
    new matchId = g_Match[worldSlot][mDatabaseId];
    if(matchId <= 0) return 0;

    g_Match[worldSlot][mPendingParticipantWrites] = 0;
    new serial = g_Match[worldSlot][mSerial];

    foreach(new playerid : Player)
    {
        if(!Player_IsAuthenticated(playerid)) continue;
        if(g_Player[playerid][pWorldSlot] != worldSlot) continue;
        if(g_Player[playerid][pTeam] != WORLD_TEAM_ALPHA && g_Player[playerid][pTeam] != WORLD_TEAM_BRAVO) continue;

        g_Player[playerid][pMatchDatabaseId] = matchId;
        g_Player[playerid][pMatchKills] = 0;
        g_Player[playerid][pMatchDeaths] = 0;
        g_Player[playerid][pReady] = true;
        g_Match[worldSlot][mPendingParticipantWrites]++;

        new query[384];
        mysql_format(g_Database, query, sizeof(query),
            "INSERT INTO `match_players` (`match_id`,`player_id`,`team`,`left_at`) VALUES (%d,%d,%d,NULL) ON DUPLICATE KEY UPDATE `team`=VALUES(`team`),`left_at`=NULL",
            matchId, g_Player[playerid][pDatabaseId], g_Player[playerid][pTeam]
        );
        mysql_tquery(g_Database, query, "Match_OnParticipantPersisted", "dd", worldSlot, serial);
    }

    return g_Match[worldSlot][mPendingParticipantWrites] > 0;
}

forward Match_OnParticipantPersisted(worldSlot, serial);
public Match_OnParticipantPersisted(worldSlot, serial)
{
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(g_Match[worldSlot][mSerial] != serial || g_Match[worldSlot][mState] != MATCH_STATE_CREATING) return 1;

    if(cache_affected_rows() <= 0)
    {
        Match_Cancel(worldSlot, "No se pudo persistir uno de los participantes.");
        return 1;
    }

    if(g_Match[worldSlot][mPendingParticipantWrites] > 0)
        g_Match[worldSlot][mPendingParticipantWrites]--;

    if(g_Match[worldSlot][mPendingParticipantWrites] > 0) return 1;

    if(!Match_HasStartRequirements(worldSlot))
    {
        Match_Cancel(worldSlot, "Los equipos cambiaron durante la preparacion.");
        return 1;
    }

    g_Match[worldSlot][mRoundNumber] = 1;
    Match_StartRoundCountdown(worldSlot);
    return 1;
}

Match_SetWorldMatchStatus(worldSlot, bool:active)
{
    if(!World_IsValidSlot(worldSlot)) return 0;

    g_World[worldSlot][wStatus] = active ? WORLD_STATUS_MATCH : WORLD_STATUS_IDLE;
    new query[192];
    mysql_format(g_Database, query, sizeof(query), "UPDATE `worlds` SET `status`=%d WHERE `id`=%d LIMIT 1", g_World[worldSlot][wStatus], g_World[worldSlot][wDatabaseId]);
    mysql_tquery(g_Database, query);
    return 1;
}

Match_StartRoundCountdown(worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return 0;
    if(g_Match[worldSlot][mDatabaseId] <= 0) return 0;

    g_Match[worldSlot][mState] = MATCH_STATE_COUNTDOWN;
    g_Match[worldSlot][mAlphaPoints] = 0;
    g_Match[worldSlot][mBravoPoints] = 0;

    Match_PreparePlayersForRound(worldSlot);

    new query[384];
    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `matches` SET `status`='countdown',`alpha_rounds`=%d,`bravo_rounds`=%d WHERE `id`=%d LIMIT 1",
        g_Match[worldSlot][mAlphaRounds], g_Match[worldSlot][mBravoRounds], g_Match[worldSlot][mDatabaseId]
    );
    mysql_tquery(g_Database, query);

    new serial = g_Match[worldSlot][mSerial];
    SetTimerEx("Match_CountdownTick", 250, false, "ddd", worldSlot, serial, MATCH_COUNTDOWN_SECONDS);
    return 1;
}

Match_PreparePlayersForRound(worldSlot)
{
    foreach(new playerid : Player)
    {
        if(!Player_IsAuthenticated(playerid)) continue;
        if(g_Player[playerid][pWorldSlot] != worldSlot) continue;
        if(!Match_IsPlayerParticipant(playerid)) continue;
        if(g_Player[playerid][pTeam] != WORLD_TEAM_ALPHA && g_Player[playerid][pTeam] != WORLD_TEAM_BRAVO) continue;

        TogglePlayerSpectating(playerid, false);
        World_SetSpawnInfo(playerid);
        SpawnPlayer(playerid);
        TogglePlayerControllable(playerid, false);
    }
    return 1;
}

forward Match_CountdownTick(worldSlot, serial, remaining);
public Match_CountdownTick(worldSlot, serial, remaining)
{
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(g_Match[worldSlot][mSerial] != serial || g_Match[worldSlot][mState] != MATCH_STATE_COUNTDOWN) return 1;

    if(remaining > 0)
    {
        new message[96];
        format(message, sizeof(message), "Ronda %d comienza en %d...", g_Match[worldSlot][mRoundNumber], remaining);
        World_SendMessage(worldSlot, 0xF1C40FFF, message);
        SetTimerEx("Match_CountdownTick", 1000, false, "ddd", worldSlot, serial, remaining - 1);
        return 1;
    }

    return Match_BeginRound(worldSlot);
}

Match_BeginRound(worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return 0;
    if(g_Match[worldSlot][mState] != MATCH_STATE_COUNTDOWN) return 0;

    g_Match[worldSlot][mState] = MATCH_STATE_LIVE;

    foreach(new playerid : Player)
    {
        if(!Match_IsPlayerParticipant(playerid)) continue;
        if(g_Player[playerid][pWorldSlot] != worldSlot) continue;
        TogglePlayerControllable(playerid, true);
    }

    new query[512];
    mysql_format(g_Database, query, sizeof(query),
        "INSERT INTO `match_rounds` (`match_id`,`round_number`,`started_at`) VALUES (%d,%d,UTC_TIMESTAMP()) ON DUPLICATE KEY UPDATE `started_at`=VALUES(`started_at`),`ended_at`=NULL,`winner_team`=NULL,`alpha_points`=0,`bravo_points`=0",
        g_Match[worldSlot][mDatabaseId], g_Match[worldSlot][mRoundNumber]
    );
    mysql_tquery(g_Database, query);

    if(g_Match[worldSlot][mRoundNumber] == 1)
    {
        mysql_format(g_Database, query, sizeof(query), "UPDATE `matches` SET `status`='live',`started_at`=COALESCE(`started_at`,UTC_TIMESTAMP()) WHERE `id`=%d LIMIT 1", g_Match[worldSlot][mDatabaseId]);
    }
    else
    {
        mysql_format(g_Database, query, sizeof(query), "UPDATE `matches` SET `status`='live' WHERE `id`=%d LIMIT 1", g_Match[worldSlot][mDatabaseId]);
    }
    mysql_tquery(g_Database, query);

    World_SendMessage(worldSlot, 0x2ECC71FF, "GO!");
    Match_BroadcastScore(worldSlot);
    return 1;
}

Match_OnPlayerDeath(playerid, killerid)
{
    if(!Player_IsAuthenticated(playerid)) return 0;
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return 0;
    if(g_Match[worldSlot][mState] != MATCH_STATE_LIVE) return 0;
    if(!Match_IsPlayerParticipant(playerid)) return 0;

    g_Player[playerid][pDeaths]++;
    g_Player[playerid][pMatchDeaths]++;
    Match_PersistDeath(playerid, g_Match[worldSlot][mDatabaseId]);

    new bool:validEnemyKill = false;
    if(killerid != INVALID_PLAYER_ID && killerid != playerid && IsPlayerConnected(killerid) && Player_IsAuthenticated(killerid))
    {
        if(g_Player[killerid][pWorldSlot] == worldSlot && Match_IsPlayerParticipant(killerid))
        {
            new killerTeam = g_Player[killerid][pTeam];
            new victimTeam = g_Player[playerid][pTeam];
            if((killerTeam == WORLD_TEAM_ALPHA || killerTeam == WORLD_TEAM_BRAVO) && killerTeam != victimTeam)
            {
                validEnemyKill = true;
                g_Player[killerid][pKills]++;
                g_Player[killerid][pMatchKills]++;
                Match_PersistKill(killerid, g_Match[worldSlot][mDatabaseId]);

                if(killerTeam == WORLD_TEAM_ALPHA) g_Match[worldSlot][mAlphaPoints]++;
                else g_Match[worldSlot][mBravoPoints]++;
            }
        }
    }

    if(validEnemyKill)
    {
        Match_BroadcastScore(worldSlot);
        if(g_Match[worldSlot][mAlphaPoints] >= g_World[worldSlot][wPointsToWin])
            return Match_EndRound(worldSlot, WORLD_TEAM_ALPHA);
        if(g_Match[worldSlot][mBravoPoints] >= g_World[worldSlot][wPointsToWin])
            return Match_EndRound(worldSlot, WORLD_TEAM_BRAVO);
    }

    SetTimerEx("Match_RespawnPlayer", MATCH_RESPAWN_DELAY_MS, false, "ddddd", playerid, Player_GetSession(playerid), worldSlot, g_Match[worldSlot][mSerial], g_Match[worldSlot][mRoundNumber]);
    return 1;
}

Match_PersistDeath(playerid, matchId)
{
    new query[512];
    mysql_format(g_Database, query, sizeof(query), "UPDATE `match_players` SET `deaths`=`deaths`+1 WHERE `match_id`=%d AND `player_id`=%d LIMIT 1", matchId, g_Player[playerid][pDatabaseId]);
    mysql_tquery(g_Database, query);
    mysql_format(g_Database, query, sizeof(query), "UPDATE `player_stats` SET `deaths`=`deaths`+1 WHERE `player_id`=%d LIMIT 1", g_Player[playerid][pDatabaseId]);
    mysql_tquery(g_Database, query);
    return 1;
}

Match_PersistKill(playerid, matchId)
{
    new query[512];
    mysql_format(g_Database, query, sizeof(query), "UPDATE `match_players` SET `kills`=`kills`+1 WHERE `match_id`=%d AND `player_id`=%d LIMIT 1", matchId, g_Player[playerid][pDatabaseId]);
    mysql_tquery(g_Database, query);
    mysql_format(g_Database, query, sizeof(query), "UPDATE `player_stats` SET `kills`=`kills`+1 WHERE `player_id`=%d LIMIT 1", g_Player[playerid][pDatabaseId]);
    mysql_tquery(g_Database, query);
    return 1;
}

forward Match_RespawnPlayer(playerid, sessionId, worldSlot, serial, roundNumber);
public Match_RespawnPlayer(playerid, sessionId, worldSlot, serial, roundNumber)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(g_Player[playerid][pWorldSlot] != worldSlot) return 1;
    if(g_Match[worldSlot][mSerial] != serial || g_Match[worldSlot][mRoundNumber] != roundNumber) return 1;
    if(g_Match[worldSlot][mState] != MATCH_STATE_LIVE) return 1;
    if(!Match_IsPlayerParticipant(playerid)) return 1;

    World_SetSpawnInfo(playerid);
    SpawnPlayer(playerid);
    return 1;
}

Match_EndRound(worldSlot, winnerTeam)
{
    if(!World_IsValidSlot(worldSlot)) return 0;
    if(g_Match[worldSlot][mState] != MATCH_STATE_LIVE) return 0;
    if(winnerTeam != WORLD_TEAM_ALPHA && winnerTeam != WORLD_TEAM_BRAVO) return 0;

    g_Match[worldSlot][mState] = MATCH_STATE_ROUND_END;
    if(winnerTeam == WORLD_TEAM_ALPHA) g_Match[worldSlot][mAlphaRounds]++;
    else g_Match[worldSlot][mBravoRounds]++;

    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pWorldSlot] == worldSlot && Match_IsPlayerParticipant(playerid))
            TogglePlayerControllable(playerid, false);
    }

    new query[1024];
    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `match_rounds` SET `alpha_points`=%d,`bravo_points`=%d,`winner_team`=%d,`ended_at`=UTC_TIMESTAMP() WHERE `match_id`=%d AND `round_number`=%d LIMIT 1",
        g_Match[worldSlot][mAlphaPoints], g_Match[worldSlot][mBravoPoints], winnerTeam,
        g_Match[worldSlot][mDatabaseId], g_Match[worldSlot][mRoundNumber]
    );
    mysql_tquery(g_Database, query);

    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `matches` SET `status`='round_end',`alpha_rounds`=%d,`bravo_rounds`=%d WHERE `id`=%d LIMIT 1",
        g_Match[worldSlot][mAlphaRounds], g_Match[worldSlot][mBravoRounds], g_Match[worldSlot][mDatabaseId]
    );
    mysql_tquery(g_Database, query);

    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `player_stats` ps INNER JOIN `match_players` mp ON mp.`player_id`=ps.`player_id` SET ps.`rounds_won`=ps.`rounds_won`+CASE WHEN mp.`team`=%d THEN 1 ELSE 0 END, ps.`rounds_lost`=ps.`rounds_lost`+CASE WHEN mp.`team`<>%d THEN 1 ELSE 0 END WHERE mp.`match_id`=%d",
        winnerTeam, winnerTeam, g_Match[worldSlot][mDatabaseId]
    );
    mysql_tquery(g_Database, query);

    new winnerName[WORLD_TEAM_NAME_LENGTH + 1], message[160];
    if(winnerTeam == WORLD_TEAM_ALPHA) format(winnerName, sizeof(winnerName), "%s", g_World[worldSlot][wTeamAlphaName]);
    else format(winnerName, sizeof(winnerName), "%s", g_World[worldSlot][wTeamBravoName]);
    format(message, sizeof(message), "%s gana la ronda %d.", winnerName, g_Match[worldSlot][mRoundNumber]);
    World_SendMessage(worldSlot, 0x2ECC71FF, message);
    Match_BroadcastScore(worldSlot);

    if(g_Match[worldSlot][mAlphaRounds] >= g_World[worldSlot][wRoundsToWin]) return Match_Finish(worldSlot, WORLD_TEAM_ALPHA);
    if(g_Match[worldSlot][mBravoRounds] >= g_World[worldSlot][wRoundsToWin]) return Match_Finish(worldSlot, WORLD_TEAM_BRAVO);

    SetTimerEx("Match_NextRound", MATCH_ROUND_END_SECONDS * 1000, false, "dd", worldSlot, g_Match[worldSlot][mSerial]);
    return 1;
}

forward Match_NextRound(worldSlot, serial);
public Match_NextRound(worldSlot, serial)
{
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(g_Match[worldSlot][mSerial] != serial || g_Match[worldSlot][mState] != MATCH_STATE_ROUND_END) return 1;

    g_Match[worldSlot][mRoundNumber]++;
    return Match_StartRoundCountdown(worldSlot);
}

Match_Finish(worldSlot, winnerTeam)
{
    if(!World_IsValidSlot(worldSlot)) return 0;
    if(!Match_IsActiveState(g_Match[worldSlot][mState])) return 0;

    g_Match[worldSlot][mState] = MATCH_STATE_FINISHED;

    new query[1024];
    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `matches` SET `status`='finished',`winner_team`=%d,`alpha_rounds`=%d,`bravo_rounds`=%d,`ended_at`=UTC_TIMESTAMP() WHERE `id`=%d LIMIT 1",
        winnerTeam, g_Match[worldSlot][mAlphaRounds], g_Match[worldSlot][mBravoRounds], g_Match[worldSlot][mDatabaseId]
    );
    mysql_tquery(g_Database, query);

    mysql_format(g_Database, query, sizeof(query), "UPDATE `match_players` SET `winner`=CASE WHEN `team`=%d THEN 1 ELSE 0 END WHERE `match_id`=%d", winnerTeam, g_Match[worldSlot][mDatabaseId]);
    mysql_tquery(g_Database, query);

    mysql_format(g_Database, query, sizeof(query),
        "UPDATE `player_stats` ps INNER JOIN `match_players` mp ON mp.`player_id`=ps.`player_id` SET ps.`matches_played`=ps.`matches_played`+1, ps.`wins`=ps.`wins`+CASE WHEN mp.`team`=%d THEN 1 ELSE 0 END, ps.`losses`=ps.`losses`+CASE WHEN mp.`team`<>%d THEN 1 ELSE 0 END WHERE mp.`match_id`=%d",
        winnerTeam, winnerTeam, g_Match[worldSlot][mDatabaseId]
    );
    mysql_tquery(g_Database, query);

    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pWorldSlot] != worldSlot || !Match_IsPlayerParticipant(playerid)) continue;
        if(g_Player[playerid][pTeam] == winnerTeam) g_Player[playerid][pWins]++;
        else if(g_Player[playerid][pTeam] == WORLD_TEAM_ALPHA || g_Player[playerid][pTeam] == WORLD_TEAM_BRAVO) g_Player[playerid][pLosses]++;
        g_Player[playerid][pReady] = false;
        TogglePlayerControllable(playerid, false);
    }

    Match_SetWorldMatchStatus(worldSlot, false);

    new winnerName[WORLD_TEAM_NAME_LENGTH + 1], message[192];
    if(winnerTeam == WORLD_TEAM_ALPHA) format(winnerName, sizeof(winnerName), "%s", g_World[worldSlot][wTeamAlphaName]);
    else format(winnerName, sizeof(winnerName), "%s", g_World[worldSlot][wTeamBravoName]);
    format(message, sizeof(message), "%s gana la partida %d-%d.", winnerName, g_Match[worldSlot][mAlphaRounds], g_Match[worldSlot][mBravoRounds]);
    World_SendMessage(worldSlot, 0x2ECC71FF, message);

    SetTimerEx("Match_ResetFinished", MATCH_FINISH_RESET_SECONDS * 1000, false, "dd", worldSlot, g_Match[worldSlot][mSerial]);
    return 1;
}

forward Match_ResetFinished(worldSlot, serial);
public Match_ResetFinished(worldSlot, serial)
{
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(g_Match[worldSlot][mSerial] != serial || g_Match[worldSlot][mState] != MATCH_STATE_FINISHED) return 1;

    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pWorldSlot] != worldSlot) continue;
        if(g_Player[playerid][pMatchDatabaseId] == g_Match[worldSlot][mDatabaseId])
        {
            g_Player[playerid][pMatchDatabaseId] = 0;
            g_Player[playerid][pMatchKills] = 0;
            g_Player[playerid][pMatchDeaths] = 0;
            g_Player[playerid][pReady] = false;
            TogglePlayerControllable(playerid, true);
            if(g_Player[playerid][pTeam] == WORLD_TEAM_ALPHA || g_Player[playerid][pTeam] == WORLD_TEAM_BRAVO)
            {
                World_SetSpawnInfo(playerid);
                SpawnPlayer(playerid);
            }
        }
    }

    Match_ResetRuntime(worldSlot);
    World_SendMessage(worldSlot, 0xBFC9CAFF, "El mundo esta listo para una nueva partida. Usa /ready.");
    return 1;
}

Match_Cancel(worldSlot, const reason[])
{
    if(!World_IsValidSlot(worldSlot)) return 0;

    new matchId = g_Match[worldSlot][mDatabaseId];
    g_Match[worldSlot][mState] = MATCH_STATE_CANCELLED;

    if(matchId > 0)
    {
        new query[512];
        mysql_format(g_Database, query, sizeof(query), "UPDATE `matches` SET `status`='cancelled',`ended_at`=UTC_TIMESTAMP() WHERE `id`=%d AND `status`<>'finished' LIMIT 1", matchId);
        mysql_tquery(g_Database, query);
    }

    Match_SetWorldMatchStatus(worldSlot, false);

    new message[256];
    format(message, sizeof(message), "Partida cancelada: %s", reason);
    World_SendMessage(worldSlot, 0xE67E22FF, message);

    foreach(new playerid : Player)
    {
        if(g_Player[playerid][pWorldSlot] != worldSlot) continue;

        g_Player[playerid][pMatchDatabaseId] = 0;
        g_Player[playerid][pMatchKills] = 0;
        g_Player[playerid][pMatchDeaths] = 0;
        g_Player[playerid][pReady] = false;
        TogglePlayerControllable(playerid, true);

        if(g_Player[playerid][pTeam] == WORLD_TEAM_ALPHA || g_Player[playerid][pTeam] == WORLD_TEAM_BRAVO)
        {
            World_SetSpawnInfo(playerid);
            SpawnPlayer(playerid);
        }
    }

    Match_ResetRuntime(worldSlot);
    return 1;
}

Match_BroadcastScore(worldSlot)
{
    if(!World_IsValidSlot(worldSlot)) return 0;

    new message[192];
    format(message, sizeof(message), "Marcador: %s %d (%d) - (%d) %d %s",
        g_World[worldSlot][wTeamAlphaName],
        g_Match[worldSlot][mAlphaRounds],
        g_Match[worldSlot][mAlphaPoints],
        g_Match[worldSlot][mBravoPoints],
        g_Match[worldSlot][mBravoRounds],
        g_World[worldSlot][wTeamBravoName]
    );
    World_SendMessage(worldSlot, 0xFFFFFFFF, message);
    return 1;
}

Match_ShowStatus(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return SendError(playerid, "Debes entrar a un mundo primero.");

    if(g_Match[worldSlot][mState] == MATCH_STATE_WAITING)
    {
        Match_ShowReadySummary(worldSlot);
        return 1;
    }

    Match_BroadcastScore(worldSlot);
    return 1;
}

Match_OnPlayerSpawn(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return 1;
    if(!Match_IsPlayerParticipant(playerid)) return 1;

    if(g_Match[worldSlot][mState] == MATCH_STATE_COUNTDOWN ||
        g_Match[worldSlot][mState] == MATCH_STATE_ROUND_END ||
        g_Match[worldSlot][mState] == MATCH_STATE_FINISHED)
    {
        TogglePlayerControllable(playerid, false);
    }
    else if(g_Match[worldSlot][mState] == MATCH_STATE_LIVE)
    {
        TogglePlayerControllable(playerid, true);
    }
    return 1;
}

Match_OnPlayerDisconnect(playerid)
{
    new worldSlot = g_Player[playerid][pWorldSlot];
    if(!World_IsValidSlot(worldSlot)) return 1;

    if(g_Match[worldSlot][mState] == MATCH_STATE_WAITING || g_Match[worldSlot][mState] == MATCH_STATE_CREATING)
        g_Player[playerid][pReady] = false;

    if(!Match_IsPlayerParticipant(playerid)) return 1;

    new query[384];
    mysql_format(g_Database, query, sizeof(query), "UPDATE `match_players` SET `left_at`=UTC_TIMESTAMP() WHERE `match_id`=%d AND `player_id`=%d LIMIT 1", g_Match[worldSlot][mDatabaseId], g_Player[playerid][pDatabaseId]);
    mysql_tquery(g_Database, query);
    return 1;
}

Match_TryRestorePlayer(playerid)
{
    new bool:hasActiveMatch = false;
    for(new worldSlot = 0; worldSlot < g_WorldCount; worldSlot++)
    {
        if(Match_IsWorldActive(worldSlot) && g_Match[worldSlot][mDatabaseId] > 0)
        {
            hasActiveMatch = true;
            break;
        }
    }

    if(!hasActiveMatch) return World_ShowList(playerid);

    new query[768];
    mysql_format(g_Database, query, sizeof(query),
        "SELECT mp.`match_id`,mp.`team`,mp.`kills`,mp.`deaths`,m.`world_id` FROM `match_players` mp INNER JOIN `matches` m ON m.`id`=mp.`match_id` WHERE mp.`player_id`=%d AND m.`status` IN ('countdown','live','round_end') ORDER BY mp.`match_id` DESC LIMIT 1",
        g_Player[playerid][pDatabaseId]
    );
    mysql_tquery(g_Database, query, "Match_OnRestoreLookup", "dd", playerid, Player_GetSession(playerid));
    return 1;
}

forward Match_OnRestoreLookup(playerid, sessionId);
public Match_OnRestoreLookup(playerid, sessionId)
{
    if(!Player_IsSessionValid(playerid, sessionId)) return 1;
    if(cache_num_rows() == 0) return World_ShowList(playerid);

    new matchId, team, kills, deaths, worldDatabaseId;
    cache_get_value_name_int(0, "match_id", matchId);
    cache_get_value_name_int(0, "team", team);
    cache_get_value_name_int(0, "kills", kills);
    cache_get_value_name_int(0, "deaths", deaths);
    cache_get_value_name_int(0, "world_id", worldDatabaseId);

    new worldSlot = World_FindByDatabaseId(worldDatabaseId);
    if(!World_IsValidSlot(worldSlot)) return World_ShowList(playerid);
    if(g_Match[worldSlot][mDatabaseId] != matchId || !Match_IsWorldActive(worldSlot)) return World_ShowList(playerid);
    if(team != WORLD_TEAM_ALPHA && team != WORLD_TEAM_BRAVO) return World_ShowList(playerid);

    g_Player[playerid][pWorldSlot] = worldSlot;
    g_Player[playerid][pTeam] = team;
    g_Player[playerid][pMatchDatabaseId] = matchId;
    g_Player[playerid][pMatchKills] = kills;
    g_Player[playerid][pMatchDeaths] = deaths;
    g_Player[playerid][pReady] = true;

    SetPlayerVirtualWorld(playerid, g_World[worldSlot][wVirtualWorld]);
    SetPlayerInterior(playerid, g_World[worldSlot][wInterior]);
    TogglePlayerSpectating(playerid, false);
    World_SetSpawnInfo(playerid);
    SpawnPlayer(playerid);

    new query[320];
    mysql_format(g_Database, query, sizeof(query), "UPDATE `match_players` SET `left_at`=NULL WHERE `match_id`=%d AND `player_id`=%d LIMIT 1", matchId, g_Player[playerid][pDatabaseId]);
    mysql_tquery(g_Database, query);

    SendSuccess(playerid, "Te reincorporaste a la partida que estaba en curso.");
    Match_BroadcastScore(worldSlot);
    return 1;
}

Match_RecoverInterrupted()
{
    Match_ResetAll();
    mysql_tquery(g_Database,
        "UPDATE `matches` SET `status`='cancelled',`ended_at`=COALESCE(`ended_at`,UTC_TIMESTAMP()) WHERE `status` IN ('countdown','live','round_end')",
        "Match_OnInterruptedRecovered"
    );
    return 1;
}

forward Match_OnInterruptedRecovered();
public Match_OnInterruptedRecovered()
{
    mysql_tquery(g_Database, "UPDATE `worlds` SET `status`=0 WHERE `status`=2", "Match_OnWorldStatusRecovered");
    return 1;
}

forward Match_OnWorldStatusRecovered();
public Match_OnWorldStatusRecovered()
{
    World_LoadAll();
    return 1;
}
