#!/bin/bash

# --- CONFIGURATION ---
STEAMCMD_DIR="$PWD/steamcmd"
SCUM_SERVER_DIR="$PWD/scum_server"
ADMINS_FILE="$SCUM_SERVER_DIR/Admins.txt"
SERVER_SCRIPT="$SCUM_SERVER_DIR/SCUMServer.sh"
APP_ID=1110390

# --- FONCTIONS UTILES ---

function get_steamid_from_profile() {
    local url="$1"
    # Si c'est déjà un steamID64
    if [[ "$url" =~ steamcommunity.com\/profiles\/([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    # Si c'est un vanity URL, utiliser steamid.uk pour résoudre sans API key
    if [[ "$url" =~ steamcommunity.com\/id\/([^/]+) ]]; then
        local vanity="${BASH_REMATCH[1]}"
        local steamid=$(curl -s "https://steamid.uk/profile/$vanity" | grep -oE 'SteamID64</td><td[^>]*>[0-9]+' | grep -oE '[0-9]{17}')
        if [[ -n "$steamid" ]]; then
            echo "$steamid"
            return 0
        else
            echo "Impossible de résoudre le SteamID (profil privé ou inexistant)."
            return 1
        fi
    fi
    echo "Lien Steam non reconnu."
    return 1
}

function install_server() {
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y lib32gcc-s1 wget unzip curl jq

    mkdir -p "$STEAMCMD_DIR" "$SCUM_SERVER_DIR"

    if [ ! -f "$STEAMCMD_DIR/steamcmd.sh" ]; then
        echo "Téléchargement de SteamCMD..."
        wget -O "$STEAMCMD_DIR/steamcmd_linux.tar.gz" "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
        tar -xzf "$STEAMCMD_DIR/steamcmd_linux.tar.gz" -C "$STEAMCMD_DIR"
        rm "$STEAMCMD_DIR/steamcmd_linux.tar.gz"
    fi

    update_server
}

function update_server() {
    echo "Suppression des anciens fichiers du serveur (hors sauvegardes et config)..."
    find "$SCUM_SERVER_DIR" -mindepth 1 ! -name "Saved" ! -name "Config" ! -name "ServerSettings.ini" ! -name "Admins.txt" -exec rm -rf {} +
    echo "Mise à jour du serveur SCUM..."
    "$STEAMCMD_DIR/steamcmd.sh" +login anonymous +force_install_dir "$SCUM_SERVER_DIR" +app_update $APP_ID validate +quit
}

function start_server() {
    cd "$SCUM_SERVER_DIR" || exit 1
    nohup ./SCUMServer.sh -log > scum.log 2>&1 &
    echo "Serveur SCUM lancé."
}

function stop_server() {
    pkill -f SCUMServer.sh && echo "Serveur arrêté." || echo "Aucun serveur en cours."
}

function restart_server() {
    stop_server
    sleep 2
    start_server
}

function add_admin() {
    local steamid="$1"
    if grep -q "$steamid" "$ADMINS_FILE" 2>/dev/null; then
        echo "Déjà admin."
    else
        echo "$steamid" >> "$ADMINS_FILE"
        echo "Ajouté : $steamid"
    fi
}

function remove_admin() {
    local steamid="$1"
    if [ -f "$ADMINS_FILE" ]; then
        grep -v "$steamid" "$ADMINS_FILE" > "$ADMINS_FILE.tmp" && mv "$ADMINS_FILE.tmp" "$ADMINS_FILE"
        echo "Supprimé : $steamid"
    else
        echo "Aucun fichier Admins.txt"
    fi
}

function list_admins() {
    if [ -f "$ADMINS_FILE" ]; then
        cat "$ADMINS_FILE"
    else
        echo "Aucun admin."
    fi
}

function send_rcon() {
    local rcon_pass="$1"
    local cmd="$2"
    local rcon_port="${3:-27015}"
    if ! command -v rcon &>/dev/null; then
        echo "Installation de rcon..."
        sudo apt install -y golang-go
        go install github.com/gorcon/rcon-cli/cmd/rcon@latest
        export PATH=$PATH:$(go env GOPATH)/bin
    fi
    rcon -a 127.0.0.1:$rcon_port -p "$rcon_pass" "$cmd"
}

function usage() {
    echo "Usage: $0 [install|update|start|stop|restart|add-admin|remove-admin|list-admins|get-steamid|rcon]"
    echo "  install                : Installe le serveur SCUM"
    echo "  update                 : Met à jour le serveur SCUM"
    echo "  start                  : Démarre le serveur"
    echo "  stop                   : Arrête le serveur"
    echo "  restart                : Redémarre le serveur"
    echo "  add-admin <steamid|url>: Ajoute un admin (SteamID ou URL profil)"
    echo "  remove-admin <steamid> : Supprime un admin"
    echo "  list-admins            : Liste les admins"
    echo "  get-steamid <url>      : Récupère le SteamID à partir d'un lien de profil"
    echo "  rcon <pass> <cmd> [port]: Envoie une commande RCON"
}

# --- MAIN ---
case "$1" in
    install) install_server ;;
    update) update_server ;;
    start) start_server ;;
    stop) stop_server ;;
    restart) restart_server ;;
    add-admin)
        if [[ "$2" =~ steamcommunity.com ]]; then
            steamid=$(get_steamid_from_profile "$2")
            [ -n "$steamid" ] && add_admin "$steamid"
        else
            add_admin "$2"
        fi
        ;;
    remove-admin) remove_admin "$2" ;;
    list-admins) list_admins ;;
    get-steamid) get_steamid_from_profile "$2" ;;
    rcon) send_rcon "$2" "$3" "$4" ;;
    *) usage ;;
esac
