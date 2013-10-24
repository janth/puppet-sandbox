# vim:ft=ruby:sw=2:foldmethod=syntax:foldlevel=9

domain = 'evry.dev'
boxes = 'http://212.18.136.81/vagrant/boxes/'

nodes = [
  { :hostname => 'puppet',  :ip => '172.16.10.10', :ram => 384, :box => 'vagrant-OracleLinux-6.4-x86_64', :osclass => 'redhat'},
  { :hostname => 'client1', :ip => '172.16.10.11', :ram => 224, :box => 'vagrant-OracleLinux-6.4-x86_64', :osclass => 'redhat' },
  { :hostname => 'client2', :ip => '172.16.10.12', :ram => 512, :box => 'vagrant-Solaris-11.1-64bit__2013-07-26-13-12', :osclass => 'solaris11' },
]

Vagrant.configure("2") do |config|
  nodes.each do |node|
    guest_os = node[:osclass] ? node[:osclass] : ':linux';
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      node_config.vm.box_url = boxes + node[:box] + '.box'
      node_config.vm.guest = node[:osclass]
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      node_config.vm.synced_folder "puppet/manifests", "/etc/puppet/manifests"
      node_config.vm.synced_folder "puppet/modules",   "/etc/puppet/modules"
      node_config.vm.synced_folder "puppet/hieradata", "/etc/puppet/hieradata"

      memory = node[:ram] ? node[:ram] : 256;
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--memory', memory.to_s
        ]
      end # virtualbox customization


      node_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = "VagrantConf/manifests"         # usually manifests/
        puppet.manifest_file  = "site.pp"
        puppet.module_path    = [ "VagrantConf/modules" ]
        puppet.options        = "--verbose"
      end

    end
  end
end
