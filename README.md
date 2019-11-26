# Energie monitoring - Publication de la téléinformation

Ce projet fait partie d'un projet global de suivi en temps réel de la consommation et de la production d'électricité de mon domicile.

Cette partie s'intéresse à la récupération des données d'un compteur Enedis (Linky ou autre compteur moderne) en utilisant la Télé-information client (TIC).
Ces données sont simplement formatées en JSON et envoyées sur un [broker MQTT](https://fr.wikipedia.org/wiki/MQTT), leur exploitation est réalisée par l'autre partie du projet.

Ce code est destiné à touner sur un [Raspberry Pi](https://www.raspberrypi.org/) avec la carte d'extension [PiTInfo](https://hallard.me/pitinfov12-light/). La récupération et la transmission de la téléinformation est réalisée avec [Node-RED](https://nodered.org/).

Tous les crédits vont à Charles Hallard (http://hallard.me), je n'ai fait que reprendre son travail pour l'adapter à mes besoins.

NB : Actuellement, seul le mode "historique" est géré (compteurs non Linky ou Linky en mode historique), n'ayant pas de Linky en mode standard en ma possession (cela devrait arriver début 2020).

## Pré-requis

- La téléinformation activée sur le compteur
- Un [Raspberry Pi](https://www.raspberrypi.org) avec le système d'exploitation [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
- La carte d'extension [PiTInfo](https://www.tindie.com/products/Hallard/pitinfo/)
- Un broker MQTT ([mosquitto](https://mosquitto.org/download/) par exemple)

## Installation

- Installer les dépendances nécessaires :
  ```
  $ curl -sSL https://get.docker.com | sh
  $ sudo apt install git docker-compose
  ```
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

## Documentation télé-information client

- Sorties de télé-information client des appareils de comptage électroniques utilisés par Enedis : https://www.enedis.fr/sites/default/files/Enedis-NOI-CPT_02E.pdf
- Sorties de télé-information client des appareils de comptage Linky utilisés en généralisation par Enedis : https://www.enedis.fr/sites/default/files/Enedis-NOI-CPT_54E.pdf
