# Podman Container nutzen

## 1\. Container starten (Detached Mode)

Wir starten den Nginx-Container im Hintergrund (`-d`) und mappen den Port 80 des Containers auf den Port 8080 des Hosts.

```bash
podman run -d --name nginx-training -p 8080:80 docker.io/library/nginx:latest
```

| Parameter | Erklärung |
| :--- | :--- |
| `podman run` | Erstellt und startet einen Container. |
| `-d` | **Detached Mode:** Lässt den Container im Hintergrund laufen und gibt das Terminal frei. |
| `--name nginx-training` | Weist dem Container den eindeutigen Namen `nginx-training` zu. |
| `-p 8080:80` | **Port-Mapping:** Leitet den Host-Port **8080** auf den Container-Port **80** um. |
| `ubuntu/nginx` | Das zu verwendende **Image** (wird automatisch heruntergeladen, falls noch nicht vorhanden). |

## 2\. Container anzeigen

Überprüfe, ob der Container läuft und die Port-Zuordnung korrekt ist.

### Aktive Container anzeigen

```bash
podman ps
```

**Erwartete Ausgabe:** Du solltest den Container `nginx-training` mit dem Status `Up` und dem Port-Mapping `0.0.0.0:8080->80/tcp` sehen.

### Logs anzeigen

Überprüfe die Start-Logs des Nginx-Webservers.

```bash
podman logs nginx-training
```

**Tipp:** Du kannst `podman logs -f nginx-training` verwenden, um die Logs in Echtzeit zu verfolgen (mit `Ctrl+C` beenden).

-----

## 3\. Interaktion mit `podman exec`

Wir führen Befehle in dem laufenden Container aus.

### Einzelnen Befehl ausführen

Prüfe die Ubuntu-Version, auf der der Container basiert.

```bash
podman exec nginx-training cat /etc/os-release
```

**Ausgabe:** Zeigt Details zur im Container verwendeten Ubuntu-Version.

### Interaktive Shell öffnen (Debugging)

Starte eine `bash`-Sitzung, um den Container zu inspizieren (z.B. Dateien oder Konfiguration prüfen).

```bash
podman exec -it nginx-training /bin/bash
```

| Parameter | Erklärung |
| :--- | :--- |
| `-it` | **Interactive/TTY:** Notwendig, um eine interaktive Sitzung zu starten und die Eingabe/Ausgabe richtig zu verbinden. |
| `/bin/bash` | Der Befehl, der **innerhalb** des Containers ausgeführt wird (die Shell). |

> **Innerhalb der Shell:** Du bist jetzt im Container. Du kannst beispielsweise `/var/www/html` prüfen oder `exit` eingeben, um die Shell zu verlassen.

-----

## 4\. Container stoppen und neu starten

### Container stoppen

Sende ein **SIGTERM**-Signal zum geordneten Beenden.

```bash
podman stop nginx-training
```

### Status prüfen (Container gestoppt)

```bash
podman ps
podman ps -a
```

  * `podman ps` zeigt ihn nicht mehr an.
  * `podman ps -a` zeigt ihn mit dem Status **`Exited`** an.

### Container neu starten

```bash
podman restart nginx-training
```

### Status prüfen (Container wieder aktiv)

```bash
podman ps
```

Der Container sollte wieder mit dem Status **`Up`** angezeigt werden.

-----

## 5\. Container löschen

Container, die nicht mehr benötigt werden, sollten gelöscht werden, um Ressourcen freizugeben.

### Container löschen

Der Container muss **gestoppt** sein, um ihn zu löschen.

```bash
# 1. Sicherstellen, dass er gestoppt ist
podman stop nginx-training

# 2. Container entfernen
podman rm nginx-training
```

### Löschen erzwingen

Wenn der Container noch läuft, kannst du das Löschen erzwingen (`-f`). **Achtung:** Dies stoppt ihn abrupt und löscht ihn sofort.

```bash
podman rm -f nginx-training
```

### Status prüfen (Container entfernt)

```bash
podman ps -a
```

Der Container `nginx-training` sollte nun **nicht mehr** in der Liste erscheinen.
