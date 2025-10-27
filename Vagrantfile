NETWORK_PREFIX = "192.168.56."
HOSTNAME_PREFIX = "training-"

Vagrant.configure("2") do |config|
  name = HOSTNAME_PREFIX + "pottwhale"

  config.vm.define name do |node|
    node.vm.box = "bento/ubuntu-24.04"
    node.vm.hostname = name
    node.vm.network "private_network", ip: NETWORK_PREFIX + "10"

    # zusätzliches bridged Interface: DHCP vom LAN
    node.vm.network "public_network",
      bridge: "wlp10s0"

    # fixiertes SSH-Forwarding: host 2222 -> guest 22
    node.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh", auto_correct: false
    # Stelle sicher, dass Vagrant diesen Host-Port zum SSH verwendet
    node.ssh.port = 2222

    node.vm.provider "virtualbox" do |vb|
      vb.memory = 4096
      vb.cpus   = 2
    end

    # Ansible vom Host aus ausführen (nutzt standardmäßig den vagrant-user)
    node.vm.provision "ansible" do |ansible|
      ansible.config_file = "provisioning/playbooks/ansible.cfg"
      ansible.playbook = "./provisioning/playbooks/create_container_hv.yml"
      ansible.become = true
      ansible.inventory_path = "./provisioning/inventories/testing.ini"
    end
  end
end
