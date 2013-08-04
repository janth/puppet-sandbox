# vim:ft=puppet:foldmethod=syntax:tw=80

# Work around the fact that we cannot trust facts ;->
# See  http://projects.puppetlabs.com/issues/19514
# $verifiedcert = certcheck()

# import 'classes/*'
# import 'nodes/*'
notify {'JTM: site!!!':}

import 'nodes'

/*
node default {
  notify {'JTM: node default.':}
}

node basenode inherits default {
  import 'nodes/basenode'
  notify {'JTM: node basenode.':}
}

#node /client\d.evry.dev/ inherits basenode {
node 'client1.evry.dev' inherits basenode {
  notify {'JTM: client1.evry.dev.':}
}

node 'puppet.evry.dev' inherits basenode {
  import 'nodes/puppetmaster'
  notify {'JTM: puppet.evry.dev.':}
}
*/
