require 'spec_helper'

describe 'unicorn' do
  before do
    mock_config { use_recipes :unicorn }
  end
  
  it 'returns used recipe' do
    config.used_recipes.should == [:unicorn]
  end

  it 'has default unicorn pid' do
    mock_config { set :deploy_to, '/foo/bar' }
    config.unicorn_pid_file.should == '/foo/bar/shared/pids/unicorn.pid'
  end
end