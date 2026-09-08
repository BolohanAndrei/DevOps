Vagrant.configure("2") do |config|
  config.vm.box_check_update = false
  config.vm.boot_timeout = 600

  config.hostmanager.enabled = true 
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.include_offline = false

  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
  end

  centos_setup = lambda do |node, ip_addr, script_name, ram_mb|
    node.vm.box = "eurolinux-vagrant/centos-stream-9"
    node.vm.network "private_network", ip: ip_addr
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = ram_mb
    end
    node.vm.provision "shell", path: script_name
  end

  # DB
  config.vm.define "db" do |db|
    db.vm.hostname = "db"
    centos_setup.call(db, "192.168.56.15", "mysql.sh", 1024)
  end

  # Memcache
  config.vm.define "memcache" do |memcache|
    memcache.vm.hostname = "memcache"
    centos_setup.call(memcache, "192.168.56.14", "memcache.sh", 512)
  end

  # RabbitMQ
  config.vm.define "rabbit" do |rabbit|
    rabbit.vm.hostname = "rabbit"
    centos_setup.call(rabbit, "192.168.56.13", "rabbitmq.sh", 1024)
  end

  # Tomcat
  config.vm.define "tomcat" do |tomcat|
    tomcat.vm.hostname = "tomcat"
    centos_setup.call(tomcat, "192.168.56.12", "tomcat.sh", 1024)
  end

  # Nginx
  config.vm.define "nginx" do |nginx|
    nginx.vm.box = "ubuntu/jammy64"
    nginx.vm.hostname = "nginx"
    nginx.vm.network "private_network", ip: "192.168.56.11"
    nginx.vm.provider "virtualbox" do |vb|
      vb.cpus = 1
      vb.memory = 512
    end
    nginx.vm.provision "shell", path: "nginx.sh"
  end
end