# Base de datos

Las migraciones las ejecuta el propio gamemode. No se necesita `mysql.exe`, `.bat`, `.sh` ni un migrador externo.

## Punto cero

`scriptfiles/migrations/0001_core.sql` es la unica migracion inicial despues del reinicio. Crea todo el esquema base y un mundo/mapa/loadout de desarrollo.

Una vez integrado este reinicio, `0001_core.sql` queda inmutable. Cada cambio posterior del esquema debe crear una nueva migracion ordenada (`0002_*`, `0003_*`, etc.) y registrarla en el migrador Pawn.

## Arranque

1. `mysql_connect_file()` lee `server/mysql.ini`.
2. El gamemode garantiza que exista `schema_migrations`.
3. Ejecuta las migraciones pendientes mediante `mysql_tquery_file`.
4. Registra una version solo despues de terminar su archivo sin errores MySQL.
5. Los mundos y los datos de runtime se cargan despues de completar migraciones.
6. Un error de migracion aborta el arranque para evitar ejecutar el servidor contra un esquema incompleto.

Usa `mysql.ini.example` como plantilla. `mysql.ini` nunca debe subirse al repositorio.
