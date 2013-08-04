## EVRY lab VirtualBox + Vagrant + Puppet with puppetmaster and clients {oel,sol11}

Author: Jan Thomas

## Om puppet

<a href="http://puppetlabs.com"><abbr title="Puppet automation tool">Puppet</abbr> Labs</a> - The Company behind <abbr title="Puppet automation tool">Puppet</abbr></p>
<a href="http://puppetlabs.com/puppet/puppet-open-source/"><abbr title="Puppet automation tool">Puppet</abbr></a> - The OpenSource version</p>
<a href="http://puppetlabs.com/puppet/puppet-enterprise/"><abbr title="Puppet automation tool">Puppet</abbr> Enterprise</a> - The commercial version</p>
<a href="http://puppetlabs.com/community/overview/">The Community</a> - Active and vibrant</p>
<a href="http://docs.puppetlabs.com/"><abbr title="Puppet automation tool">Puppet</abbr> Documentation</a> - Main and Official reference</p>
<abbr title="Puppet automation tool">Puppet</abbr> Modules on: <a href="http://forge.puppetlabs.com">Module Forge</a> and <a href="https://github.com/search?q=puppet">GitHub</a></p>
Software related to <abbr title="Puppet automation tool">Puppet</abbr>:<br />
* <a href="http://docs.puppetlabs.com/mcollective/">MCollective</a> - Infrastructure Orchestration framework<br /> <a href="http://docs.puppetlabs.com/hiera/1/">Hiera</a> - Key-value lookup tool where <abbr title="Puppet automation tool">Puppet</abbr> data can be placed<br /> <a href="http://docs.puppetlabs.com/puppetdb/1/">PuppetDB</a> - An Inventory Service and StoredConfigs backend<br /> <a href="http://docs.puppetlabs.com/dashboard/"><abbr title="Puppet automation tool">Puppet</abbr> DashBoard</a> - A <abbr title="Puppet automation tool">Puppet</abbr> <em>Web frontend</em> and External Node Classifier (ENC)<br /> <a href="http://theforeman.org/">The Foreman</a> - A well-known third party provisioning tool and <abbr title="Puppet automation tool">Puppet</abbr> ENC<br /> <a href="http://cloudsmith.github.com/geppetto">Geppetto</a> - A <abbr title="Puppet automation tool">Puppet</abbr> IDE based on Eclipse</p>


http://www.puppetcookbook.com/posts/add-a-unix-group.html

### Puppet + vim
To valg:
* Enten hent http://downloads.puppetlabs.com/puppet/puppet.vim og legg i din ~/.vim/syntax
* Eller https://github.com/rodjek/vim-puppet (har bedre keyword farging)
som er enklest hvis en bruker vim bundle/vundle/pathogen: 
 0. (Valgfritt) les mer på https://github.com/gmarik/vundle
 1. git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
 2. vim ~/.vimrc
 3. legg til følgende:

   ```vim
   set nocompatible               " be iMproved
   filetype off                   " required!

   set rtp+=~/.vim/bundle/vundle/
   call vundle#rc()

   " Required: Let Vundle manage Vundle 
   Bundle 'gmarik/vundle'
   Bundle 'rodjek/vim-puppet'
   filetype plugin indent on     " required!
   ```

4. `vim +BundleInstall +qall`

Alternativ editor: Geppetto (Eclipse plugin): http://cloudsmith.github.io/geppetto/

### Testing
* puppet-lint site/site.pp
* puppet apply --noop --verbose site/site.pp

### Andre anbefalinger:
* Bruk alltid siste versjon av vagrant: http://downloads.vagrantup.com/
* Installer puppet: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html
* Installer puppet-lint: http://puppet-lint.com/
* Installer zsh: http://zsh.sourceforge.net/
   http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
   http://grml.org/zsh/zsh-lovers.html
   http://zshwiki.org/home/
   http://www.slideshare.net/jaguardesignstudio/why-zsh-is-cooler-than-your-shell-16194692
   http://fendrich.se/blog/2012/09/28/no/
* Installer oh-my-zsh: https://github.com/robbyrussell/oh-my-zsh og http://www.stevendobbelaere.be/installing-and-configuring-the-oh-my-zsh-shell/
* grml-zsh: http://grml.org/zsh/

### links
* PuppetLabs PDF doc: http://puppetlabs.com/misc/pdf-doc/
* MultiVM: https://gist.github.com/dlutzy/2469037
* http://kiennt.com/blog/2012/06/28/using-vagrant-to-setup-multiple-virtual-machie.html
* https://github.com/patrickdlee/vagrant-examples
* https://github.com/mitchellh/vagrant/issues/1693
* https://github.com/grahamgilbert/vagrant-puppetmaster
* https://github.com/puppetlabs/puppet-vagrant-boxes
* http://stackoverflow.com/questions/13065576/override-vagrant-configuration-settings-locally-per-dev
* https://github.com/grahamgilbert/vagrant-puppetmaster
* https://github.com/puppetlabs/puppet-vagrant-boxes
* https://github.com/fsalum/vagrant-puppet
