# Projekt für die Bereitstellung eine Container Schulung

Installation von Ansible
```
sudo apt install python3-venv
python3 -m venv .venv
source ./.venv/bin/activate
pip install -r requirements.txt
```

Starten des Container wirts inkl. provisionierung
```bash
vagrant up training-pottwhale
```