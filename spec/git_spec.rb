require 'spec_helper'

describe 'git' do
  before do
    mock_config do
      use_recipe :git
      set :deploy_to, '/foo/bar'
      def finalize_update; return; end;
    end
  end

  it 'has branch' do
    config.branch.should == 'master'
  end

  context 'with repository' do
    before do
      mock_config { set :repository, 'git@example.com/test-app.git' }
    end

    describe 'deploy:setup' do
      before do
        mock_config do
          set :shared_path, "#{deploy_to}/shared"
          set :shared_children, %w(public/system log tmp/pids)
        end
      end

      it 'clones repository' do
        cli_execute 'deploy:setup'
        config.should have_run('git clone --no-checkout git@example.com/test-app.git /foo/bar/current')
      end
    end

    describe 'deploy:update' do
      it 'updates' do
        cli_execute 'deploy:update'
        config.should have_run('cd /foo/bar/current && git fetch origin && git reset --hard origin/master')
      end
    end
  end

  it 'has current revision' do
    config.should_receive(:capture).with('cd /foo/bar/current && git rev-parse --short HEAD') { "baz\n" }
    config.current_revision.should == 'baz'
  end

  it 'shows pending' do
    config.should_receive(:current_revision) { 'baz' }
    config.namespaces[:deploy].namespaces[:pending].should_receive(:system).with('git log --pretty=medium --stat baz..origin/master')
    cli_execute 'deploy:pending'
  end

  it 'sets forward agent' do
    config.ssh_options[:forward_agent].should == true
  end
end