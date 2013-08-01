# vim:ft=puppet:foldmethod=syntax:tw=80

# Work around the fact that we cannot trust facts ;->
# See  http://projects.puppetlabs.com/issues/19514
# $verifiedcert = certcheck()

import 'nodes'
