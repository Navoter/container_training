# Podman Compose: Frontend + Backend als Stack

Im vorherigen Kapitel hast du das Setup komplett manuell erstellt:
Du hast ein Netzwerk angelegt, zwei Container gestartet und Volumes gemountet, um Konfigurationen und Inhalte bereitzustellen. Das hat gut funktioniert, jedoch war jeder Schritt einzeln auszuführen und bei Änderungen oder Neustarts mussten die Container erneut aufgebaut werden.

In diesem Kapitel lernst du, wie du dieselbe Umgebung mit **podman compose** automatisiert starten kannst.
Statt jeden Container einzeln zu erstellen, fassen wir die gesamte Struktur in einer einzigen YAML-Datei zusammen. Podman compose übernimmt dann:

* das Erstellen und Verwalten des internen Netzwerks
* das Starten und Stoppen aller Services auf einmal
* die Zuordnung von Mounts und Ports
* die automatische Verbindung der Container untereinander über ihre Service-Namen

Wir verwenden weiterhin den bestehenden Ordner aus dem vorherigen Kapitel:

```
~/frontend/
├── proxy.conf
└── index.html
```

Dieser muss **nicht verändert** werden.

---

## 1. Projektverzeichnis für Compose erstellen

```bash
mkdir ~/podman-compose-proxy-demo
cd ~/podman-compose-proxy-demo
```
Wir legen einen separaten Arbeitsbereich an, in dem nur die Backend-Daten und die Compose-Konfiguration liegen.
Der Frontend-Ordner bleibt an seinem bisherigen Ort und wird später eingebunden.

---

## 2. Backend-Inhalt vorbereiten

```bash
mkdir backend
echo '<h1>Hallo vom Backend-Dienst! (Via Proxy & Compose)</h1>' > backend/index.html
```
Wir erstellen einen eigenen Ordner `backend`, in dem die HTML-Seite liegt, die der Backend-Nginx ausliefern soll.
Durch das spätere Mounten ersetzt diese Datei die Standard-Startseite des Backend-Containers.

---

## 3. `compose.yml` erstellen

```bash
cat > compose.yml << EOL
services:
  backend:
    container_name: backend-app
    hostname: backend-app
    image: docker.io/library/nginx:latest
    volumes:
      - ./backend/index.html:/usr/share/nginx/html/index.html:Z
    networks:
      - web-net

  frontend:
    container_name: frontend-proxy
    hostname: frontend-proxy
    image: docker.io/library/nginx:latest
    ports:
      - "8080:80"
    volumes:
      - ~/frontend/proxy.conf:/etc/nginx/conf.d/default.conf:Z
      - ~/frontend/index.html:/usr/share/nginx/html/index.html:Z
    depends_on:
      - backend
    networks:
      - web-net

networks:
  web-net:
EOL
```

**Was passiert hier?**

| Service    | Aufgabe                                                     | Wichtige Punkte                                                   |
| ---------- | ----------------------------------------------------------- | ----------------------------------------------------------------- |
| `backend`  | Liefert die Backend-Webseite aus                            | Die lokale Datei ersetzt die Standard-`index.html` des Containers |
| `frontend` | Nginx-Proxy, der `/app/` an den Backend-Dienst weiterleitet | Weiterhin dieselbe `proxy.conf` wie im vorherigen Kapitel         |

* `depends_on: backend` stellt sicher: **Frontend startet erst, wenn Backend läuft**
* Podman Compose erstellt automatisch ein **gemeinsames Netzwerk**, daher funktioniert `proxy_pass http://backend:80/;` ohne weitere Konfiguration.

---

## 4. Stack starten
```bash
podman compose up -d
```

**Was passiert hier?**

* Beide Container werden gebaut bzw. gestartet
* Ein internes Netzwerk wird automatisch angelegt
* Frontend und Backend können sich über ihre Service-Namen erreichen
* Die Volumes werden beim Start eingebunden

---

## 5. Testen

| URL                          | Erwartetes Ergebnis      | Bedeutung                                                          |
| ---------------------------- | ------------------------ | ------------------------------------------------------------------ |
| `http://localhost:8080/`     | Frontend-Seite erscheint | Kommunikation: Browser → Frontend                                  |
| `http://localhost:8080/app/` | Backend-Seite erscheint  | Kommunikation: Browser → Frontend → Backend über internes Netzwerk |

**Wichtig:**
Der Backend-Port wird **nicht** nach außen freigegeben — er ist nur für das Frontend erreichbar.

---

## 6. Aufräumen

```bash
podman compose down
```
* Beide Container werden gestoppt und gelöscht
* Das von Compose erzeugte Netzwerk wird entfernt
* Deine Dateien (`~/frontend` und `~/podman-compose-proxy-demo`) bleiben bestehen

Wenn du möchtest, kannst du die Compose-Umgebung komplett entfernen:

```bash
rm -r ~/podman-compose-proxy-demo
```

---
