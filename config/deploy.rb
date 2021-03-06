set :application, "helpy"
set :repo_url, "git@github.com:opula/helpy.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/var/www/helpy"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5


namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke 'docker:restart'
  end
end

after  'deploy:publishing', 'deploy:restart'

namespace :docker do
  desc 'Restart container'
  task :restart do
    on roles(:app) do
      within release_path do
        # execute :rm, "config/database.yml"
        # execute :cp, "config/database.yml.docker config/database.yml"

        execute :sudo, "chown -R deploy:deploy /var/www"
        # execute :sudo, "docker restart helpy"
      end
    end
  end
end
