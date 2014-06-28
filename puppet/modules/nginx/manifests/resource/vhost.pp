# define: nginx::resource::vhost
#
# This definition creates a virtual host
#
# Parameters:
#   [*ensure*]              - Enables or disables the specified vhost (present|absent)
#   [*listen_ip*]           - Default IP Address for NGINX to listen with this vHost on. Defaults to all interfaces (*)
#   [*listen_port*]         - Default IP Port for NGINX to listen with this vHost on. Defaults to TCP 80
#   [*listen_options*]      - Extra options for listen directive like 'default' to catchall. Undef by default.
#   [*ipv6_enable*]         - BOOL value to enable/disable IPv6 support (false|true). Module will check to see if IPv6
#                             support exists on your system before enabling.
#   [*ipv6_listen_ip*]      - Default IPv6 Address for NGINX to listen with this vHost on. Defaults to all interfaces (::)
#   [*ipv6_listen_port*]    - Default IPv6 Port for NGINX to listen with this vHost on. Defaults to TCP 80
#   [*ipv6_listen_options*] - Extra options for listen directive like 'default' to catchall. Template will allways add ipv6only=on.
#                             While issue jfryman/puppet-nginx#30 is discussed, default value is 'default'.
#   [*index_files*]         - Default index files for NGINX to read when traversing a directory
#   [*proxy*]               - Proxy server(s) for the root location to connect to.  Accepts a single value, can be used in
#                             conjunction with nginx::resource::upstream
#   [*proxy_read_timeout*]  - Override the default the proxy read timeout value of 90 seconds
#   [*ssl*]                 - Indicates whether to setup SSL bindings for this vhost.
#   [*ssl_cert*]            - Pre-generated SSL Certificate file to reference for SSL Support. This is not generated by this module.
#   [*ssl_key*]             - Pre-generated SSL Key file to reference for SSL Support. This is not generated by this module.
#   [*ssl_port*]            - Default IP Port for NGINX to listen with this SSL vHost on. Defaults to TCP 443
#   [*server_name*]         - List of vhostnames for which this vhost will respond. Default [$name].
#   [*www_root*]            - Specifies the location on disk for files to be read from. Cannot be set in conjunction with $proxy
#   [*rewrite_www_to_non_www*]  - Adds a server directive and rewrite rule to rewrite www.domain.com to domain.com in order to avoid
#                             duplicate content (SEO);
#   [*try_files*]           - Specifies the locations for files to be checked as an array. Cannot be used in conjuction with $proxy.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#  nginx::resource::vhost { 'test2.local':
#    ensure   => present,
#    www_root => '/var/www/nginx-default',
#    ssl      => 'true',
#    ssl_cert => '/tmp/server.crt',
#    ssl_key  => '/tmp/server.pem',
#  }
define nginx::resource::vhost(
  $ensure                 = 'enable',
  $listen_ip              = '*',
  $listen_port            = '80',
  $listen_options         = undef,
  $ipv6_enable            = false,
  $ipv6_listen_ip         = '::',
  $ipv6_listen_port       = '80',
  $ipv6_listen_options    = 'default',
  $ssl                    = false,
  $ssl_cert               = undef,
  $ssl_key                = undef,
  $ssl_port		  = '443',
  $proxy                  = undef,
  $proxy_read_timeout     = $nginx::params::nx_proxy_read_timeout,
  $index_files            = undef,
  $server_name            = [$name],
  $www_root               = undef,
  $rewrite_www_to_non_www = false,
  $location_cfg_prepend   = undef,
  $location_cfg_append    = undef,
  $try_files              = undef,
  $custom_template        = undef
) {

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  # Add IPv6 Logic Check - Nginx service will not start if ipv6 is enabled
  # and support does not exist for it in the kernel.
  if ($ipv6_enable == 'true') and ($ipaddress6)  {
    warning('nginx: IPv6 support is not enabled or configured properly')
  }

  # Check to see if SSL Certificates are properly defined.
  if ($ssl == 'true') {
    if ($ssl_cert == undef) or ($ssl_key == undef) {
      fail('nginx: SSL certificate/key (ssl_cert/ssl_cert) and/or SSL Private must be defined and exist on the target system(s)')
    }
  }

  # Use the File Fragment Pattern to construct the configuration files.
  # Create the base configuration file reference.
  if ($listen_port != $ssl_port) {
    file { "${nginx::config::nx_temp_dir}/nginx.d/${name}-001":
      ensure  => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_header.erb'),
      notify => Class['nginx::service'],
    }
  }

  if ($ssl == 'true') and ($ssl_port == $listen_port) {
    $ssl_only = 'true'
  }

  # Create the default location reference for the vHost
  nginx::resource::location {"${name}-default":
    ensure               => $ensure,
    vhost                => $name,
    ssl                  => $ssl,
    ssl_only             => $ssl_only,
    location             => '/',
    proxy                => $proxy,
    proxy_read_timeout   => $proxy_read_timeout,
    try_files            => $try_files,
    www_root             => $www_root,
    custom_template      => $custom_template,
    notify               => Class['nginx::service'],
    index_files          => $index_files,
  }

  # Support location_cfg_prepend and location_cfg_append on default location created by vhost
  if $location_cfg_prepend {
    Nginx::Resource::Location["${name}-default"] {
      location_cfg_prepend => $location_cfg_prepend
    }
  }
  if $location_cfg_append {
    Nginx::Resource::Location["${name}-default"] {
      location_cfg_append => $location_cfg_append
    }
  }
  # Create a proper file close stub.
  if ($listen_port != $ssl_port) {
    file { "${nginx::config::nx_temp_dir}/nginx.d/${name}-699":
      ensure  => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_footer.erb'),
      notify  => Class['nginx::service'],
    }
  }

  # Create SSL File Stubs if SSL is enabled
  if ($ssl == 'true') {
    file { "${nginx::config::nx_temp_dir}/nginx.d/${name}-700-ssl":
      ensure => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_ssl_header.erb'),
      notify => Class['nginx::service'],
    }
    file { "${nginx::config::nx_temp_dir}/nginx.d/${name}-999-ssl":
      ensure => $ensure ? {
        'absent' => absent,
        default  => 'file',
      },
      content => template('nginx/vhost/vhost_footer.erb'),
      notify => Class['nginx::service'],
    }
  }
}
