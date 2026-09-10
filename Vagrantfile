Vagrant.configure("2") do |config|
  config.vm.box_check_update = false 
  config.vm.define "scriptbox" do |scriptbox|
    if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end
    scriptbox.vm.box = "eurolinux-vagrant/centos-stream-9"
	scriptbox.vm.network "private_network", ip: "192.168.10.12"
	scriptbox.vm.provider "virtualbox" do |vb|
     vb.memory = "1024"
   end
  end
  

  config.vm.define "web01" do |web01|
    web01.vm.box = "eurolinux-vagrant/centos-stream-9"
	web01.vm.network "private_network", ip: "192.168.10.13"
  end
  
  config.vm.define "web02" do |web02|
    web02.vm.box = "eurolinux-vagrant/centos-stream-9"
	web02.vm.network "private_network", ip: "192.168.10.14"
  end

   config.vm.define "web03" do |web03|
    web03.vm.box = "ubuntu/jammy64"
        web03.vm.network "private_network", ip: "192.168.10.15"
  end
end
