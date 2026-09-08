Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.boot_timeout = 600
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.hostmanager.enabled = true 
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = false

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  centos_setup = lambda do |node|
    node.vm.box = "geerlingguy/centos7"
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 1024
    end
    node.vm.provision "shell", inline: <<-SHELL
      sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS-*.repo
      sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS-*.repo
      sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS-*.repo
      yum clean all
    SHELL
  end

  # Nginx
  config.vm.define "nginx" do |nginx|
    nginx.vm.box = "ubuntu/jammy64"
    nginx.vm.hostname = "nginx"
    nginx.vm.network "private_network", ip: "192.168.56.11"
    nginx.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--paravirtprovider", "hyperv"]
      vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
      vb.customize ["modifyvm", :id, "--nested-paging", "on"]
    end
  end

  # Tomcat
  config.vm.define "tomcat" do |tomcat|
    centos_setup.call(tomcat)
    tomcat.vm.hostname = "tomcat"
    tomcat.vm.network "private_network", ip: "192.168.56.12"
  end

  # RabbitMQ
  config.vm.define "rabbit" do |rabbit|
    centos_setup.call(rabbit)
    rabbit.vm.hostname = "rabbit"
    rabbit.vm.network "private_network", ip: "192.168.56.13"
  end

  # Memcache
  config.vm.define "memcache" do |memcache|
    centos_setup.call(memcache)
    memcache.vm.hostname = "memcache"
    memcache.vm.network "private_network", ip: "192.168.56.14"
  end

  # DB
  config.vm.define "db" do |db|
    centos_setup.call(db)
    db.vm.hostname = "db"
    db.vm.network "private_network", ip: "192.168.56.15"
  end
end