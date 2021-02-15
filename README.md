# Récupération et publication de la téléinformation

Ce projet permet de récupérer en temps réel les données d'un compteur Enedis (Linky ou autre compteur moderne) en utilisant la Télé-information client (TIC) et de les publier vers un topic MQTT.

[MQTT](https://fr.wikipedia.org/wiki/MQTT) est un protocole de messagerie publish-subscribe largement utilisé dans l'Internet des objets. De nombreux logiciels permettent de consommer et d'exploiter les données issues de ce protocole.

La téléinformation est une sortie physique acessible librement sur les compteurs Enedis. Pour la décoder, il est possible de réaliser soi-même un circuit électronique ou d'acheter des modules prêts à l'emploi.

Ce projet se décompose en deux parties :
  - **Le matériel** permettant de lire les données de la téléinformation
  - **L'application** permettant de décoder et publier ces données

## Le matériel

Ma solution se base sur le [PiTInfo](https://hallard.me/pitinfov12/) de [Charles Hallard](http://hallard.me), c'est une carte d'extension qui se branche sur un Raspberry Pi et qui permet de récupérer les données de la téléinformation sur son port série. Le PiTInfo est [en vente sur Tindie](https://www.tindie.com/products/Hallard/pitinfo/).

Concernant le Raspberry, un [Raspberry Pi Zero](https://www.raspberrypi.org/products/raspberry-pi-zero/) suffit largement, mais n'importe quel autre modèle devrait fonctionner.

NB : Ce projet fonctionne exclusivement sur un Raspberry Pi, mais si vous vous sentez l'âme d'un aventurier et que vous préférez l'utilisation d'un ESP8266, Charles Hallard (encore lui) a intégré la téléinfo à l'excellent [firmware Tasmota](https://github.com/arendst/Tasmota/blob/development/lib/lib_div/LibTeleinfo/README.md).

## L'application

L'application consiste en une image Docker qui embarque un flow [Node-RED](https://nodered.org/). Le flow écoute les données sur le port série, vérifie les informations et les publie vers un topic MQTT.

### Pré-requis

- Le système d'exploitation [Raspberry Pi OS](https://www.raspberrypi.org/software/operating-systems/) installé sur votre Raspberry Pi.
- Un broker MQTT ([mosquitto](https://mosquitto.org/download/) par exemple) installé directement sur votre Raspberry Pi ou bien sur une autre machine du réseau.

### Configuration du port série

Par défaut, le port série est désactivé. La procédure pour l'activer est disponible sur le blog de Charles Hallard : https://hallard.me/enable-serial-port-on-raspberry-pi/

### Lancement avec docker-compose

- Tout d'abord, il faut installer docker ainsi que docker-compose :
  ```
  $ curl -sSL https://get.docker.com | sh
  $ sudo apt install docker-compose
  ```
- Récupérer le fichier [docker-compose.yml](https://raw.githubusercontent.com/tms0/teleinfo-publisher/main/docker-compose.yml)
- Modifier le fichier [.env-sample](https://raw.githubusercontent.com/tms0/teleinfo-publisher/main/.env-sample) pour renseigner les valeurs spécifiques à votre environnement et le renommer en `.env`
- Lancer l'application : `docker-compose up -d`

### Téléinformation "historique" ou "standard" ?

Si vous possédez un Linky, vous pouvez demander à votre fournisseur d'électricité d'activer la téléinformation en mode "historique" ou "standard".  
Le mode historique est celui en place sur les anciens compteurs, il permet de récupérer de quoi suivre sa consommation mais n'est pas aussi complet que le mode "standard".  
Le mode "standard" devient vraiment intéressant si vous produisez de l'électricité (panneaux photovoltaïques, etc) et que vous souhaitez suivre votre injection sur le réseau, ou bien que votre abonnement est plus compliqué que ce qui est prévu dans le mode "historique".

### Fonctionnement en détails de l'application

L'éditeur NodeRed est accessible depuis le navigateur sur `http://<hostname>:1880`.

Le flow écoute les trames de la téléinformation sur le port série (`/dev/ttyAMA0`), elles sont ensuite validées et transformées en un objet JSON, sous la forme "étiquette" / valeur".

Enfin chaque message est publié sur un broker MQTT, dans le topic `teleinfo`.

Exemple de message avec la téléinformation "historique" du compteur Linky :
```
{ 
   "timestamp": 1575315182914,
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

## Exploitation des données

Le protocole MQTT étant énormément utilisé dans l'Internet des objets, de nombreuses solutions sont possibles pour exploiter vos données :

- Utilisation d'[InfluxDB (et de toute la pile TICK)](https://www.influxdata.com/time-series-platform/) : c'est ma solution préférée, voir mon projet de [suivi en temps réel de la consommation et de la production d'électricité de mon domicile](https://github.com/tms0/energy-monitoring) pour la mettre en oeuvre.
- Solutions de domotique : [HomeAssistant](https://www.home-assistant.io/integrations/mqtt/), [OpenHAB](https://www.openhab.org/addons/bindings/mqtt/), [Domoticz](https://www.domoticz.com/wiki/MQTT), ...
- Et plus encore : [OpenEnergyMonitor](https://guide.openenergymonitor.org/technical/mqtt/), [MQTT Explorer](http://mqtt-explorer.com/), etc, etc...!

## Documentation télé-information client

- Sorties de télé-information client des appareils de comptage électroniques utilisés par Enedis : https://www.enedis.fr/sites/default/files/Enedis-NOI-CPT_02E.pdf
- Sorties de télé-information client des appareils de comptage Linky utilisés en généralisation par Enedis : https://www.enedis.fr/sites/default/files/Enedis-NOI-CPT_54E.pdf

## Crédits

Tous les crédits vont à Charles Hallard (http://hallard.me), je n'ai fait que reprendre son travail pour l'adapter à mes besoins.
