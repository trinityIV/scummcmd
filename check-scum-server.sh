#!/bin/bash

# Recherche d'un conteneur SCUM existant (nom contenant 'scum_server')
CONTAINER_NAME=$(docker ps --format '{{.Names}}' | grep -m1 'scum_server')

if [ -z "$CONTAINER_NAME" ]; then
    echo "Aucun conteneur SCUM trouvé."
    read -p "Voulez-vous créer un conteneur nommé 'scum_server' ? (o/n) : " REP
    if [[ "$REP" =~ ^[Oo]$ ]]; then
        read -p "Entrez le nom de l'image Docker à utiliser (ex: scum-server:latest) : " IMAGE_NAME
        if [ -z "$IMAGE_NAME" ]; then
            echo "Aucune image spécifiée. Opération annulée."
            exit 1
        fi
        docker run -d --name scum_server -p 7042:7042/udp "$IMAGE_NAME"
        if [ $? -ne 0 ]; then
            echo "Erreur lors de la création du conteneur."
            exit 1
        fi
        CONTAINER_NAME="scum_server"
        echo "Conteneur 'scum_server' créé et lancé."
    else
        echo "Opération annulée."
        exit 1
    fi
fi

# Option pour installer/mettre à jour le serveur avec steamcmd
read -p "Voulez-vous installer ou mettre à jour le serveur SCUM avec steamcmd ? (o/n) : " USE_STEAMCMD
if [[ "$USE_STEAMCMD" =~ ^[Oo]$ ]]; then
    read -p "Entrez le chemin d'installation du serveur (ex: /home/steam/scum_server) : " INSTALL_DIR
    if [ -z "$INSTALL_DIR" ]; then
        echo "Aucun chemin spécifié. Opération annulée."
        exit 1
    fi
    read -p "Entrez l'ID Steam du serveur SCUM (ex: 1110390) : " APP_ID
    if [ -z "$APP_ID" ]; then
        APP_ID=1110390
        echo "Utilisation de l'ID Steam par défaut : $APP_ID"
    fi
    read -p "Entrez le chemin vers steamcmd (ex: /usr/games/steamcmd) : " STEAMCMD_PATH
    if [ -z "$STEAMCMD_PATH" ]; then
        STEAMCMD_PATH="steamcmd"
    fi
    $STEAMCMD_PATH +login anonymous +force_install_dir "$INSTALL_DIR" +app_update $APP_ID validate +quit
    if [ $? -ne 0 ]; then
        echo "Erreur lors de l'installation/mise à jour avec steamcmd."
        exit 1
    fi
    echo "Serveur SCUM installé/mis à jour dans $INSTALL_DIR"
fi

# Vérifier que le conteneur tourne
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Le conteneur '$CONTAINER_NAME' n'est pas en cours d'exécution."
    exit 1
fi

# Récupérer le port mappé (exemple: 0.0.0.0:7042->7042/udp)
PORT_MAPPING=$(docker port $CONTAINER_NAME 7042/udp | head -n1)
if [ -z "$PORT_MAPPING" ]; then
    echo "Impossible de trouver le port exposé 7042/udp pour le conteneur."
    exit 1
fi

# Extraire l'IP et le port
IP=$(echo $PORT_MAPPING | cut -d: -f1)
PORT=$(echo $PORT_MAPPING | cut -d: -f2)

# Si IP est 0.0.0.0, prendre l'IP locale de la machine
if [ "$IP" == "0.0.0.0" ]; then
    IP=$(hostname -I | awk '{print $1}')
fi

echo "Serveur SCUM détecté !"
echo "Nom du conteneur : $CONTAINER_NAME"
echo "IP : $IP"
echo "Port : $PORT"
echo "Lien direct pour rejoindre : steam://connect/$IP:$PORT"

# Génération du fichier d'informations verbose
INFO_FILE="scum_server_info.txt"
{
    echo "===== INFOS SERVEUR SCUM ====="
    echo "Date : $(date)"
    echo "Nom du conteneur : $CONTAINER_NAME"
    echo "IP : $IP"
    echo "Port : $PORT"
    echo "Lien direct Steam : steam://connect/$IP:$PORT"
    echo "=============================="
} > "$INFO_FILE"
echo "Fichier d'informations généré : $INFO_FILE"
