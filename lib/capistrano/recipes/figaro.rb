module CapistranoRecipes
  module Figaro
    def self.load_into(configuration)
      configuration.load do

        namespace :figaro do
          desc 'Upload application.yml to remote server'
          task :upload, :roles => :app, :except => { :no_release => true } do
            transfer :up, "config/application.yml", "#{config_path}/application.yml", :via => :scp
          end
          before 'deploy:finalize_update' do
            figaro.upload if agree? 'Upload application.yml?'
          end
          after 'deploy:setup' do
            figaro.upload if agree? 'Setup application.yml?'
          end

          desc 'Download application.yml from remote server'
          task :download_application_file, :roles => :app, :except => { :no_release => true } do
            if agree? "Your local config/application.yml file will be overwritten. Continue?"
              download "#{config_path}/application.yml", "config/application.yml", :via => :scp
            end
          end

          desc 'Symlink application.yml to config path'
          task :symlink, :roles => :app, :except => { :no_release => true } do
            run "ln -nfs #{config_path}/application.yml #{release_path}/config/application.yml"
          end
          after 'deploy:finalize_update', 'figaro:symlink'
        end
      end
    end
  end
end
