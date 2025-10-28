# Datenpersistenz: Volumes und Mounts

## A. Named Volumes (Verwaltete Volumes)

**Named Volumes** sind der bevorzugte Weg, um persistente Daten für Container zu speichern. Podman erstellt und verwaltet diese Datenbereiche automatisch auf dem Host-Dateisystem, aber der genaue Speicherort ist für den Benutzer meist irrelevant.

### Schritt 1: Volume erstellen

Zuerst erstellen wir ein Volume, bevor wir den Container starten.

```bash
# Erstellt ein Volume mit dem Namen "nginx-data"
podman volume create nginx-data
```

### Schritt 2: Volume beim Start verwenden

Wir starten den Nginx-Container und **mounten** das erstellte Volume in das Datenverzeichnis des Webservers (`/usr/share/nginx/html`).

```bash
podman run -d --name nginx-training \
    -p 8080:80 \
    -v nginx-data:/usr/share/nginx/html \
    docker.io/library/nginx:latest
```

| Parameter | Erklärung |
| :--- | :--- |
| `-v nginx-data:/usr/share/nginx/html` | **Volume Mount:** Verknüpft das **Named Volume** `nginx-data` mit dem Pfad `/usr/share/nginx/html` **im Container**. |

### Schritt 3: Daten auf das Volume kopieren und testen

Wir kopieren unsere geänderte `index.html` auf das **Volume** *im laufenden Container*.

1.  **Geänderte Datei zurückkopieren (Host → Volume im Container):**
    *(Voraussetzung: Die Datei `index.html` aus der vorherigen Übung existiert noch auf dem Host.)*
    ```bash
    podman cp index.html nginx-volume:/usr/share/nginx/html/index.html
    ```
2.  **Webseite prüfen:** Öffnen Sie im Browser: `http://localhost:8080`.
      * **Ergebnis:** Es sollte die Überschrift **"Willkommen zur Podman Schulung\!"** angezeigt werden.

### Schritt 4: Persistenz demonstrieren (Löschen & Neustart)

1.  **Container stoppen und löschen:**
    ```bash
    podman stop nginx-training
    podman rm nginx-training
    ```
    *(Das Volume `nginx-data` bleibt erhalten\!)*
2.  **Neuen Container starten, der das GLEICHE Volume verwendet:**
    ```bash
    podman run -d --name nginx-training-neu \
        -p 8081:80 \
        -v nginx-data:/usr/share/nginx/html \
        docker.io/library/nginx:latest
    ```
3.  **Webseite prüfen:** Öffnen Sie im Browser: `http://localhost:8081`.
      * **Ergebnis:** Es wird **wieder** die Überschrift **"Willkommen zur Podman Schulung\!"** angezeigt.
      * **Erklärung:** Der neue Container hat das existierende Volume mit der gespeicherten `index.html` verwendet. **Daten sind persistent.**

### Schritt 5: Volumes anzeigen und löschen

```bash
# Zeigt alle Named Volumes an
podman volume ls

# Löscht das Volume und damit die dauerhaft gespeicherten Daten!
podman volume rm nginx-data
```

-----

## B. Bind Mounts (Host-Verzeichnisse)

**Bind Mounts** verknüpfen ein **spezifisches Verzeichnis** auf dem Host-Dateisystem direkt mit einem Pfad im Container. Dies ist nützlich für die Entwicklung oder wenn man den genauen Speicherort der Daten kontrollieren möchte.

### Schritt 1: Lokales Verzeichnis erstellen

Erstelle auf deinem Host ein Verzeichnis mit der geänderten `index.html`.

```bash
# Erstellt ein lokales Verzeichnis
mkdir host-website
mv index.html host-website/
```

### Schritt 2: Bind Mount beim Start verwenden

Wir starten den Nginx-Container und **mounten** das lokale Verzeichnis in das Datenverzeichnis des Webservers.

```bash
podman run -d --name nginx-bind-mount \
    -p 8082:80 \
    -v $(pwd)/host-website:/usr/share/nginx/html:Z \
    docker.io/library/nginx:latest
```

| Parameter | Erklärung |
| :--- | :--- |
| `-v $(pwd)/host-website:/...` | **Bind Mount:** Verknüpft den **absoluten Pfad** auf dem Host (`$(pwd)` = aktuelles Verzeichnis) mit dem Container-Pfad. |
| `:Z` | **SELinux-Kontext:** Wird oft in Red Hat/Fedora/CentOS Umgebungen benötigt. Stellt sicher, dass Podman die Berechtigungen für das Mounting korrekt setzt (kann auf anderen Systemen weggelassen werden). |

### Schritt 3: Interne und externe Änderungen

1.  **Webseite prüfen:** Öffnen Sie im Browser: `http://localhost:8082`. Die geänderte Seite ist sichtbar.
2.  **Änderung auf dem Host vornehmen:** Ändere die Datei auf deinem Host.
    ```bash
    echo "<h1>Aktualisiert über Bind Mount!</h1>" > host-website/index.html
    ```
3.  **Browser prüfen:** Laden Sie `http://localhost:8082` neu.
      * **Ergebnis:** Die Änderung ist **sofort sichtbar**, da der Container direkt das Host-Verzeichnis liest.

-----

## 8. Aufräumen

```bash
# Container stoppen und löschen
podman stop nginx-bind-mount nginx-training-neu
podman rm nginx-bind-mount nginx-training-neu

# Lokales Verzeichnis löschen
rm -r host-website
```