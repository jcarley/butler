define puma::app(
  $app_path          = "",
  $run_as_user       = "",
  $config_file_path  = "",
  $ensure            = "present",
  $port              = "",
  $control_app_port  = "",
  $ruby_home_path    = "/home/${run_as_user}/.rbenv/shims",
  $rails_env         = $rails_environment,
) {

  contain puma::service

  # example result
  # app_path = "/home/vagrant/apps/submission" + "/tmp/pids/puma"
  $puma_tmp_root = "/tmp/pids/puma"
  $puma_tmp = "${app_path}${puma_tmp_root}"

  notice($puma_tmp)

  $uid = $run_as_user

  if $config_file_path == "" {
    $config_file = "${app_path}/config/puma.rb"

    file { "${app_path}/config":
      ensure => directory,
    }

    file { $config_file:
      content => template('puma/puma_config.erb'),
      ensure  => present,
      notify  => Service['puma-manager'],
    }

  } else {
    $config_file = $config_file_path
  }

  if $ensure == "present" {
    line { "puma add-app ${app_path}":
      file    => "/etc/puma.conf",
      line    => $app_path,
      require => File[$config_file],
      notify  => Service['puma-manager'],
    }

  } else {
    line { "puma remove-app ${app_path}":
      file    => "/etc/puma.conf",
      line    => $app_path,
      require => File[$config_file],
      notify  => Service['puma-manager'],
    }
  }

}
