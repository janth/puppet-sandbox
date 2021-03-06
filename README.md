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
_MEN NB!_ Vi skal bruke minst mulig av de. Offisiell velsignet modulliste vil komme p� [wikien](http://212.18.136.81/wiki/display/MV/Puppet)

#### Related programvare
[MCollective](http://docs.puppetlabs.com/mcollective/) - Infrastructure Orchestration framework  
[Hiera](http://docs.puppetlabs.com/hiera/1/) - Key-value lookup tool where Puppet data can be placed  
[PuppetDB](http://docs.puppetlabs.com/puppetdb/1/) - An Inventory Service and StoredConfigs backend  
[Puppet DashBoard](http://docs.puppetlabs.com/dashboard/) - A Puppet Web frontend and External Node Classifier (ENC)  
[The Foreman](http://theforeman.org/) - A well-known third party provisioning tool and Puppet ENC  
[Geppetto](http://cloudsmith.github.com/geppetto) - A Puppet IDE based on [Eclipse](http://eclipse.org/)

## Om Lab'en (Linux/Windows)
Dette lab-oppstettet lager 3 stk virtualbox VMer ved hjelp av Vagrant; 2 linux og en solaris11. Den ene linuxen blir satt opp som puppetmaster med dashboard og puppetdb. Den andre linuxen og solaris11 er tenk som klienter.

**NB!** Laben er utviklet p� PC med linux som hoved-os, og derfor kun testet der.
Har du __windows p� din PC__, er det nytt farvann og ukjent terreng, men b�de Virtualbox, Vagrant og Git skal v�re mulig � installere p� Windows. Se feks http://guides.beanstalkapp.com/version-control/git-on-windows.html for instruksjoner.

### Kom i gang
0. Sjekk at du har en PC som oppfyller kravene:
   * PC: Kapabel til � kj�re 64bits programvare (linux: sjekk [linux-bits](https://raw.github.com/janth/cos/master/linux-bits.sh))  
     **NB!** Husk � installere 64-bits versjon av programmene under!!!
   * Diskplass: Minimum ~10G
   Detaljer:

   | .../lab | ~50Mb |
   |---------|------:|
   | ~/vagrant.d (holds the .box files) | ~2.6G |
   | ~/VirtualBox VMs (holds the Virtualbox machines) | ~ |
 
   VM maks disk (de er laget med en tynn vmdk diskfil, dvs filen vokser etterhvert som mer og mer installeres i VMen):

   | VM |  Max disk |
   |--------|----:|
   | puppet |  4G |
   | client1 | 20G |
   | client2 | 30G |

   * RAM: Du b�r ha 2G RAM ledig for � kj�re alle 3 lab-boxene.
   Detaljer (dette kan overstyres i Vagrantfile):

   | VM |  RAM |
   |--------|----:|
   | puppet |  384M |
   | client1 | 224M |
   | client2 | 512M |

1. Installer [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Installer [Vagrant](http://downloads.vagrantup.com/)
3. Installer [Git](http://git-scm.com/downloads) (eller for linux: ```sudo yum install git``` / ```sudo apt-get install git```
4. Lag en egen lab katalog
5. Klon dette prosjektet: ```git clone https://github.com/janth/vagrant.git```


Hvis du kj�rer windows:

6. Legg f�lgende i din ```/etc/hosts``` / ```%SystemRoot%\system32\drivers\etc\hosts```
   ```
   172.16.10.10   puppet.evry.dev   puppet pm
   172.16.10.11   client1.evry.dev  client1 c1
   172.16.10.12   client2.evry.dev  client2 c2
   ```
6. Legg vagrant box ssh-rsa key i din ssh config: https://github.com/mitchellh/vagrant/tree/master/keys
   TBD...
6. Oppdater modulene som brukes for � sette opp lab'en  
   TBD...


Hvis PCen din kj�rer linux:

7. Kj�r vagrant...
   
   ```bash
   # Denne fikser de manuelle stegene for windows automatisk! ;->
   bin/1stSetup.sh 

   vagrant up puppet
   vagrant provision puppet
   vagrant up client1
   vagrant up client2
   ```

Deretter...

8. Sjekk dashboard (http://172.16.10.10:3000/), du skal se 3 noder (ja, puppetmaster puppet (aka puppet.evry.dev) er node av seg selv)
9. Skriv puppetkode. **NB!** Se wiki for EVRY 8D44 Puppet Best Practice (http://212.18.136.81/wiki/display/MV/Puppet)
10. Ved dagens slutt:
   * Husk � lagre alle filer, commit kode til ditt repo, push til origin
   * La VMene hvile:
   ```bash
   vagrant suspend client1
   vagrant suspend client2
   ```
11. Neste dag:
   ```bash
   vagrant resume client1
   vagrant resume client2
   ```

### Puppet Editor ([vim](http://www.vim.org)/[Eclipse](http://eclipse.org/))
To valg:
* *Enten* https://github.com/rodjek/vim-puppet (har bedre keyword farging)
som er enklest hvis en bruker vim [bundle/vundle/pathogen](https://github.com/gmarik/vundle): 
 1. git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
 2. vim ~/.vimrc
 3. legg til f�lgende:

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
* Dashboard: http://172.16.10.10:3000/
* PuppetDB: http://172.16.10.10:8080/
* CLI sp�rringer:
    sudo puppet agent --test
    curl -k -H "Accept: yaml" https://puppet:8140/production/facts/puppet.evry.dev
    curl -H "Accept: application/json" http://puppet:8080/v2/facts/puppet.evry.dev
    curl -H "Accept: application/json" http://puppet:8080/v2/metrics/mbean/java.lang:type=Memory

### Logger (p� puppetmaster puppet.evry.dev)
    tail -f /var/log/puppet*/* /usr/share/puppet-dashboard/log/*

### Validering av puppetkode
* puppet-lint site/site.pp
* puppet apply --noop --verbose site/site.pp

### Andre anbefalinger:
* Bruk alltid siste versjon av vagrant: http://downloads.vagrantup.com/
* Installer puppet: http://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html
* Installer puppet-lint: http://puppet-lint.com/
