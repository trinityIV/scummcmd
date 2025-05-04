#!/bin/bash

# 1. Installer les dépendances
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y lib32gcc-s1 wget unzip

# 2. Créer les dossiers nécessaires
STEAMCMD_DIR="$PWD/steamcmd"
SCUM_SERVER_DIR="$PWD/scum_server"

mkdir -p "$STEAMCMD_DIR"
mkdir -p "$SCUM_SERVER_DIR"

# 3. Télécharger et extraire SteamCMD si absent
if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
    echo "Téléchargement de SteamCMD..."
    wget -O "$STEAMCMD_DIR/steamcmd_linux.tar.gz" "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
    tar -xzf "$STEAMCMD_DIR/steamcmd_linux.tar.gz" -C "$STEAMCMD_DIR"
    rm "$STEAMCMD_DIR/steamcmd_linux.tar.gz"
fi

# 4. Installer le serveur SCUM via SteamCMD
echo "Téléchargement du serveur SCUM..."
"$STEAMCMD_DIR/steamcmd.sh" +login anonymous +force_install_dir "$SCUM_SERVER_DIR" +app_update 1110390 validate +quit

# 5. Créer un script de lancement
echo "Création du script de lancement..."
cat <<EOF > "$PWD/start_scum_server.sh"
#!/bin/bash
cd "$SCUM_SERVER_DIR"
./SCUMServer.sh -log
EOF
chmod +x "$PWD/start_scum_server.sh"

echo "Installation terminée !"
echo "Utilisez ./start_scum_server.sh pour lancer le serveur SCUM."
