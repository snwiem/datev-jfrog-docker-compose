# DATEV Jfrog Docker

Dieses Projektverzeichnis beinhaltet eine rudimentäre Docker-Compose Konfiguration um Artifactory und XRay mit allen benötigen Subsystemen und Konfigurationen auf einem Docker-Host zu starten.

# Verwendung

## Umgebung konfigurieren

Alle Einstellungen müssen in der `.env` Datei erfolgen, da diese sowohl das `setup.sh` Skript als auch die `docker-compose.yml` Konfiguration bedient.

Auf jeden Fall sollte `.env/DOCKER_DATA` gesetzt werden. Unterhalb dieses Verzeichnisses werden alle Volume-Data der Container abgelegt.

Die Änderungen der Ports können zu Problemen führen da diese teilweise fix in den Containers gesetzt sind und von aussen nicht geändert werden können.

## Umgebung einrichten

Ausführen von

```
$ sudo ./setup.sh
```

Hiermit werden unterhalb von `DOCKER_DATA` alle notwendigen Verzeichnisse mit den entsprechendne Berechtigungen angelegt und initialisiert.

## Container starten

Durch 

```
$ docker-compose up -d
```

werden alle Container gestartet. Für den initialen Startup ist es häufig sinnvoll die Container-Logs zu begutachten

```
$ docker-compose up -d && docker-compose logs -f
```

## Applikationen einrichten

Nach einer kurzen Weile sollten Artifactory und XRay auf dem Host unter den in `.env` konfigurierten Ports erreichbar sein.

## Lizenzen

Zum Konfigurieren und Betreiben der JFrog-Anwendungen werden Lizenz-Schlüssel benötigt. Trial Lizenzen kann man sich unter http://jfrog.com für die jeweiligen Produkte beantragen.
