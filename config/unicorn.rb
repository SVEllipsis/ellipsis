@dir = "/home/pi/ellipsis/"

worker_processes 2
working_directory @dir
timeout 30
preload_app true

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
listen "/tmp/sockets/unicorn.sock", :backlog => 64

# Set process id path
pid "/tmp/pids/unicorn.pid"

# Set log file paths
stderr_path "/var/log/unicorn.stderr.log"
stdout_path "/var/log/unicorn.stdout.log"
