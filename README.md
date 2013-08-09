## EVRY lab VirtualBox + Vagrant + Puppet with puppetmaster and clients {oel,sol11}

Author: Jan Thomas

## Om puppet
[Puppet Labs](http://puppetlabs.com/) - The Company behind Puppet  
[Puppet](http://puppetlabs.com/puppet/puppet-open-source/) - The OpenSource version  
[Puppet Enterprise](http://puppetlabs.com/puppet/puppet-enterprise/)- The commercial version  
[The Community](http://puppetlabs.com/community/overview/)- Active and vibrant  
[Documentation](http://docs.puppetlabs.com/) - Main and Official reference  
[PDF Docs](http://puppetlabs.com/misc/pdf-doc/) - For download and offline access
Puppet Modules: [Module Forge](http://forge.puppetlabs.com), [GitHub](https://github.com/search?q=puppet)  
_MEN NB!_ Vi skal bruke minst mulig av de. Offisiell velsignet modulliste vil komme på [wikien](http://212.18.136.81/wiki/dashboard.action)

#### Related programvare
[MCollective](http://docs.puppetlabs.com/mcollective/) - Infrastructure Orchestration framework  
[Hiera](http://docs.puppetlabs.com/hiera/1/) - Key-value lookup tool where Puppet data can be placed  
[PuppetDB](http://docs.puppetlabs.com/puppetdb/1/) - An Inventory Service and StoredConfigs backend  
[Puppet DashBoard](http://docs.puppetlabs.com/dashboard/) - A Puppet Web frontend and External Node Classifier (ENC)  
[The Foreman](http://theforeman.org/) - A well-known third party provisioning tool and Puppet ENC  
[Geppetto](http://cloudsmith.github.com/geppetto) - A Puppet IDE based on [Eclipse](http://eclipse.org/)

## Om Lab'en (Linux/Windows)
Dette lab-oppstettet lager 3 stk virtualbox VMer ved hjelp av Vagrant; 2 linux og en solaris11. Den ene linuxen blir satt opp som puppetmaster med dashboard og puppetdb. Den andre linuxen og solaris11 er tenk som klienter.

**NB!** Laben er utviklet på PC med linux som hoved-os, og derfor kun testet der.
Har du __windows på din PC__, er det nytt farvann og ukjent terreng, men både Virtualbox, Vagrant og Git skal være mulig å installere på Windows. Se feks http://guides.beanstalkapp.com/version-control/git-on-windows.html for instruksjoner.

### Puppet Editor ([vim](http://www.vim.org)/[Eclipse](http://eclipse.org/))
To valg:
* *Enten* https://github.com/rodjek/vim-puppet (har bedre keyword farging)
som er enklest hvis en bruker vim [bundle/vundle/pathogen](https://github.com/gmarik/vundle): 
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
   Bundle 'godlygeek/tabular'
   Bundle 'scrooloose/syntastic'
   " SnipMate + vim-snippets
   Bundle 'MarcWeber/vim-addon-mw-utils'
   Bundle 'tomtom/tlib_vim'
   Bundle 'garbas/vim-snipmate'
   Bundle 'honza/vim-snippets'
   filetype plugin indent on     " required!
   ```
4. last inn:
   ```vim +BundleInstall +qall```

* *Eller* hent http://downloads.puppetlabs.com/puppet/puppet.vim og legg i din ~/.vim/syntax

Alternativ editor: Geppetto (Eclipse plugin): http://cloudsmith.github.io/geppetto/


### Lab GUI mm
* Dashboard: http://172.16.10.10:300/
* PuppetDB: http://172.16.10.10:8080/
* CLI spørringer:
    sudo puppet agent --test
    curl -k -H "Accept: yaml" https://puppet:8140/production/facts/puppet.evry.dev
    curl -H "Accept: application/json" http://puppet:8080/v2/facts/puppet.evry.dev
    curl -H "Accept: application/json" http://puppet:8080/v2/metrics/mbean/java.lang:type=Memory

### Logger (på puppetmaster puppet.evry.dev)
    tail -f /var/log/puppet*/* /usr/share/puppet-dashboard/log/*

### Validering av puppetkode
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
