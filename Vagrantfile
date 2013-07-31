# -*- mode: ruby -*-
# vim:ft=ruby:sw=2

# debug:
# VAGRANT_LOG=debug vagrant up

Vagrant.configure("2") do |config|

  #config.vm.provision :shell, :inline => "echo Hello"
  # MultiVM: https://gist.github.com/dlutzy/2469037
  # http://kiennt.com/blog/2012/06/28/using-vagrant-to-setup-multiple-virtual-machie.html

  config.vm.define :client1 do |client1_config|
     client1_config.vm.box = "client1"
     client1_config.vm.box_url = "~/EVRY/Boxes/centos-6.4.box"
     client1_config.vm.hostname = "client1.home.lan"

     client1_config.vm.provider :virtualbox do |vb|
       # # Don't boot with headless mode
       # vb.gui = true
       vb.customize ["modifyvm", :id, "--memory", "224"]
     end
     # client1_config.vm.network :forwarded_port, guest: 80, host: 8080

     # First NIC is always NAT
     # https://github.com/mitchellh/vagrant/issues/1693
     #client1_config.vm.network :private_network, ip: "172.16.10.10"
     #client1_config.vm.network :private_network, ip: "172.16.10.10", :adapter => 2
     client1_config.vm.network :private_network, ip: "172.16.10.11"
     #client1_config.vm.network :public_network
     # client1_config.ssh.forward_agent = true
     client1_config.vm.synced_folder "/home/et2441", "/vagrant_data"
  end

  config.vm.define :client2 do |client2_config|
     client2_config.vm.box = "client2"
     client2_config.vm.box_url = "~/EVRY/Boxes/centos-6.4.box"
     client2_config.vm.hostname = "client2.home.lan"

     client2_config.vm.provider :virtualbox do |vb|
       # # Don't boot with headless mode
       # vb.gui = true
       vb.customize ["modifyvm", :id, "--memory", "224"]
     end
     # client2_config.vm.network :forwarded_port, guest: 80, host: 8080

     # First NIC is always NAT
     # https://github.com/mitchellh/vagrant/issues/1693
     #client2_config.vm.network :private_network, ip: "172.16.10.10"
     #client2_config.vm.network :private_network, ip: "172.16.10.10", :adapter => 2
     client2_config.vm.network :private_network, ip: "172.16.10.12"
     #client2_config.vm.network :public_network
     # client2_config.ssh.forward_agent = true
     client2_config.vm.synced_folder "/home/et2441", "/vagrant_data"
  end

  config.vm.define :puppetmaster do |puppetmaster_config|
     puppetmaster_config.vm.box = "puppetmaster"
     puppetmaster_config.vm.box_url = "~/EVRY/Boxes/centos-6.4.box"
     puppetmaster_config.vm.hostname = "puppetmaster.home.lan"

     puppetmaster_config.vm.provider :virtualbox do |vb|
       # # Don't boot with headless mode
       # vb.gui = true
       vb.customize ["modifyvm", :id, "--memory", "224"]
     end
     # puppetmaster_config.vm.network :forwarded_port, guest: 80, host: 8080

     # First NIC is always NAT
     # https://github.com/mitchellh/vagrant/issues/1693
     #puppetmaster_config.vm.network :private_network, ip: "172.16.10.10"
     #puppetmaster_config.vm.network :private_network, ip: "172.16.10.10", :adapter => 2
     puppetmaster_config.vm.network :private_network, ip: "172.16.10.10"
     #puppetmaster_config.vm.network :public_network
     # puppetmaster_config.ssh.forward_agent = true
     puppetmaster_config.vm.synced_folder "/home/et2441", "/vagrant_data"
  end

  # https://github.com/grahamgilbert/vagrant-puppetmaster
  # https://github.com/puppetlabs/puppet-vagrant-boxes

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file client1.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "init.pp"
  # end
  #
  # config.vm.provision :puppet do |puppet|
  #   puppet.manifests_path = File.expand_path("../manifests", __FILE__)
  # end

  ## Puppet workshop:
  ## Enable Puppet --debug setting on provisioning? Used from command line with DEBUG=true vagrant up nodeX
  #DEBUG = ENV['DEBUG'] ? '--debug' : ''
  #config.vm.provision :puppet do |puppet|
  #  puppet.manifests_path = "site"
  #  puppet.manifest_file  = "site.pp"
  #  puppet.module_path    = [ "modules", "site" ]
  #  puppet.options        = "--verbose --hiera_config hiera_vagrant.yaml %s" % DEBUG
  #  puppet.facter = {
  #     "is_vagrant" => true,
  #  }
  #end

end
