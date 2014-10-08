pidfile "tmp/pids/butler.pid"
state_path "tmp/pids/butler.state"
bind 'tcp://127.0.0.1:9292'
activate_control_app

threads 3, 10
