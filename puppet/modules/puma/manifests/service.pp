class puma::service {
  service { 'puma-manager':
    provider   => 'upstart',
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    status     => "/sbin/initctl list | /bin/grep '^puma .*$' | /bin/grep process",
  }
}

