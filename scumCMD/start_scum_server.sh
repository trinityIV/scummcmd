#!/bin/bash
# Ce script lance le serveur SCUM et le redémarre automatiquement en cas d'arrêt.
# Pour ajouter un admin, éditez le fichier Admins.txt dans le dossier du serveur :
#   echo STEAM_ID > ./Admins.txt
# Remplacez STEAM_ID par l'identifiant Steam de l'admin.

cd "$(dirname "$0")/scum_server"

while true; do
    ./SCUMServer.sh -log
    echo "Le serveur s'est arrêté. Redémarrage dans 5 secondes..."
    sleep 5
done
