Vagrant.configure("2") do |config|

  config.vm.define "website" do |website|
    website.vm.box = "geerlingguy/centos7"
    website.vm.network "private_network", ip: "192.168.33.15"
    if Vagrant.has_plugin?("vagrant-vbguest")
      website.vbguest.auto_update = false
    end
    website.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = "2048"
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] 
    end
    website.vm.provision "shell", inline: <<-SHELL
      set -e
      if ! grep -q "vault.centos.org" /etc/yum.repos.d/CentOS-Base.repo 2>/dev/null; then
        sed -i s/mirror.centos.org/vault.centos.org/g /etc/yum.repos.d/CentOS-*.repo
        sed -i s/^#.*baseurl=http/baseurl=http/g /etc/yum.repos.d/CentOS-*.repo
        sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS-*.repo
        yum clean all
      fi

      yum install httpd wget unzip -y
      systemctl start httpd
      systemctl enable httpd
      cd /tmp/
      wget https://www.tooplate.com/zip-templates/2167_orbital.zip
      unzip -o 2167_orbital.zip
      cp -r 2167_orbital/* /var/www/html
      systemctl restart httpd
    SHELL
  end

  config.vm.define "wordpress" do |wordpress|
    wordpress.vm.box = "ubuntu/jammy64"
    wordpress.vm.boot_timeout = 600

    wordpress.vm.network "private_network", ip: "192.168.33.16"

    if Vagrant.has_plugin?("vagrant-vbguest")
      wordpress.vbguest.auto_update = false
    end

    wordpress.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      vb.memory = 3072
      vb.customize ["modifyvm", :id, "--ioapic", "on"]
      vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
      vb.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
      vb.customize ["modifyvm", :id, "--paravirtprovider", "hyperv"]
      vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
      vb.customize ["modifyvm", :id, "--nested-paging", "on"]
    end

    wordpress.vm.provision "shell", inline: <<-SHELL
      set -e
      export DEBIAN_FRONTEND=noninteractive

      sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
      update-grub

      apt update -y
      apt install -y apache2 ghostscript libapache2-mod-php mysql-server \
                    php php-bcmath php-curl php-imagick php-intl \
                    php-mbstring php-mysql php-xml php-zip curl

      mkdir -p /srv/www
      chown www-data:www-data /srv/www
      curl -s https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

      if [ -f /vagrant/wordpress.conf ]; then
        cp /vagrant/wordpress.conf /etc/apache2/sites-available/wordpress.conf
        a2ensite wordpress
        a2enmod rewrite
        a2dissite 000-default
        systemctl reload apache2
      fi

      systemctl enable --now mysql
      mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
      mysql -e "CREATE USER IF NOT EXISTS 'wordpress'@'localhost' IDENTIFIED BY 'admin';"
      mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
      mysql -e "FLUSH PRIVILEGES;"

      if [ -f /srv/www/wordpress/wp-config-sample.php ]; then
        sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
        sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
        sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
        sudo -u www-data sed -i 's/password_here/admin/' /srv/www/wordpress/wp-config.php
      fi
    SHELL
  end
end
