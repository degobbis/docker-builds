🇬🇧 [English](README.md) | 🇩🇪 Deutsch

# docker-builds

## 1. Übersicht

Dieses Repository baut und veröffentlicht Docker-Images mit einem Makefile, Bash-Skripten und Dockerfiles. Der Build-Prozess wird über `.env` konfiguriert; diese Datei wird durch Kopieren von `.env-example` erstellt. Die Skripte in `templates/init`, `templates/build` und `templates/push` stellen die wiederverwendbare Initialisierungs-, Build- und Push-Logik bereit.

Am Anfang des Makefiles werden die Variablen global per `export` exportiert. Dadurch stehen die konfigurierten Werte den nachfolgenden Bash-Skripten zur Verfügung.

## 2. Lokale Nutzung

### Voraussetzungen

- Docker mit Buildx-Unterstützung
- GNU Make
- Bash >=4.0
- Ein Docker-Hub-Konto, wenn Images veröffentlicht werden sollen
- Ein Login bei der GitHub Container Registry (GHCR) für Multi-Platform-Zwischenimages

### Konfiguration

Die lokale Umgebungsdatei aus der Vorlage erstellen:

```bash
cp .env-example .env
```

Danach die Werte in `.env` nach Bedarf anpassen. Das Beispiel enthält unter anderem folgende Platzhalter:

| Variable | Zweck | Beispiel |
|---|---|---|
| `DOCKER_HUB_REPOSITORY` | Docker-Hub-Benutzername oder -Organisation; entspricht im Standard-Setup dem GitHub-Benutzernamen | `"degobbis"` |
| `DOCKER_HUB_REPOSITORY_LOCAL_PREFIX` | Registry-Präfix für Multi-Platform-Zwischenimages; anstelle einer lokalen Registry wird GHCR verwendet | `"ghcr.io"` |
| `<IMAGE>_VERSION` | Version eines einzelnen Images, zum Beispiel `PHP82_VERSION` | imagespezifischer Wert |

Historisch wurde die Zwischenregistry wegen des Limits für Multi-Architecture-Pushes im kostenlosen Docker-Hub-Tarif verwendet. Das konfigurierte Präfix ist inzwischen GHCR statt einer lokalen Registry.

### Image-Namen und Registries

Für ein Image namens `php82` werden die relevanten Namen wie folgt gebildet:

```make
IMAGE_BUILD_DOCKERHUB = "$DOCKER_HUB_REPOSITORY/php82"
# Ergebnis: degobbis/php82

IMAGE_BUILD = "$DOCKER_HUB_REPOSITORY_LOCAL_PREFIX/$DOCKER_HUB_REPOSITORY/$IMAGE_BUILD_NAME"
# Ergebnis: ghcr.io/degobbis/php82
```

`IMAGE_BUILD_DOCKERHUB` ist das endgültige Ziel auf Docker Hub. `IMAGE_BUILD` ist das GHCR-Ziel für den Multi-Platform-Build und den anschließenden Push von GHCR zu Docker Hub.

### Make-Befehle

Die verfügbaren Ziele anzeigen:

```bash
make help
```

Ein Image lokal oder über das Standardziel des Repositories bauen, zum Beispiel:

```bash
make build-php82
make build-mariadb118
```

Einen Multi-Platform-Build anfordern:

```bash
make build-php82 multi-platforms=1
```

Ein vorhandenes Multi-Platform-Image von GHCR zu Docker Hub pushen, ohne es neu zu bauen:

```bash
make build-php82 multi-platforms=1 only-push=1
```

Die konkreten Image-Ziele hängen von den Image-Definitionen im Repository ab.

### Docker-Login

Die lokalen Skripte führen **keinen** Docker-Login durch. Lokal wird der Docker-Login über den Credential Store beziehungsweise die Keychain eingerichtet, zum Beispiel:

```bash
docker login ghcr.io
docker login
```

Keine Registry-Passwörter in `.env` oder in den Build-Skripten hinterlegen. In GitHub Actions wird die Authentifizierung separat konfiguriert, wie unten beschrieben.

## 3. GitHub-Actions-Automatisierung

Die Workflows liegen in `.github/workflows/` und sind in einen Master-Workflow und wiederverwendbare Subflows aufgeteilt.

### Übersicht der Workflows

| Workflow | Aufgabe |
|---|---|
| `builds.yml` | Master-Workflow: wählt geänderte Images aus, erstellt die Matrix, ruft pro Image einen Build-Subflow auf und startet die Ergebnissammlung |
| `subflows/detect-changes.yml` | Wiederverwendbarer Change Detector; wird bei leerem `changedImages` aufgerufen und erkennt Änderungen an `.env-example` sowie an `_VERSION`-Variablen |
| `subflows/build-image.yml` | Wiederverwendbarer Build-Flow pro Image |
| `subflows/collect-results.yml` | Sammelt Ergebnisartefakte, erstellt oder aktualisiert das Sammel-Issue und schließt es nach einem erfolgreichen Lauf |

### Trigger und manuelle Ausführung

