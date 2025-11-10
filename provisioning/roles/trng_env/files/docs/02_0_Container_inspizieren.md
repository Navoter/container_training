## Container inspizieren: `podman inspect`

Der Befehl `podman inspect` liefert **detaillierte Low-Level-Informationen** über den Container im JSON-Format. Dies ist essenziell für Debugging und fortgeschrittene Konfigurationsprüfungen.

Wir starten zuerst den Container für das Beispiel:

```bash
podman run -d --name nginx-training -p 8080:80 docker.io/library/nginx:latest
```

### Inspektion durchführen

Führe den Befehl aus:

```bash
podman inspect nginx-training
```

### Wichtige Informationen in der Ausgabe (Auszug)

Die Ausgabe ist eine lange JSON-Struktur, aber die folgenden Schlüsselbereiche sind besonders nützlich:

  * **`State`**: Zeigt den aktuellen Zustand des Containers (z. B. `Running`, `Pid`, `StartedAt`).
  * **`Config`**: Enthält die Konfiguration, die beim Start des Containers verwendet wurde (z. B. das Image, die Environment-Variablen).
  * **`HostConfig`**: Zeigt die Host-spezifischen Einstellungen, wie Port-Bindings (`PortBindings`), Neustart-Richtlinien und Volumes.
      * **Beispiel für Port-Binding-Check:**
        ```json
        "PortBindings": {
            "80/tcp": [
                {
                    "HostIp": "",
                    "HostPort": "8080"
                }
            ]
        },
        ```
  * **`NetworkSettings`**: Enthält alle Netzwerkinformationen, einschließlich der zugewiesenen IP-Adresse des Containers (`IPAddress`).

### Spezifische Informationen abrufen

Du kannst die Ausgabe filtern, um nur bestimmte Werte anzuzeigen. Hier holen wir uns die **IP-Adresse** des Containers:

```bash
podman inspect --format '{{.NetworkSettings.IPAddress}}' nginx-training
```

-----

## Container-Protokolle: `podman logs`

Der Befehl `podman logs` ruft die Standardausgabe (`STDOUT`) und Standardfehlerausgabe (`STDERR`) des im Container laufenden Hauptprozesses ab. Dies sind typischerweise die **Webserver-Zugriffs- und Fehlerprotokolle** (Access und Error Logs).

### Logs einmalig anzeigen

```bash
podman logs nginx-training
```

**Ergebnis:** Zeigt alle bisherigen Logs seit dem Start des Containers.

### Logs in Echtzeit verfolgen (Follow)

Der `-f` (follow) Parameter ist nützlich, um die Logs live zu verfolgen, während der Container läuft.

```bash
podman logs -f nginx-training
```

> **Aktion:** Führe diesen Befehl in einem Terminal aus und rufe dann in einem Browser `http://localhost:8080` auf. Du solltest sofort die entsprechende Zugriffszeile (Access Log) im Terminal sehen.

> **Beenden:** Drücke `Strg + C`, um das Verfolgen der Logs zu stoppen.

### Logs ab einem bestimmten Zeitpunkt anzeigen

Du kannst die Logs auch nach einer Zeitangabe filtern (z. B. nur die letzten 10 Minuten):

```bash
podman logs --since 10m nginx-training
```

## Aufräumen

```bash
# Container stoppen und löschen
podman stop nginx-training
podman rm nginx-training
```