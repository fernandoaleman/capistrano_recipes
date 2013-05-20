require 'spec_helper'

describe 'assets' do
  before do
    mock_config do
      use_recipe :assets
      set :application, 'foo'
      set :deploy_to, '/foo/bar'
      set :latest_release, deploy_to
      set :use_sudo, false
    end
  end

  describe 'deploy:assets:precompile' do
    it 'runs precompile' do
      cli_execute 'deploy:assets:precompile'
      config.should have_run('[ -e /foo/bar/shared/assets/manifest* ] && cat /foo/bar/shared/assets/manifest* || echo')
      config.should have_run(' cd -- /foo/bar && rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile ')
      config.should have_run('ls -1 /foo/bar/shared/assets/manifest* | wc -l')
      config.should have_run('ls /foo/bar/shared/assets/manifest*')
      config.should have_run(" cp -- '' ''/assets_manifest ")
    end
  
    it 'uses bundle command' do
      mock_config { use_recipe :bundle }
      cli_execute 'deploy:assets:precompile'
      config.should have_run(' cd -- /foo/bar && bundle exec rake RAILS_ENV=production RAILS_GROUPS=assets assets:precompile ')
    end
  end

  describe 'deploy:assets:clean' do
    it 'runs clean' do
      cli_execute 'deploy:assets:clean'
      config.should have_run('cd /foo/bar && rake RAILS_ENV=production RAILS_GROUPS=assets assets:clean')
    end
  end
end