# config valid for current version and patch releases of Capistrano
lock "~> 3.10.2"

set :application, "rails52_rpush"
set :repo_url, "git@github.com:kntmrkm/rails52-rpush.git"

set :log_level, :debug

set :pty, false
set :use_sudo, false
set :deploy_via, :remote_cache
set :deploy_to, '/deploy'

set :linked_files, %w{.env config/master.key db/production.sqlite3}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets tmp/sessions bundle}
set :keep_releases, 5
set :conditionally_migrate, true

namespace :deploy do
  desc 'Upload config files'
  task :upload do
    on roles(:app) do |host|
      if test "[ ! -d #{shared_path}/config ]"
        execute "mkdir -p #{shared_path}/config"
      end

      upload!('.env', "#{shared_path}/.env")
      upload!('config/master.key', "#{shared_path}/config/master.key")
    end
  end
end

namespace :rpush do
  desc 'Rpush'
  task :start do
    on roles(:push) do
      # bundle exec rpush start -p /deploy/shared/tmp/pids/rpush.pid -c /deploy/shared/config/rpush.rb -e production
      #execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} bundle exec rpush start -p #{shared_path}/tmp/pids/rpush.pid -c #{shared_path}/rpush.rb -e #{fetch(:rails_env)}"
      #execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} bundle exec rpush stop -e #{fetch(:rails_env)}"
      #execute "cd #{current_path} && RAILS_ENV=#{fetch(:rails_env)} bundle exec rpush start -e #{fetch(:rails_env)}"

      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "rpush start -f -c config/initializers/rpush.rb -e #{fetch(:rails_env)}"
        end
      end
    end
  end
end

before :deploy,   'deploy:upload'
after  :deploy,    'rpush:start'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
