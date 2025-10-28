# Bereitstellen einer PinP Umgebung für Schulungen

## Vorbereiten der Ansible Umgebung
Installation von Ansible
```
sudo apt install python3-venv
python3 -m venv .venv
source ./.venv/bin/activate
pip install -r requirements.txt
```

## Test mit Vagrant
Starten des Container wirts inkl. provisionierung
(Hinweis: Vagrant und Hypervisor z.B. VirtualBox Installation muss manuell erfolgen)
```bash
vagrant up training-pottwhale
```

## SSH Konfiguration
Die Folgende SSH Konfiguration kann verwendet werden, um mit VSCode oder unter Linux an dem Training teilzunehmen.

SSH Config

```ini
Host trainee01
  HostName 45.142.176.60
  User trainee
  Port 2201
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee02
  HostName 45.142.176.60
  User trainee
  Port 2202
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee03
  HostName 45.142.176.60
  User trainee
  Port 2203
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee04
  HostName 45.142.176.60
  User trainee
  Port 2204
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee05
  HostName 45.142.176.60
  User trainee
  Port 2205
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee06
  HostName 45.142.176.60
  User trainee
  Port 2206
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee07
  HostName 45.142.176.60
  User trainee
  Port 2207
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee08
  HostName 45.142.176.60
  User trainee
  Port 2208
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee09
  HostName 45.142.176.60
  User trainee
  Port 2209
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
Host trainee10
  HostName 45.142.176.60
  User trainee
  Port 2210
  LocalForward 8080 127.0.0.1:8080
  LocalForward 8081 127.0.0.1:8081
  LocalForward 8082 127.0.0.1:8082
```