# Netzwerke

Wir nutzen einen Nginx-Container als **Frontend-Proxy**, um den Verkehr auf Basis des Pfades an einen **Backend-Container** weiterzuleiten.

## Schritt 1: Netzwerk erstellen

Um die Namensauflösung zu ermöglichen (damit der Frontend-Container den Backend-Container über seinen Namen erreichen kann), benötigen wir ein benutzerdefiniertes Netzwerk.

```bash
podman network create web-net
```

## Schritt 2: Backend-Dienst starten

Wir starten den zweiten Container, unseren **Backend-Dienst** (`backend-app`), und hängen ihn an das neue Netzwerk an. Wir nutzen `podman exec`, um eine einzigartige `index.html` zu erstellen.

1.  **Backend-Container starten:**
    ```bash
    podman run -d --name backend-app \
        --network web-net \
        docker.io/library/nginx:latest
    ```
2.  **Inhalt im Backend anpassen:**
    ```bash
    podman exec backend-app sh -c 'echo "<h1>Hallo vom Backend-Dienst! (Erreicht via Proxy)</h1>" > /usr/share/nginx/html/index.html'
    ```

## Schritt 3: Proxy-Konfiguration vorbereiten

Der **Frontend-Proxy** muss wissen, dass er alle Anfragen an `/app/` an den Backend-Dienst weiterleiten soll. Wir erstellen dafür eine Konfigurationsdatei auf dem Host.
1. **Frontend Ordner erstellen**
   ```bash
   mkdir ~/frontend
   ```

2.  **Lokale Konfigurationsdatei (`proxy.conf`) erstellen:**
    ```bash
    # Erstellt die Konfiguration direkt auf dem Host
    cat > ~/frontend/proxy.conf << EOL
    server {
        listen 80;

        # Standard-Route: Dient die lokale index.html des Proxys.
        location / {
            root   /usr/share/nginx/html;
            index  index.html;
        }

        # Proxy-Route: Leitet /app/ an den Backend-Container weiter.
        location /app/ {
            # WICHTIG: Podman löst den Container-Namen 'backend-app' in die IP auf.
            proxy_pass http://backend-app:80/;
            proxy_set_header Host \$host;
        }
    }
    EOL
    ```
3.  **Lokale Frontend-Seite erstellen:**
    ```bash
    echo "<h1>Frontend-Proxy: Standard-Seite</h1><p>Zum Backend-Dienst: <a href=\"/app/\">Hier klicken</a></p>" > ~/frontend/index.html
    ```

## Schritt 4: Frontend-Proxy starten

Wir starten den Haupt-Nginx-Container (`frontend-proxy`), binden ihn an Host-Port 8080 und mounten sowohl die benutzerdefinierte Nginx-Konfiguration als auch die Frontend-`index.html`.

```bash
podman run -d --name frontend-proxy \
    -p 8080:80 \
    --network web-net \
    -v ~/frontend/proxy.conf:/etc/nginx/conf.d/default.conf:Z \
    -v ~/frontend/index.html:/usr/share/nginx/html/index.html:Z \
    docker.io/library/nginx:latest
```

## Schritt 5: Demonstration

### Test 1: Lokaler Inhalt (Frontend)

Rufen Sie die Root-URL auf:

  * **URL:** `http://localhost:8080/`
  * **Erwartetes Ergebnis:** Die Seite zeigt **"Frontend-Proxy: Standard-Seite"** an.

### Test 2: Umgeleiteter Inhalt (Backend)

Rufen Sie den Pfad `/app/` auf (oder klicken Sie auf den Link in der Frontend-Seite):

  * **URL:** `http://localhost:8080/app/`
  * **Erwartetes Ergebnis:** Die Seite zeigt **"Hallo vom Backend-Dienst\! (Erreicht via Proxy)"** an.

**Zusammenfassung:** Die Anfrage ging an den `frontend-proxy`, der sie basierend auf der URL (`/app/`) über das **`web-net` Netzwerk** an den isolierten Container `backend-app` weitergeleitet hat. Die Kommunikation zwischen den Containern erfolgt über das Podman-Netzwerk, ohne dass der Backend-Port auf dem Host freigegeben werden musste.

-----

## 6. Aufräumen

```bash
# Container stoppen und löschen
podman stop frontend-proxy backend-app
podman rm frontend-proxy backend-app

# Netzwerk löschen
podman network rm web-net

# Lokale Dateien löschen
rm proxy.conf frontend-index.html
```