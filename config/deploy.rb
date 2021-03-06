# config valid only for current version of Capistrano
lock '3.4.0'
server '206.128.156.201', port: 22, roles: [:web, :app, :db], primary: true

set :application,     'bare_metal'
set :repo_url,        'git@github.com:sitepoint-editors/bare-metal-fun.git'

set :user,            'deploy'
set :puma_threads,    [4, 16]
set :puma_workers,    0


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to,     "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :use_sudo,      false
set :deploy_via,    :remote_cache

# Puma
set :puma_bind,       "unix://#{shared_path}/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord
set :ssh_options,     { forward_agent: true, user: fetch(:user) }

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases,   5

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc "Link shared files"
  task :symlink_config_files do
    on roles(:web) do
      symlinks = {
        #"#{shared_path}/config/database.yml" => "#{release_path}/config/database.yml",
        "#{shared_path}/config/secrets.yml" => "#{release_path}/config/secrets.yml"
      }
      execute symlinks.map{|from, to| "ln -nfs #{from} #{to}"}.join(" && ")
    end
  end

  before 'deploy:assets:precompile', :symlink_config_files
end
