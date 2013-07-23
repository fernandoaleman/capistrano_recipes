module CapistranoRecipes
  module Nginx
    def self.load_into(configuration)
      configuration.load do
        # Nginx path on server
        _cset :nginx_path, '/etc/nginx'

        # Nginx http port
        _cset :nginx_port, '80'

        # Path to local nginx vhost template
        _cset(:nginx_local_site_available_template) { "#{templates_path}/nginx.vhost.erb" }

        # Path to remote sites-available location
        _cset :nginx_remote_site_available_file, lambda { "#{nginx_path}/sites-available/#{application}" }

        # Path to remote sites-enabled location
        _cset :nginx_remote_site_enabled_link, lambda { "#{nginx_path}/sites-enabled/#{application}" }

        # Whether or not to use ssl
        _cset :use_ssl, false

        # Nginx https port
        _cset :nginx_ssl_port, '443'

        # Nginx ssl directory on server
        _cset :nginx_ssl_dir, 'ssl'

        # Nginx ssl path on server
        _cset :nginx_ssl_path, lambda { File.join nginx_path, nginx_ssl_dir }

        # Nginx ssl certificates directory on server
        _cset :nginx_ssl_certs_dir, 'certs'

        # Nginx ssl private keys directory on server
        _cset :nginx_ssl_private_dir, 'private'

        # Nginx ssl certificates path on server
        _cset :nginx_ssl_certs_path, lambda { File.join nginx_ssl_path, nginx_ssl_certs_dir }

        # Nginx ssl private keys path on server
        _cset :nginx_ssl_private_path, lambda { File.join nginx_ssl_path, nginx_ssl_private_dir }

        # Nginx ssl certificate file
        _cset :nginx_ssl_cert, lambda { "#{application}.crt" }

        # Nginx ssl key file
        _cset :nginx_ssl_key, lambda { "#{application}.key" }
        
        # Whether or not to use auth basic
        _cset :use_auth_basic, false
        
        # Nginx auth basic username
        _cset :nginx_auth_basic_username, lambda { ask "Enter #{rails_env} auth basic username " }
        
        # Nginx auth basic password
        _cset :nginx_auth_basic_password, lambda { password_prompt "Enter #{rails_env} auth basic password " }
        
        # Nginx htpasswd path on server
        _cset :nginx_htpasswd_path, lambda{ "#{shared_path}/htpasswd" }
        
        # Nginx htpasswd file on server
        _cset :nginx_htpasswd_file, lambda{ File.join nginx_htpasswd_path, "htpasswd" }

        def using_ssl?
          fetch(:use_ssl)
        end
        
        def using_auth_basic?
          fetch(:use_auth_basic)
        end

        namespace :nginx do
          desc 'Add HTTP Basic Authentication'
          task :auth_basic, :roles => :web, :except => { :no_release => true } do
            htpasswd = "#{nginx_auth_basic_username}:#{%Q{#{nginx_auth_basic_password}}.crypt(%Q{#{application}})}"
            commands = []
            commands << "mkdir -p #{nginx_htpasswd_path}"
            commands << "if (test -f #{nginx_htpasswd_file}); then #{sudo} mv #{nginx_htpasswd_file} /tmp/htpasswd; fi"
            commands << "echo '#{htpasswd}' >> /tmp/htpasswd"
            commands << "#{sudo} mv /tmp/htpasswd #{nginx_htpasswd_file}"

            run commands.join(" && ")
          end
          
          desc 'Create and upload nginx vhost'
          task :setup, :roles => :web, :except => { :no_release => true } do
            auth_basic if using_auth_basic?
            upload_template nginx_local_site_available_template, nginx_remote_site_available_file
            run "#{sudo} ln -nfs #{nginx_remote_site_available_file} #{nginx_remote_site_enabled_link}"
            restart
          end
          after 'deploy:setup' do
            nginx.setup if agree?("Create and upload nginx vhost for #{application}?")
          end

          %w[start stop restart status].each do |command|
            desc "#{command.capitalize} nginx"
            task command, :roles => :app, :except => { :no_release => true } do
              run "#{sudo} service nginx #{command}"
            end
          end
        end
      end
    end
  end
end
