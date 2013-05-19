module CapistranoRecipes
  module Mysql
    def self.load_into(configuration)
      configuration.load do
        # MySQL admin user with access to create databases and grant permissions
        _cset :mysql_admin_user, lambda { ask "Enter #{rails_env} database username with access to create database" }

        # Application database adapter
        _cset :mysql_adapter, lambda { 'mysql2' }
        
        # Application database name
        _cset :mysql_database, lambda { "#{application}_#{rails_env}" }
        
        # Application database user
        _cset :mysql_user, lambda { ask "Enter #{rails_env} database username" }

        # Application database password
        _cset(:mysql_password) { password_prompt "Enter #{rails_env} database password" }

        # Application database host
        _cset :mysql_host, lambda { 'localhost' }

        # Application database encoding
        _cset :mysql_encoding, lambda { 'utf8' }

        # Path to local database config template
        _cset :mysql_local_config_template, lambda { "#{templates_path}/mysql.yml.erb" }

        # Path to remote database config file
        _cset :mysql_remote_config_file, lambda { "#{config_path}/database.yml" }

        # Application database backup file
        _cset :mysql_backup_file, lambda { "#{application}-backup.sql.bz2" }

        # Path to local database backup file
        _cset :mysql_local_backup_file, lambda { "tmp/#{mysql_backup_file}" }

        # Path to remote database backup file
        _cset :mysql_remote_backup_file, lambda { "#{backup_path}/#{mysql_backup_file}" }

        namespace :mysql do
          desc 'Generate the database.yml configuration file'
          task :setup, :roles => :app, :except => { :no_release => true } do
            upload_template mysql_local_config_template, mysql_remote_config_file
          end
          after 'deploy:setup' do
            mysql.setup if agree? 'Setup database.yml?'
            mysql.create if agree? 'Create database?'
          end

          desc 'Create mysql database'
          task :create, :roles => :db, :only => { :primary => true } do
            sql = <<-SQL.gsub(/^ {14}/, '')
              "CREATE DATABASE #{mysql_database};
              GRANT ALL PRIVILEGES ON #{mysql_database}.* TO #{mysql_user}@localhost IDENTIFIED BY '#{mysql_password}';"
            SQL

            mysql_admin = mysql_admin_user

            run "mysql --user=#{mysql_user} -p --execute=#{sql}" do |channel, stream, data|
              if data =~ /^Enter password:/
                pass = password_prompt "Enter database password for '#{mysql_admin}'"
                channel.send_data "#{pass}\n"
              end
            end
          end

          desc 'Symlink the database.yml file into the latest deploy'
          task :symlink, :roles => :app, :except => { :no_release => true } do
            run "ln -nfs #{mysql_remote_config} #{release_path}/config/database.yml"
          end
          after 'deploy:finalize_update', 'mysql:symlink'

          desc 'Populate the database with seed data'
          task :seed do
            run "cd #{current_path} && #{rake} RAILS_ENV=#{rails_env} db:seed"
          end
          after 'deploy:cold' do
            mysql.seed if agree? 'Load seed data into database?'
          end

          desc 'Performs a mysqldump of the database'
          task :dump, :roles => :db, :only => { :primary => true } do
            prepare_from_yaml

            run "mysqldump --user=#{db_user} -p --host=#{db_host} #{db_name} | bzip2 -z9 > #{mysql_remote_backup_file}" do |channel, stream, out|
            channel.send_data "#{db_pass}\n" if out =~ /^Enter password:/
              puts out
            end
          end

          desc "Download compressed database dump"
          task :fetch_dump, :roles => :db, :only => { :primary => true } do
            download mysql_remote_backup_file, mysql_local_backup_file, :via => :scp
          end

          desc "Restore the database from the latest compressed dump"
          task :restore, :roles => :db, :only => { :primary => true } do
            prepare_from_yaml

            run "bzcat #{mysql_remote_backup_file} | mysql --user=#{db_user} -p --host=#{db_host} #{db_name}" do |channel, stream, out|
            channel.send_data "#{db_pass}\n" if out =~ /^Enter password:/
              puts out
            end if agree? 'Are you sure you want to restore your database?'
          end

          %w[start stop restart status].each do |command|
            desc "#{command.capitalize} mysql"
            task command, :roles => :db, :only => { :primary => true } do
              run "#{sudo} service mysqld #{command}"
            end
          end
        end

        def prepare_from_yaml
          set(:db_user) { db_config[rails_env]["username"] }
          set(:db_pass) { db_config[rails_env]["password"] }
          set(:db_host) { db_config[rails_env]["host"] }
          set(:db_name) { db_config[rails_env]["database"] }
        end
        
        def db_config
          @db_config ||= fetch_db_config
        end
        
        def fetch_db_config
          require 'yaml'
          file = capture "cat #{mysql_remote_config_file}"
          db_config = YAML.load(file)
        end
      end
    end
  end
end
