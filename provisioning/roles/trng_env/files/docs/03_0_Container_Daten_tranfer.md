## 1. Vorbereitung und Start

1.  **Container starten:** Wir stellen sicher, dass der Container läuft.
    ```bash
    podman run -d --name nginx-training -p 8080:80 docker.io/library/nginx:latest
    ```
2.  **Webseite prüfen:** Öffnen Sie im Browser: `http://localhost:8080`. Es sollte die Standard-Nginx-Seite angezeigt werden.

-----

## 2. Standardseite kopieren (Container → Host)

Wir holen die aktuelle `index.html` aus dem Container auf das Host-System, um sie zu bearbeiten.

### Befehl

```bash
podman cp nginx-training:/usr/share/nginx/html/index.html ./
```

### Überprüfung

Prüfen Sie, ob die Datei auf Ihrem Host-System liegt:

```bash
ls index.html
# Inhalt der Datei prüfen:
cat index.html
```

-----

## 3. Datei bearbeiten (Host)

Wir bearbeiten die Datei auf dem Host, um zu zeigen, dass die Änderungen nach dem Zurückkopieren sichtbar sind.

### Befehl

Öffnen Sie die Datei in einem Editor oder verwenden Sie `echo`, um den Inhalt zu ersetzen:

```bash
# Ersetze den Inhalt durch eine einfache neue Zeile:
echo "<h1>Willkommen zur Podman Schulung!</h1>" > index.html
```

-----

## 4. Geänderte Seite zurückkopieren (Host → Container)

Jetzt überschreiben wir die Originaldatei im laufenden Container mit unserer geänderten Version.

### Befehl

```bash
podman cp index.html nginx-training:/usr/share/nginx/html/index.html
```

### Überprüfung 1: Im Container

Um sicherzustellen, dass die Datei im Container korrekt überschrieben wurde, prüfen wir den Inhalt direkt im Container:

```bash
podman exec nginx-training cat /usr/share/nginx/html/index.html
```

**Erwartete Ausgabe:** Es sollte `<h1>Willkommen zur Podman Schulung!</h1>` ausgegeben werden.

### Überprüfung 2: Im Browser

Laden Sie `http://localhost:8080` im Browser neu.

**Erwartetes Ergebnis:** Es sollte nun die neue Überschrift **"Willkommen zur Podman Schulung\!"** angezeigt werden, was bestätigt, dass Nginx die kopierte Datei verwendet.

-----

## 5. Isolation und Ephemerizität demonstrieren

### Szenario A: Isolation (Zweiter Container)

Starte einen **zweiten Container** vom *gleichen Image* auf einem anderen Host-Port.

```bash
podman run -d --name nginx-training-new -p 8081:80 docker.io/library/nginx:latest
```

**Überprüfung:**

1.  Öffnen Sie im Browser: `http://localhost:8081` (Port des neuen Containers).
2.  **Erwartetes Ergebnis:** Es wird die **ursprüngliche Nginx-Standardseite** angezeigt.
3.  **Erklärung:** Der neue Container wurde aus dem **Original-Image** gestartet und hat die ursprüngliche, unveränderte `index.html`. Die Änderungen im Container `nginx-training` waren **isoliert** von allen anderen Containern.

### Szenario B: Ephemerizität (Neustart nach Löschen)

1.  **Original-Container stoppen und löschen:**
    ```bash
    podman stop nginx-training
    podman rm nginx-training
    ```
2.  **Container erneut starten (vom Original-Image):**
    ```bash
    podman run -d --name nginx-training-neu -p 8080:80 docker.io/library/nginx:latest
    ```

**Überprüfung:**

1.  Öffnen Sie im Browser: `http://localhost:8080` (Port des neu gestarteten Containers).
2.  **Erwartetes Ergebnis:** Es wird wieder die **ursprüngliche Nginx-Standardseite** angezeigt.
3.  **Erklärung:** Da die Änderung direkt in das Dateisystem des Containers geschrieben wurde und **kein Volume** verwendet wurde, gingen alle Änderungen verloren, als der Container gelöscht wurde. Der Container war **ephemer (flüchtig)**.

-----

## 6. Aufräumen

Zum Abschluss der Schulungssitzung beenden Sie die Container und entfernen die erstellten Dateien.

```bash
# Beide Container stoppen und löschen
podman stop nginx-training nginx-training-neu
podman rm nginx-training nginx-training-neu
```
