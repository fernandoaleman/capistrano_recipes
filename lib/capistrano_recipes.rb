require 'capistrano'

module CapistranoRecipes
  def self.load_into(configuration)
      configuration.load('deploy')

      configuration.load do
        _cset :shared_children, %w(public/system log tmp/pids tmp/sockets)
        _cset(:domain) { abort "Please specify domain, set :domain, 'domain.com'"}
        _cset :config_dir, 'config'
        _cset :config_path, lambda { File.join shared_path, config_dir }
        _cset :backup_dir, 'backup'
        _cset :backup_path, lambda { File.join shared_path, backup_dir }
        _cset :log_path, lambda { File.join shared_path, 'log' }
        _cset :pids_path, lambda { File.join shared_path, 'pids' }
        _cset :sockets_path, lambda { File.join shared_path, 'sockets' }

        set :user, 'deployer'

        @used_recipes = []

        class << self
          attr_reader :used_recipes
        end

        def use_recipe(recipe_name)
          return if @used_recipes.include?(recipe_name.to_sym)

          begin
            require "capistrano/recipes/#{recipe_name}"

            const_recipe = CapistranoRecipes.const_get(recipe_name.to_s.capitalize.gsub(/_(\w)/) { $1.upcase })
            const_recipe.load_into(self)
            @used_recipes << recipe_name.to_s.downcase.to_sym
          rescue LoadError
            abort "Did you misspell `#{recipe_name}` recipe name?"
          end
        end

        def use_recipes(*recipes)
          recipes.each do |recipe|
            use_recipe(recipe)
          end
        end

        def using_recipe?(recipe)
          used_recipes.include?(recipe.to_sym)
        end

        def upload_template(local_file, remote_file, permissions = nil)
          temp_file = "/tmp/#{File.basename(remote_file)}"
          template  = parse_template(local_file)
          put template, temp_file
          run "chmod #{permissions} #{temp_file}" unless permissions.nil?
          run "#{sudo} mv #{temp_file} #{remote_file}"
        end

        def templates_path
          expanded_path_for('capistrano/recipes/templates')
        end

        def expanded_path_for(path)
          e = File.join(File.dirname(__FILE__), path)
          File.expand_path(e)
        end

        def parse_template(file)
          require 'erb'
          template = File.read(file)
          return ERB.new(template, nil, '<>').result(binding)
        end

        def ask(question)
          q = "\n#{question} : "
          Capistrano::CLI.ui.ask(q)
        end

        def agree?(question)
          q = "\n#{question} : "
          Capistrano::CLI.ui.agree(q)
        end

        def password_prompt(prompt)
          p = "\n#{prompt} : "
          Capistrano::CLI.password_prompt(p)
        end

        def say(message)
          m = "\n#{message}"
          Capistrano::CLI.ui.say(m)
        end

        namespace :deploy do
          desc 'Deploy application'
          task :default do
            update
            restart
          end

          desc 'Setup servers for deployment'
          task :setup, :except => { :no_release => true } do
            dirs = [deploy_to, releases_path, shared_path, config_path, backup_path, pids_path, sockets_path]
            dirs += shared_children.map { |d| File.join(shared_path, d.split('/').last) }
            run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
            run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
          end

          task :restart do
            # nothing
            # if task is not being used, it will not appear in `cap -T`
          end

          task :start do
            # nothing
            # if task is not being used, it will not appear in `cap -T`
          end

          task :stop do
            # nothing
            # if task is not being used, it will not appear in `cap -T`
          end
        end
      end
    end
  end

  if Capistrano::Configuration.instance
    CapistranoRecipes.load_into(Capistrano::Configuration.instance)
  end