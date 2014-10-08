class rake::precompile_assets(
  $working_directory,
  $ruby_home_path,
  $run_as_user
) {

  exec {"RAILS_ENV=production ${working_directory} assets:clean assets:precompile:all":
    command     => "${ruby_home_path}/rake assets:clean assets:precompile:all",
    path        => ["${ruby_home_path}", "/usr/local/bin", "/usr/local/sbin", $path],
    cwd         => $working_directory,
    environment => ['RAILS_ENV=production', "HOME=/home/${run_as_user}"],
    timeout     => 0,
    user        => $run_as_user,
    group       => $run_as_user
  }
}

define rake::run (
  $tasks = "",
  $except = undef,
  $only = undef,
  $working_directory,
  $ruby_home_path,
  $run_as_user,
  $rails_env = $rails_environment,
) {

  if is_array($tasks) {
    $task_list = join($tasks, " ")
  } else {
    $task_list = $tasks
  }

  if $except != undef {
    validate_array($except)
    $test_condition = $rails_env
    $members = $except
    $ok_to_run = !member($members, $test_condition)
  } elsif $only != undef {
    validate_array($only)
    $test_condition = $rails_env
    $members = $only
    $ok_to_run = member($members, $test_condition)
  } else {
    $ok_to_run = true
  }

  if $ok_to_run {
    exec {"${working_directory} ${task_list}":
      command     => "${ruby_home_path}/bundle exec rake ${task_list}",
      path        => ["${ruby_home_path}", "/usr/local/bin", "/usr/local/sbin", "/usr/sbin", "/usr/bin", "/sbin", "/bin"],
      cwd         => $working_directory,
      environment => ["RAILS_ENV=${rails_env}", "HOME=/home/${run_as_user}"],
      timeout     => 0,
      user        => $run_as_user,
      group       => $run_as_user,
    }
  }
}
