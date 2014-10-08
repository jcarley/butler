class roles::www::webapp(
  $run_as_user,
  $ruby_home_path = "/home/${run_as_user}/.rbenv/shims",
  $application_name,
  $virtual_host,
  $base_app_home,
  $server_name = ['localhost'],
  $rails_env = 'development',
  $vhost_template = 'nginx/vhost.erb'
) {

  $upstream_port = 9292
  $control_app_port = 6464
  $application_home = "$base_app_home/$application_name"

  if member(['development', 'test'], $rails_env) {
    $bundle_opts = "--jobs 2"
  } else {
    $bundle_opts = "--binstubs --path vendor/bundle --jobs 2 --without development test >> /home/${run_as_user}/bundle.log 2>&1"
  }

  anchor { 'roles::www::webapp::begin': } ->

  exec {"run bundle ${$application_home}":
    command     => "${ruby_home_path}/bundle install ${bundle_opts}",
    cwd         => $application_home,
    path        => [$ruby_home_path, $path, "${path}:/bin:/usr/bin"],
    user        => $run_as_user,
    group       => $run_as_user,
    timeout     => 0,
  } ->

  rake::run { 'submission tmp create':
    tasks             => "tmp:clear tmp:create",
    working_directory => $submission_app_home ,
    ruby_home_path    => $ruby_home_path,
    run_as_user       => $run_as_user,
    rails_env         => $rails_env,
    notify            => [Service['puma-manager'], Service['sidekiq-manager']],
  } ->

  puma::app { "install_app ${$application_home}":
    run_as_user      => $run_as_user,
    app_path         => $application_home,
    port             => $upstream_port,
    control_app_port => $control_app_port,
    ruby_home_path   => $ruby_home_path,
  } ->


  anchor { 'roles::www::webapp::end': }

  nginx::resource::upstream { "${application_name}_rack_app":
    ensure  => present,
    members => [
      "127.0.0.1:${upstream_port}",
    ],
  }

  nginx::resource::vhost { $virtual_host:
    ensure      => present,
    www_root    => $base_app_home,
    server_name => $server_name,
    try_files   => ['$uri/index.html', '$uri', "@${application_name}_endpoint"],
    index_files => undef,
  }

  $rack_app_config = {
    ''                 => 'proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto; proxy_set_header Host $http_host',
    'proxy_redirect'   => 'off',
  }

  nginx::resource::location { "${application_name}_upstream":
    ensure               => present,
    location             => "@${application_name}_endpoint",
    proxy                => "http://${application_name}_rack_app",
    location_cfg_prepend => $rack_app_config,
    vhost                => $virtual_host,
  }

  # The following lines are saying the same thing
  # <% unless ['development', 'test'].include?(rails_env) %>
  # unless member(['development', 'test'], $rails_env) {

    # $assets_config = {
      # 'gzip_static' => 'on',
    # }

    # nginx::resource::location { 'assets':
      # ensure               => present,
      # location             => '^~ /assets/',
      # www_root             => "${submission_app_home}/public",
      # location_cfg_prepend => $assets_config,
      # vhost                => 'www.espdev.com',
    # }

    # nginx::resource::location { 'javascripts':
      # ensure               => present,
      # location             => '^~ /javascripts/',
      # www_root             => "${submission_app_home}/public",
      # index_files          => undef,
      # location_cfg_prepend => $assets_config,
      # vhost                => 'www.espdev.com',
    # }

    # nginx::resource::location { 'stylesheets':
      # ensure               => present,
      # location             => '^~ /stylesheets/',
      # www_root             => "${submission_app_home}/public",
      # location_cfg_prepend => $assets_config,
      # vhost                => 'www.espdev.com',
    # }
  # }

}
