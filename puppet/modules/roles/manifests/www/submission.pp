class profiles::submission(
  $run_as_user,
  $ruby_home_path = "/home/${run_as_user}/.rbenv/shims",
  $base_app_home,
  $rails_env      = $rails_environment,
) {

  $submission_port = 9292
  $control_app_port = 6464
  $submission_app_home = "$base_app_home/submission"

  if member(['development', 'test'], $rails_env) {
    $bundle_opts = "--jobs 2"
  } else {
    $bundle_opts = "--binstubs --path vendor/bundle --jobs 2 --without development test >> /home/${run_as_user}/bundle.log 2>&1"
  }

  anchor { 'profiles::submission::begin': } ->

  exec {"run bundle ${submission_app_home}":
    command     => "${ruby_home_path}/bundle install ${bundle_opts}",
    cwd         => $submission_app_home,
    path        => [$ruby_home_path, $path, "${path}:/bin:/usr/bin"],
    user        => $run_as_user,
    group       => $run_as_user,
    timeout     => 0,
  } ->

  rake::run { 'submission db install':
    tasks             => "db:create db:migrate test:data:users log:clear",
    only              => ['development', 'test'],
    working_directory => $submission_app_home ,
    ruby_home_path    => $ruby_home_path,
    run_as_user       => $run_as_user,
    rails_env         => $rails_env,
  } ->

  rake::run { 'submission tmp create':
    tasks             => "tmp:clear tmp:create",
    working_directory => $submission_app_home ,
    ruby_home_path    => $ruby_home_path,
    run_as_user       => $run_as_user,
    rails_env         => $rails_env,
    notify            => [Service['puma-manager'], Service['sidekiq-manager']],
  } ->

  puma::app { "install_app ${submission_app_home}":
    run_as_user      => $run_as_user,
    app_path         => $submission_app_home,
    port             => $submission_port,
    control_app_port => $control_app_port,
    ruby_home_path   => $ruby_home_path,
  } ->

  sidekiq::app { "install_sidekiq ${submission_app_home}":
    run_as_user    => $run_as_user,
    app_path       => $submission_app_home,
    ruby_home_path => $ruby_home_path,
    rails_env      => $rails_env,
  } ->

  anchor { 'profiles::submission::end': }

  nginx::resource::upstream { 'submission_rake_app':
    members => [
      "127.0.0.1:${submission_port}",
    ],
    require => Class['concat::setup'],
  }

  $listen_options = $rails_env ? {
    /(candidate|production)/ => 'proxy_protocol',
    default => '',
  }

  $vhost_cfg_prepend = $rails_env ? {
    /(candidate|production)/ =>
       {
        'listen' => '*:443 proxy_protocol',
        'real_ip_header' => 'proxy_protocol',
       },
    default => {},
  }

  $location_custom_script = $rails_env ? {
    /(candidate|production)/ => 'if ($server_port != "443") { rewrite ^(.*) https://$host$1 permanent; }',
    default => '',
  }

  nginx::resource::vhost { 'www.espdev.com':
    ensure      => present,
    www_root    => $base_app_home,
    server_name => ['*.espdev.com', '*.espaws.com', '*.amazonaws.com', 'localhost'],
    try_files   => ['$uri/index.html', '$uri', '@submission_endpoint'],
    listen_options => $listen_options,
    vhost_cfg_prepend => $vhost_cfg_prepend,
    location_custom_script => $location_custom_script,
    index_files => undef,
    require     => Class['concat::setup'],
  }

  $submission_rake_app_config = {
    'proxy_http_version' => '1.1',
    'proxy_set_header'   => ['X-Forwarded-For $proxy_protocol_addr', 'Host $http_host', 'Upgrade $http_upgrade', 'Connection $connection_upgrade'],
    'proxy_redirect'   => 'off',
  }

  nginx::resource::location { 'submission_upstream':
    ensure               => present,
    location             => '@submission_endpoint',
    proxy                => 'http://submission_rake_app',
    location_cfg_prepend => $submission_rake_app_config,
    vhost                => 'www.espdev.com',
    require              => Class['concat::setup'],
  }

  if member(['development', 'candidate', 'test'], $rails_env) {
    $registration_proxy_config = {
      'proxy_http_version' => '1.1',
      'proxy_set_header'   => ['X-Real-IP $remote_addr', 'Host $host'],
    }

    nginx::resource::location { 'registration_proxy_register':
      ensure               => present,
      location             => '/register',
      proxy                => 'http://10.200.225.17',
      location_cfg_prepend => $registration_proxy_config,
      vhost                => 'www.espdev.com',
      require              => Class['concat::setup'],
    }

    nginx::resource::location { 'registration_proxy_sign-in':
      ensure               => present,
      location             => '/sign-in',
      proxy                => 'http://10.200.225.17',
      location_cfg_prepend => $registration_proxy_config,
      vhost                => 'www.espdev.com',
      require              => Class['concat::setup'],
    }
  }

  # The following lines are saying the same thing
  # <% unless ['development', 'test'].include?(rails_env) %>
  unless member(['development', 'test'], $rails_env) {

    $assets_config = {
      'gzip_static' => 'on',
    }

    nginx::resource::location { 'submission assets':
      ensure               => present,
      location             => '^~ /assets/',
      www_root             => "${submission_app_home}/public",
      location_cfg_prepend => $assets_config,
      vhost                => 'www.espdev.com',
      require              => Class['concat::setup'],
    }

    nginx::resource::location { 'submission javascripts':
      ensure               => present,
      location             => '^~ /javascripts/',
      www_root             => "${submission_app_home}/public",
      index_files          => undef,
      location_cfg_prepend => $assets_config,
      vhost                => 'www.espdev.com',
      require              => Class['concat::setup'],
    }

    nginx::resource::location { 'submission stylesheets':
      ensure               => present,
      location             => '^~ /stylesheets/',
      www_root             => "${submission_app_home}/public",
      location_cfg_prepend => $assets_config,
      vhost                => 'www.espdev.com',
      require              => Class['concat::setup'],
    }
  }

}
