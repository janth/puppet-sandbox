# vim:ft=puppet:foldmethod=syntax:tw=80

# http://bombasticmonkey.com/2011/12/27/stop-writing-puppet-modules-that-suck/
# http://www.slideshare.net/PuppetLabs/puppet-camp-sfoforge-18496179
# http://serverfault.com/questions/488595/how-to-maintain-site-pp-with-many-nodes
# https://github.com/elasticdog/puppet-sandbox

import 'classes/*'

node default {}

node basenode {

  include stdlib

  include "puppetclient"
  include "rsyslog"
  include "firewall"

}

node /client\d/ inherits basenode {}

node 'puppet.evry.dev' inherits basenode {

  include "puppetmaster"
}
