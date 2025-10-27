#!/bin/bash
# Hostkeys erzeugen
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Passwort setzen
echo "trainee:$PASSWORD" | chpasswd

# SSH-Server konfigurieren dynamisches Forwarding aktivieren
sed -i 's/#AllowTcpForwarding.*/AllowTcpForwarding yes/' /etc/ssh/sshd_config
sed -i 's/#PermitTunnel.*/PermitTunnel yes/' /etc/ssh/sshd_config
sed -i 's/#GatewayPorts.*/GatewayPorts yes/' /etc/ssh/sshd_config

# 3. SSH starten als Root
exec /usr/sbin/sshd -D