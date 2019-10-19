# Energie monitoring - Publication de la téléinformation

Ce projet fait partie d'un projet global de suivi en temps réel de la consommation et de la production d'électricité de mon domicile.

Cette partie s'intéresse à la récupération des données d'un compteur Enedis (Linky ou autre compteur moderne) en utilisant la Télé-information client (TIC).
Ces données sont simplement formatées en JSON et envoyées sur un broker MQTT, leur exploitation est réalisée par l'autre partie du projet.

Ce code est destiné à touner sur un Raspberry Pi avec la carte d'extension PiTInfo. La récupération et la transmission de la téléinformation est réalisée avec Node-RED.

Tous les crédits vont à Charles Hallard (http://hallard.me), je n'ai fait que reprendre son travail pour l'adapter à mes besoins.

## Pré-requis

- La téléinformation activée sur le compteur
- Un Raspberry Pi avec le système d'exploitation Raspbian
- La carte d'extension PiTInfo
- Un broker MQTT (mosquitto par exemple)

## Installation

- Installer les dépendances nécessaires : git, docker et docker-compose
- Récupérer le projet avec Git : `git clone https://github.com/tms0/energy-monitoring-teleinfo.git`
- Modifier le fichier `.env-sample` pour renseigner les valeurs spécifiques à votre environnement et le renommer en `.env`

### Configuration du port série

Par défaut, le port série est désactivé. La procédure pour l'activer est disponible sur le blog de Charles Hallard : https://hallard.me/enable-serial-port-on-raspberry-pi/

## Lancement de l'application

Enfin, lancer l'application avec la commande suivante : `docker-compose up -d`

## Fonctionnement

Le programme est réalisé avec Node-RED, l'éditeur est accessible sur `http://<hostname>:1880`.

Le flow écoute les trames de la téléinformation sur le port série (`/dev/ttyAMA0`), elles sont ensuite validées et transformées en un objet JSON, sous la forme "étiquette" / valeur".

Enfin chaque message est publié sur un broker MQTT, dans le topic `teleinfo`.

Exemple de message avec la téléinformation "historique" du compteur Linky :
```
{ 
   "ADCO":"XXXXXXXXXXXX",
   "OPTARIF":"HC",
   "ISOUSC":"45",
   "HCHC":"000019212",
   "HCHP":"000068306",
   "PTEC":"HP",
   "IINST":"008",
   "IMAX":"090",
   "PAPP":"01940",
   "HHPHC":"A",
   "MOTDETAT":"000000"
}
```
