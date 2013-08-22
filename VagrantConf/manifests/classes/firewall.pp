class firewall {
  case $osfamily {
    RedHat: { $service_name = "iptables" }
    Debian: { $service_name = "iptables" }
    default: { fail("Unrecognized operating system") }
  }
  # Disable firewall
  service{'firewall':
    name   => $service_name,
    ensure => stopped,
    enable => false,
  }
}
