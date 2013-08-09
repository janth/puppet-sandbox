# vim:ft=ruby:sw=2:foldmethod=syntax:foldlevel=3

#####
# Usage:
# Place this file in a directory (no need for 'vagrant init')
# run 'vagrant status', then 'vagrant up <box>'
# Enjoy
#
# To get vagrant debug output:
# VAGRANT_LOG=debug vagrant up
#####

# Notes:
# Puppet+Dashboard+PuppetDb: https://github.com/grahamgilbert/vagrant-puppetmaster
# Compact/rubycode MultiVM config: https://gist.github.com/dlutzy/2469037
# http://kiennt.com/blog/2012/06/28/using-vagrant-to-setup-multiple-virtual-machie.html
# https://github.com/patrickdlee/vagrant-examples
# https://github.com/mitchellh/vagrant/issues/1693
# https://github.com/grahamgilbert/vagrant-puppetmaster
# https://github.com/puppetlabs/puppet-vagrant-boxes
# http://stackoverflow.com/questions/13065576/override-vagrant-configuration-settings-locally-per-dev
# https://github.com/grahamgilbert/vagrant-puppetmaster
# https://github.com/puppetlabs/puppet-vagrant-boxes
# https://github.com/fsalum/vagrant-puppet
#


# ENV['VAGRANT_LOG'] = 'debug' # Does not work, probably too late anyway
domain = 'evry.dev'
#box_url = "~/EVRY/Boxes/centos-6.4.box"
# http://212.18.136.81/vagrant/boxes/ or I:\OS\vagrantboxes

nodes = [
  { :hostname => 'puppet',  :ip => '172.16.10.10', :ram => 384, :box => 'CentOS-6.4-32bit', :osclass => 'redhat',  :uri => 'http://212.18.136.81/vagrant/boxes/centos-6.4.box' },
  { :hostname => 'client1', :ip => '172.16.10.11', :ram => 224, :box => 'OEL-6.4-x86_64',   :osclass => 'redhat',  :uri => 'http://212.18.136.81/vagrant/boxes/vagrant-OracleLinux-6.4-x86_64.box' },
  { :hostname => 'client2', :ip => '172.16.10.12', :ram => 512, :box => 'Sol11-11.1',       :osclass => 'solaris', :uri => 'http://212.18.136.81/vagrant/boxes/vagrant-Solaris-11.1-64bit__2013-07-26-13-12.box' },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    guest_os = node[:osclass] ? node[:osclass] : ':linux';
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.box_url = node[:uri]
      node_config.vm.guest = node[:osclass]
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      # Port Forwarding and shared folders
      #node_config.vm.network :forwarded_port, guest: 80, host: 8080
      node_config.vm.synced_folder "/home/et2441", "/vagrant_data"
      node_config.vm.synced_folder "puppet/manifests", "/etc/puppet/manifests"
      node_config.vm.synced_folder "puppet/modules",   "/etc/puppet/modules"
      node_config.vm.synced_folder "puppet/hieradata", "/etc/puppet/hieradata"

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm.provider :virtualbox do |vb|
        # vb.gui = true # Don't boot with headless mode
        vb.customize [
          'modifyvm', :id,
          '--name', 'EVRYlab_' + node[:hostname],
          '--memory', memory.to_s
        ]
      end # virtualbox customization

      # Bootstrap Bash Script
      #node_config.vm.provision :shell, :path => "bootstrap.sh"
      #node_config.vm.provision :shell, :inline => "echo Hello"

      # http://vstone.eu/vagrant-and-virtualbox-a-debugging-story/
      DEBUG = ENV['DEBUG'] ? '--debug' : ''
      node_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "VagrantConf/manifests"         # usually manifests/
        puppet.manifest_file  = "site.pp"
        puppet.module_path    = [ "VagrantConf/modules.local", "VagrantConf/modules" ]
        #puppet.options        = "--verbose --hiera_config hiera_vagrant.yaml %s" % DEBUG
        #puppet.options        = "--verbose %s" % DEBUG
        puppet.options        = "--verbose --debug"
        #puppet.options        = "--verbose"
        puppet.facter = {
           "is_vagrant" => true,
        }
      end

    end # node_config
  end # nodes loop


    #puppetmaster_config.vm.provision :shell, :path => "puppet_master.sh"
    # Enable the Puppet provisioner
    #puppetmaster_config.vm.provision :puppet, :module_path => "VagrantConf/modules", :manifests_path => "VagrantConf/manifests", :manifest_file => "default.pp"
    # puppet.manifests_path = File.expand_path("../manifests", __FILE__)

end

__END__

Ruby block comment:
=begin
   multi
   line
   comment
=end

<<-X
   multi
   line
   comment
X
# But gives warning 'possibly useless use of a literal in void context'


### links


require './evryvagrant.rb'
include EVRY

# File evryvagrant.rb:
module EVRY
  FOO = 'bar'
  # then use FOO in Vagrantfile config
end

  #config.vm.provision :shell, :inline => "echo Hello"

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

  https://github.com/dotless-de/vagrant-vbguest
end
