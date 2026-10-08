#define SERVER_NAME                     "Clan Wars"
#define DEFAULT_PLAYER_SKIN             (124)
#define DEFAULT_PLAYER_COLOR            (0xFFFFFFFF)
#define TEAM_ALPHA_COLOR                (0x3498DBFF)
#define TEAM_BRAVO_COLOR                (0xE74C3CFF)
#define SPECTATOR_COLOR                 (0xBFC9CAFF)

#define PLAYER_PASSWORD_MIN             (8)
#define PLAYER_PASSWORD_MAX             (64)
#define LOGIN_MAX_FAILURES              (5)
#define LOGIN_LOCK_SECONDS              (30)
#define BCRYPT_WORK_FACTOR              (12)

#define MAX_RUNTIME_WORLDS              (64)
#define MAX_LOADOUT_SLOTS               (8)
#define INVALID_WORLD_SLOT              (-1)

#define MATCH_MIN_TEAM_PLAYERS          (1)
#define MATCH_COUNTDOWN_SECONDS         (5)
#define MATCH_ROUND_END_SECONDS         (4)
#define MATCH_FINISH_RESET_SECONDS      (6)
#define MATCH_RESPAWN_DELAY_MS          (1250)

#define WORLD_NAME_LENGTH               (32)
#define WORLD_TEAM_NAME_LENGTH          (24)
#define WORLD_PASSWORD_HASH_LENGTH      (BCRYPT_HASH_LENGTH)

#define ADMIN_LEVEL_NONE                (0)
#define ADMIN_LEVEL_MODERATOR           (1)
#define ADMIN_LEVEL_ADMIN               (2)
#define ADMIN_LEVEL_MANAGER             (3)
#define ADMIN_LEVEL_ROOT                (4)

#define DIALOG_LOGIN                    (1000)
#define DIALOG_REGISTER                 (1001)
#define DIALOG_ACCOUNT                  (1002)
#define DIALOG_WORLDS                   (1100)
#define DIALOG_WORLD_PASSWORD           (1101)
#define DIALOG_TEAMS                    (1102)
#define DIALOG_HELP                     (1200)

#define WORLD_PRIVACY_PRIVATE           (0)
#define WORLD_PRIVACY_PUBLIC            (1)
#define WORLD_PRIVACY_ADMIN_ONLY        (2)

#define WORLD_STATUS_IDLE               (0)
#define WORLD_STATUS_TRAINING           (1)
#define WORLD_STATUS_MATCH              (2)
#define WORLD_STATUS_DISABLED           (3)

#define WORLD_TEAM_SPECTATOR            (0)
#define WORLD_TEAM_ALPHA                (1)
#define WORLD_TEAM_BRAVO                (2)
