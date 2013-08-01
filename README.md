## EVRY lab VirtualBox + Vagrant + Puppet with puppetmaster and clients {oel,sol11}

Author: Jan Thomas

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
* MultiVM: https://gist.github.com/dlutzy/2469037
* http://kiennt.com/blog/2012/06/28/using-vagrant-to-setup-multiple-virtual-machie.html
* https://github.com/patrickdlee/vagrant-examples
* https://github.com/mitchellh/vagrant/issues/1693
* https://github.com/grahamgilbert/vagrant-puppetmaster
* https://github.com/puppetlabs/puppet-vagrant-boxes
* http://stackoverflow.com/questions/13065576/override-vagrant-configuration-settings-locally-per-dev
* https://github.com/grahamgilbert/vagrant-puppetmaster
* https://github.com/puppetlabs/puppet-vagrant-boxes
