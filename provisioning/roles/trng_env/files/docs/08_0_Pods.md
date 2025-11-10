
# Training: Web-Services gemeinsam in einem Pod betreiben

In diesem Training lernst du, wie man zwei Container (Frontend + Backend) in einem **gemeinsamen Pod** startet. Ein Pod fasst mehrere Container so zusammen, dass sie sich ein Netzwerk, Ports und Ressourcen teilen. Dadurch können Dienste enger zusammenarbeiten – ähnlich wie Prozesse auf dem gleichen Server.

Dieses Konzept ist wichtig, um zu verstehen, wie Container in vielen modernen Systemen logisch gruppiert werden (z. B. Kubernetes Pods).


## **Lernziel**

Nach diesem Kapitel kannst du:

1. Einen Pod erstellen
2. Mehrere Container in denselben Pod starten
3. Eine Proxy-Konfiguration so anpassen, dass ein Frontend Anfragen an ein Backend im selben Pod weiterleitet
4. Verstehen, warum Container im Pod über `localhost` kommunizieren

---

## 1. Pod erstellen

```bash
podman pod create --name web-pod -p 8080:81
```

### **Was passiert hier?**

* Wir erstellen einen Pod mit dem Namen `web-pod`.
* Bei einem Pod teilen sich alle Container:

  * Netzwerkumgebung
  * localhost
  * Ports
* Wir veröffentlichen Port **8080** des Hosts → **81** im Pod.

Das bedeutet:
Rufe später [http://localhost:8080/](http://localhost:8080/) auf und du erreichst den Nginx im Pod.

**Pods anzeigen lassen:**
```bash
podman pod ps
```
---
## 2. Backend-Dienst in den Pod starten

```bash
podman run -d --name backend-app --pod web-pod docker.io/library/nginx:latest
```
* Wir starten einen Nginx-Webserver als Backend.
* Er läuft jetzt *innerhalb des Pods* → hat **keine eigene IP**.
* Statt über `http://backend-app:80/` (wie bei Compose) ist er erreichbar über:
  `http://127.0.0.1:80/` innerhalb des Pods.

### Inhalt für die Backend-Webseite anpassen:

```bash
podman exec backend-app sh -c 'echo "<h1>Hallo vom Backend im Pod!</h1>" > /usr/share/nginx/html/index.html'
```
Der Server liefert jetzt eine individuelle Seite aus, damit wir ihn gut erkennen.
---

## 3. Proxy-Konfiguration vorbereiten

Erstelle den Ordner (falls noch nicht vorhanden):

```bash
mkdir -p ~/frontend-pod
```

Erstelle die Konfigurationsdatei:

```bash
cat > ~/frontend-pod/proxy.conf << EOL
server {
    listen 81;

    # Route für Frontend-Standardseite
    location / {
        root   /usr/share/nginx/html;
        index  index.html;
    }

    # Route für Weiterleitung an Backend
    location /app/ {
        proxy_pass http://127.0.0.1:80/;
        proxy_set_header Host \$host;
    }
}
EOL
```
Lokale Frontend-Seite erstellen:
```bash
echo "<h1>Frontend-Proxy: Standard-Seite</h1><p>Zum Backend-Dienst: <a href=\"/app/\">Hier klicken</a></p>" > ~/frontend-pod/index.html
```

### **Wichtiges Verständnis:**

Da die Container im Pod *den gleichen Netzwerkraum* nutzen, ist der Backend-Dienst unter **localhost** erreichbar – **kein Containername mehr erforderlich**.

---

## 4. Frontend-Proxy im Pod starten

```bash
podman run -d --name frontend-proxy \
  --pod web-pod \
  -v ~/frontend-pod/proxy.conf:/etc/nginx/conf.d/default.conf:Z \
  -v ~/frontend-pod/index.html:/usr/share/nginx/html/index.html:Z \
  docker.io/library/nginx:latest
```

### Was passiert?

* Der Frontend-Nginx ersetzt seine Standardkonfiguration durch unsere Proxy-Regeln.
* Der Frontend-Nginx dient zwei Rollen:

  1. **Zeige eigene HTML-Seite**
  2. **Leite Anfragen an das Backend weiter** (`/app/ → localhost`)

---

## 5. Testen

| Was testen?         | URL                          | Erwartetes Ergebnis                       |
| ------------------- | ---------------------------- | ----------------------------------------- |
| Frontend            | `http://localhost:8080/`     | Die Frontend-Standardseite wird angezeigt |
| Proxy-Weiterleitung | `http://localhost:8080/app/` | Die Backend-Seite erscheint               |

---

## 6. Aufräumen

```bash
podman pod stop web-pod
podman pod rm web-pod
```

## Zusammenfassung
| Konzept                      | Bedeutung                                            |
| ---------------------------- | ---------------------------------------------------- |
| Pod                          | Gemeinsame Umgebung für mehrere Container            |
| Gemeinsame Netzwerk-Umgebung | Kommunikation über `localhost` statt Container-Namen |
| Proxy                        | Vermittelt Anfragen zwischen Frontend und Backend    |
