module CapistranoRecipes
  module Unicorn
    def self.load_into(configuration)
      configuration.load do
        # Start workers with this user
        _cset :unicorn_user, lambda { user }

        # Number of unicorn workers
        _cset :unicorn_workers, lambda { 2 }

        # Unicorn workers timeout in seconds
        _cset :unicorn_workers_timeout, lambda { 15 }

        # Unicorn config template
        _cset :unicorn_config_template, lambda { File.join templates_path, 'unicorn.rb.erb' }

        # Unicorn config file
        _cset :unicorn_config_file, lambda { File.join config_path, 'unicorn.rb' }

        # Whether or not to use unicorn init to start on reboot
        _cset :use_unicorn_init, lambda { true }

        # Unicorn init template
        _cset :unicorn_init_template, lambda { File.join templates_path, 'unicorn_init.erb' }

        # Unicorn init file
        _cset :unicorn_init_file, lambda { "/etc/init.d/unicorn-#{application}" }

        # Unicorn pid file
        _cset :unicorn_pid_file, lambda { File.join pids_path, 'unicorn.pid' }

        # Unicorn log file
        _cset :unicorn_log_file, lambda { File.join log_path, 'unicorn.log' }

        # Unicorn socket file
        _cset :unicorn_socket_file, lambda { File.join sockets_path, 'unicorn.sock' }

        # Unicofn command
        _cset :unicorn_command, lambda { using_recipe?(:bundle) ? 'bundle exec unicorn' : 'unicorn' }

        def using_unicorn_init?
          fetch(:use_unicorn_init)
        end

        namespace :unicorn do
          desc 'Setup unicorn'
          task :setup, :roles => :app, :except => { :no_release => true } do
            run "rm -f #{unicorn_socket_file}"
            upload_template unicorn_config_template, unicorn_config_file

            if using_unicorn_init?
              upload_template unicorn_init_template, unicorn_init_file, '+x'
              run "#{sudo} chkconfig --levels 235 unicorn-#{application} on"
            end
          end
          after 'deploy:setup' do
            unicorn.setup if agree? "Create and upload unicorn config for #{application}?"
          end

          %w[start stop restart].each do |command|
            desc "#{command.capitalize} unicorn"
            task command, :roles => :app, :except => { :no_release => true } do
              run "#{unicorn_init_file} #{command}"
            end
            after "deploy:#{command}", "unicorn:#{command}"
          end
        end
      end
    end
  end
end