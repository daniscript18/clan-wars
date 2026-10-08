# Clan Wars Server

Pawn 3.10.10 SA-MP Clan Wars server with asynchronous MariaDB/MySQL persistence, bcrypt authentication, independent worlds and an explicit match state machine.

## Repository layout

```text
gamemodes/
  GM.pwn             Composition root
  Core/              Startup, DB, migrations, dialogs, utilities
  Players/           Runtime player state and authentication
  Worlds/            World/team/spawn/loadout domain
  Matches/           Ready/countdown/round/match lifecycle
  Admin/             Moderation/permissions
  Commands/          Command adapters
includes/             Pawn includes
plugins/              Runtime plugins
compiler/             Pawn 3.10.10 compilers
scriptfiles/migrations/ SQL migrations executed by the server
.github/workflows/    Compile CI
```

Local agent instructions live in `.ai/` and `AGENTS.md`; both are intentionally ignored by Git.

## Enabled dependencies

The runtime currently uses SA-MP MySQL, Pawn.CMD, sscanf, samp-bcrypt, crashdetect and YSI `y_iterate`. Other bundled integrations remain disabled until a concrete feature requires them.

## Database

Copy `mysql.ini.example` to `mysql.ini` and set local credentials. `mysql.ini` is ignored by Git. The gamemode owns schema migration execution at startup, so a local `mysql` CLI or migration `.bat/.sh` is not required.

The reset baseline is `scriptfiles/migrations/0001_core.sql`. Once released/applied, migrations are immutable; later schema work must add the next ordered migration.

## Compile

Windows (same command used by VS Code/CI):

```powershell
& .\compiler\pawncc.exe `
  "$PWD\gamemodes\GM.pwn" `
  "-D$PWD\gamemodes" `
  "-i$PWD\includes" `
  '-;+' `
  '-(+' `
  '-d3' `
  '-Z+'
```

Linux:

```sh
./compiler/pawncc "$PWD/gamemodes/GM.pwn" "-D$PWD/gamemodes" "-i$PWD/includes" '-;+' '-(+' -d3 '-Z+'
```

A change is not ready while project compiler errors/warnings remain.

## Documentation

The sibling `../wiki/` repository is the canonical human-facing documentation. Every server change must update `../wiki/Changelog.md` and any affected topical wiki pages in the same task.
