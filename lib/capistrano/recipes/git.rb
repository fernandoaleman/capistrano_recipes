module CapistranoRecipes
  module Git
    def self.load_into(configuration)
      configuration.load do
        default_run_options[:pty]   = true
        ssh_options[:forward_agent] = true

        set(:repository)        { abort "Please specify repository, set :repository, 'foo'" }
        
        _cset :branch,          'master'
        _cset :use_sudo,        false
        _cset :check_repo,      true
        
        set :migrate_target,    :current

        set(:latest_release)    { fetch(:current_path) }
        set(:release_path)      { fetch(:current_path) }
        set(:releases_path)     { fetch(:current_path) }
        set(:current_release)   { fetch(:current_path) }
        set(:current_revision)  { capture("cd #{current_path} && git rev-parse --short HEAD").strip }
        set(:latest_revision)   { capture("cd #{current_path} && git rev-parse --short HEAD").strip }
        set(:previous_revision) { capture("cd #{current_path} && git rev-parse --short HEAD@{1}").strip }
        
        set :local_branch do
          `git symbolic-ref HEAD 2> /dev/null`.strip.sub('refs/heads/', '')
        end
        
        after 'deploy:setup' do
          begin
            run "git clone --no-checkout #{repository} #{current_path}"
          rescue
            if agree?("Repo already exists. Destroy and clone again?")
              run "#{try_sudo} rm -rf #{current_path}"
              retry
            end
          end
        end
        
        namespace :deploy do
          desc 'Deploy and start a cold application'
          task :cold do
            update
            migrate
            start
          end

          desc 'Update the deployed code through transaction to rollback if it has errors'
          task :update do
            transaction do
              update_code
            end
          end

          desc 'Update the deployed code'
          task :update_code, :except => { :no_release => true } do
            run "cd #{current_path} && git fetch origin && git reset --hard origin/#{branch}"
            finalize_update
          end
          
          desc 'Run migrations'
          task :migrate, :roles => :db, :only => { :primary => true } do
            run "cd #{current_path} && RAILS_ENV=#{rails_env} #{rake} db:migrate"
          end

          desc 'Deploy and run migrations'
          task :migrations do
            update
            migrate
            restart
          end

          namespace :rollback do
            desc 'Move repo back to the previous version of HEAD'
            task :repo, :except => { :no_release => true } do
              set :branch, "HEAD@{1}"
              deploy.default
            end

            desc 'Rewrite reflog so HEAD@{1} will continue to point to the next previous release'
            task :cleanup, :except => { :no_release => true } do
              run "cd #{current_path}; git reflog delete --rewrite HEAD@{1}; git reflog delete --rewrite HEAD@{1}"
            end

            desc 'Roll back to the previously deployed version'
            task :default do
              rollback.repo
              rollback.cleanup
            end
          end

          namespace :pending do
            task :diff, :except => { :no_release => true } do
              # nothing
            end

            desc 'Show pending commits'
            task :default do
              system("git log --pretty=medium --stat #{current_revision}..origin/#{branch}")
            end
          end

          desc 'Check that local git repo is in sync with remote'
          task :check_repo do
            unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
              puts "WARNING: HEAD is not the same as origin/#{branch}"
              puts "Run `git push origin #{branch}` to sync changes."
              exit
            end if fetch(:check_repo)
          end
          %w[deploy deploy:cold deploy:migrations].each do |task|
            before "#{task}", "deploy:check_repo"
          end
          
          task :symlink do
            # nothing
            # if task is not being used, it will not appear in `cap -T`
          end
          
          task :create_symlink do
            # nothing
            # if task is not being used, it will not appear in `cap -T`
          end
        end
      end
    end
  end
end