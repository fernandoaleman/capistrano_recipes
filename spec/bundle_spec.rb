require 'spec_helper'

describe 'bundle' do

  before do
    mock_config do
      use_recipes :bundle
      set :deploy_to, '/foo/bar'
    end
  end

  it 'returns used recipe' do
    config.used_recipes.should == [:bundle]
  end
end