# vim:ft=puppet:foldmethod=syntax:tw=80

# http://bombasticmonkey.com/2011/12/27/stop-writing-puppet-modules-that-suck/
# http://www.slideshare.net/PuppetLabs/puppet-camp-sfoforge-18496179
# http://serverfault.com/questions/488595/how-to-maintain-site-pp-with-many-nodes
# https://github.com/elasticdog/puppet-sandbox

# import 'classes/*'
# import 'nodes/*'

notify {'JTM: file default.pp!!!':}

#import 'nodes'

node default {
  notify {'JTM: node default':}
}

node basenode inherits default {
  import 'nodes/basenode'
  notify {'JTM: node basenode.':}
}

node /client\d.evry.dev/ inherits basenode {
#node 'client1.evry.dev' inherits basenode {
  notify {'JTM: client\d.evry.dev.':}
}

node 'puppet.evry.dev' inherits basenode {
  import 'nodes/puppetmaster'
  notify {'JTM: puppet.evry.dev.':}
}
