@echo off
setlocal

:: 1. Créer les dossiers nécessaires
set STEAMCMD_DIR=%~dp0steamcmd
set SCUM_SERVER_DIR=%~dp0scum_server

if not exist "%STEAMCMD_DIR%" mkdir "%STEAMCMD_DIR%"
if not exist "%SCUM_SERVER_DIR%" mkdir "%SCUM_SERVER_DIR%"

:: 2. Télécharger SteamCMD si absent
if not exist "%STEAMCMD_DIR%\steamcmd.exe" (
    echo Téléchargement de SteamCMD...
    powershell -Command "Invoke-WebRequest -Uri 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip' -OutFile '%STEAMCMD_DIR%\steamcmd.zip'"
    powershell -Command "Expand-Archive -Path '%STEAMCMD_DIR%\steamcmd.zip' -DestinationPath '%STEAMCMD_DIR%'"
    del "%STEAMCMD_DIR%\steamcmd.zip"
)

:: 3. Télécharger le serveur SCUM via SteamCMD
echo Téléchargement du serveur SCUM...
"%STEAMCMD_DIR%\steamcmd.exe" +login anonymous +force_install_dir "%SCUM_SERVER_DIR%" +app_update 1110390 validate +quit

:: 4. Créer un script de lancement
echo Création du script de lancement...
(
    echo @echo off
    echo cd /d "%SCUM_SERVER_DIR%"
    echo start SCUMServer.exe -log
) > "%~dp0start_scum_server.bat"

echo Installation terminée !
echo Utilise start_scum_server.bat pour lancer le serveur SCUM.
pause
