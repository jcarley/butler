# -*- mode: ruby -*-
# vi: set ft=ruby :

$setup = <<SCRIPT
# Stop and remove any existing containers
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)

make -f /home/vagrant/apps/butler/docker/extras/Makefile

/home/vagrant/apps/butler/docker/tools/build.sh
SCRIPT

$start = <<SCRIPT
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
/home/vagrant/apps/butler/docker/tools/run.sh
SCRIPT

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.provider :vmware_fusion do |v|
    config.vm.box = "jcarley/ubuntu1404-docker-puppet"
    v.vmx["memsize"] = "2048"
    v.vmx["numvcpus"] = "2"
  end

  config.vm.network :private_network, ip: "33.33.33.4"
  config.vm.network :forwarded_port, guest: 3000, host: 3000, :auto => true
  config.vm.network :forwarded_port, guest: 80, host: 80, :auto => true

  config.vm.synced_folder ".", "/home/vagrant/apps/butler"

  config.vm.provision "shell", inline: $setup

  config.vm.provision "shell", run: "always", inline: $start
end
