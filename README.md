# scumCMD

## Script de gestion tout-en-un pour serveur SCUM

Ce dépôt fournit un script Bash (`scum_manager.sh`) pour installer, mettre à jour, lancer, arrêter, redémarrer et administrer facilement un serveur SCUM sous Linux.

### Prérequis

- Linux (Debian/Ubuntu recommandé)
- Accès SSH et droits sudo
- [Steam Web API Key](https://steamcommunity.com/dev/apikey) (pour la récupération automatique de SteamID)
- (Optionnel) Go pour l'utilisation de RCON (installé automatiquement si besoin)

### Installation et gestion

1. **Télécharger le dépôt :**
   ```bash
   git clone <url-du-repo>
   cd scumCMD
   chmod +x scum_manager.sh
   ```

2. **Installer le serveur SCUM :**
   ```bash
   ./scum_manager.sh install
   ```

3. **Mettre à jour le serveur :**
   ```bash
   ./scum_manager.sh update
   ```

4. **Démarrer/Arrêter/Redémarrer le serveur :**
   ```bash
   ./scum_manager.sh start
   ./scum_manager.sh stop
   ./scum_manager.sh restart
   ```

### Gestion des admins

- **Ajouter un admin (SteamID ou lien de profil Steam) :**
  ```bash
  ./scum_manager.sh add-admin 76561198000000000
  ./scum_manager.sh add-admin https://steamcommunity.com/id/nomduprofil
  ```

- **Supprimer un admin :**
  ```bash
  ./scum_manager.sh remove-admin 76561198000000000
  ```

- **Lister les admins :**
  ```bash
  ./scum_manager.sh list-admins
  ```

- **Récupérer un SteamID à partir d'un lien de profil :**
  ```bash
  ./scum_manager.sh get-steamid https://steamcommunity.com/id/nomduprofil
  ```

### Commandes en jeu (RCON)

- **Envoyer une commande RCON :**
  ```bash
  ./scum_manager.sh rcon <motdepasse> "<commande>" [port]
  # Exemple :
  ./scum_manager.sh rcon monpass "ListPlayers"
  ```

### Nettoyage automatique lors des mises à jour

Le script supprime les anciens fichiers du serveur (hors sauvegardes et configuration) avant chaque mise à jour pour garantir une installation propre.

### Support

Pour toute question ou suggestion, ouvrez une issue sur GitHub.