Der Master-Workflow läuft bei einem Push auf den Branch `2.0.0-dev`, wenn `.env-example` geändert wurde. Der Branch ist absichtlich hartcodiert, weil GitHub Actions Variablen oder Expressions in einem `on:`-Trigger nicht auswertet.

Der Workflow kann außerdem im Actions-Tab manuell mit folgenden Eingaben gestartet werden:

| Eingabe | Typ | Bedeutung | Standard |
|---|---|---|---|
| `changedImages` | String | Optional, durch Leerzeichen getrennte Image-Namen, zum Beispiel `php82 mariadb118`. Ein leerer Wert aktiviert die automatische Erkennung. | leer |
| `onlyPush` | Integer/String | `0` baut das Image nach GHCR; `1` überspringt den Neubau und pusht das vorhandene GHCR-Image zu Docker Hub. | `0` |

Wenn `changedImages` leer ist, vergleicht `subflows/detect-changes.yml` die aktuelle und die vorherige Version von `.env-example` und extrahiert geänderte Variablen, die auf `_VERSION` enden. Das Ergebnis wird in eine Matrix umgewandelt. `builds.yml` ruft anschließend für jedes Image den `subflows/build-image.yml` auf.

### Registry-Authentifizierung und Build-Modi

Der Image-Flow meldet sich bei GHCR mit `github.actor` und `secrets.GITHUB_TOKEN` an. Bei `onlyPush=1` erfolgt zusätzlich der Login bei Docker Hub mit `vars.DOCKER_HUB_REPOSITORY` und `secrets.DOCKER_HUB_TOKEN`.

- Bei `onlyPush=0` wird `make build-<IMAGE> multi-platforms=1` für einen Multi-Platform-Build ausgeführt und das Zwischenimage nach GHCR veröffentlicht, ohne zu Docker Hub zu pushen.
- Bei `onlyPush=1` wird `make build-<IMAGE> multi-platforms=1 only-push=1` für den Push vom vorhandenen GHCR-Image zu Docker Hub ausgeführt; es findet kein neuer Image-Build statt.

### Ergebnisse, Issues und Benachrichtigungen

Jeder Image-Flow schreibt `results/result-<IMAGE>.txt` mit `success` oder `failure` und lädt die Datei als Artefakt hoch. `subflows/collect-results.yml` lädt diese Artefakte herunter und erstellt eine Zusammenfassungstabelle.

Bei fehlgeschlagenen Läufen erstellt oder aktualisiert der Workflow ein GitHub-Issue, anstatt doppelte Issues zu öffnen. Das Label lautet bei `onlyPush=0` `Build Images` und bei `onlyPush=1` `Push to Docker Hub`. Wenn alle Jobs erfolgreich sind, wird das entsprechende offene Issue mit der erfolgreichen Zusammenfassung aktualisiert und automatisch geschlossen. Bei einem vollständig erfolgreichen Lauf wird ein neues Issue erstellt und gleich geschlossen.

Damit stellen wir sicher, dass immer eine Benachrichtigung an die E-Mail-Adresse des GitHub-Kontos des Benutzers gesendet wird. 

### Retry-Verhalten

Der Push-Befehl zu Docker Hub wird bei einem Fehler mit `nick-invision/retry@v3` wiederholt:

```yaml
timeout_minutes: 10
max_attempts: 3
retry_wait_seconds: 30
```

## 4. Anleitung für Forks

Bei einem Fork werden die Workflow-Dateien kopiert, Repository-Variablen und Secrets jedoch **nicht**. Für die Automatisierung im Fork müssen in den Repository-Einstellungen folgende Werte angelegt werden:

| Name | Typ | Erforderlicher Wert |
|---|---|---|
| `DOCKER_HUB_REPOSITORY` | Repository-Variable | Eigener Docker-Hub-Benutzername oder eigene Organisation |
| `DOCKER_HUB_REPOSITORY_LOCAL_PREFIX` | Repository-Variable | Registry-Präfix, normalerweise `ghcr.io` |
| `DOCKER_HUB_TOKEN` | Repository-Secret | Docker-Hub-Access-Token mit Berechtigung zum Pushen von Images |

Außerdem den `push`-Trigger in `.github/workflows/builds.yml` prüfen. Wenn der Fork einen anderen Default-Branch verwendet, `2.0.0-dev` auf den Namen dieses Branches ändern. Dieser Wert muss direkt angepasst werden, weil GitHub-Actions-`on:`-Trigger keine Variablen oder Expressions unterstützen.

## 5. Verzeichnisstruktur

```text
.
├── Makefile                         # Globale Variablen und Image-Build-Ziele
├── .env-example                     # Konfigurationsvorlage
├── templates/
│   ├── init                         # Gemeinsame Initialisierungslogik
│   ├── build                        # Gemeinsame Image-Build-Logik
│   └── push                         # Gemeinsame Push-Logik
└── .github/workflows/
    ├── builds.yml                   # Master-Workflow
    └── subflows/
        ├── detect-changes.yml       # Änderungserkennung
        ├── build-image.yml          # Wiederverwendbare Build-Flows pro Image
        └── collect-results.yml      # Ergebnis- und Issue-Verarbeitung
```
