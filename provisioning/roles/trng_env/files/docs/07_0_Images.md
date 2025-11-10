# Container-Images: Grundlagen und Verwaltung

Images sind die unveränderlichen **Vorlagen** (Templates) oder **Baupläne**, aus denen Container erstellt werden. Ein Image enthält den gesamten Code, Laufzeitumgebungen, Bibliotheken und Konfigurationsdateien, die für eine Anwendung benötigt werden.

## A. Grundlagen der Image-Verwaltung

### 1\. Images auflisten

Der Befehl `podman images` zeigt alle lokal gespeicherten Images an.

```bash
podman images
```

| Spalte | Bedeutung |
| :--- | :--- |
| **REPOSITORY** | Der Speicherort des Images (z.B. `docker.io/library/nginx`). |
| **TAG** | Die Versionsbezeichnung (z.B. `latest` oder eine spezifische Versionsnummer). |
| **IMAGE ID** | Die eindeutige Kennung des Images. |
| **SIZE** | Die Größe des Images. |

### 2\. Image herunterladen (Pull)

Um ein Image aus einer öffentlichen Registry (standardmäßig Docker Hub) zu beziehen, nutzt man `podman pull`.

```bash
# Lädt das Image mit dem Tag 'latest' herunter
podman pull ubuntu
```

### 3\. Image aktualisieren

Da Images **unveränderlich** sind, wird ein Image nicht *aktualisiert*, sondern die neueste Version wird vom Server **neu heruntergeladen**.

```bash
# Zieht die neueste Version des ubuntu-Images. 
# Podman prüft automatisch, ob die lokale Version veraltet ist.
podman pull ubuntu
```

### 4\. Image löschen (Remove Image)

Wenn ein Image nicht mehr benötigt wird, kann es gelöscht werden, um Speicherplatz freizugeben. Ein Image kann nur gelöscht werden, wenn **keine laufenden oder beendeten Container** darauf basieren.

```bash
# Löscht ein Image anhand des Repository-Namens und Tags
podman rmi ubuntu:latest 
```

> **Tipp:** Wenn noch Container existieren, müssen diese zuerst mit `podman rm` gelöscht werden, oder Sie verwenden `podman rmi -f <image>` (Vorsicht, dies löscht auch Container-Verweise).

-----

## B. Eigenes Image erstellen: Das Dockerfile

Um ein eigenes, benutzerdefiniertes Image zu erstellen, verwenden wir ein **Dockerfile**. Dies ist eine Textdatei, die die Schritte zur Erstellung des Images definiert.

### Szenario: Einfaches statisches Webserver-Image

Wir erstellen ein Image, das eine einfache "Hallo Welt"-Seite bereitstellt.

### Schritt 1: Verzeichnis und Dateien erstellen

Erstellen Sie ein neues Verzeichnis und die notwendigen Dateien:

```bash
mkdir ~/my-custom-web
cd ~/my-custom-web

# Erstellt die Webseite
echo '<h1>Hallo von meinem eigenen Podman Image</h1>' > index.html
```

### Schritt 2: Dockerfile erstellen

Erstellen Sie im selben Verzeichnis eine Datei namens `Containerfile` (ohne Erweiterung) mit folgendem Inhalt:

```bash
cat > Containerfile << EOL
# Containerfile

# BASIS-IMAGE: Startet von einem schlanken, offiziellen Nginx-Image
FROM docker.io/library/nginx:latest

# KOPIEREN: Kopiert unsere lokale index.html in das Standard-Web-Verzeichnis des Containers
# Syntax: COPY <lokale_datei> <ziel_im_container>
COPY index.html /usr/share/nginx/html/index.html

# PORT: Dokumentiert, welcher Port die Anwendung bereitstellt (optional, aber empfohlen)
EXPOSE 80
EOL
```

### Schritt 3: Image bauen (Build)

Verwenden Sie den Befehl `podman build`, um das Image aus dem Dockerfile zu erstellen. Der Punkt (`.`) am Ende gibt an, dass sich das Dockerfile im aktuellen Verzeichnis befindet.

```bash
podman build -t my-web-image:v1.0 .
```

| Parameter | Erklärung |
| :--- | :--- |
| `podman build` | Der Befehl zum Starten des Build-Prozesses. |
| `-t my-web-image:v1.0` | **Tagging:** Weist dem neuen Image einen Namen und einen **Tag** (Version) zu. |
| `.` | Der **Build-Kontext** (das aktuelle Verzeichnis, in dem sich das Dockerfile und die `index.html` befinden). |

### Schritt 4: Das eigene Image testen

Starten Sie einen Container basierend auf Ihrem neu erstellten Image.

```bash
podman run -d --name my-test-server -p 8080:80 my-web-image:v1.0
```

**Überprüfung:** Öffnen Sie im Browser: `http://localhost:8080`. Es sollte die Ausgabe **"Hallo von meinem eigenen Podman Image\!"** erscheinen.

-----

## Aufräumen

```bash
# Container stoppen und löschen
podman stop my-test-server
podman rm my-test-server

# Eigenes Image löschen
podman rmi my-web-image:v1.0

# Zum vorherigen Verzeichnis wechseln und temporäre Dateien löschen
cd ~
rm -r ~/my-custom-web
```