require 'spec_helper'

describe 'nginx' do

  before do
    mock_config do
      use_recipe :nginx
      set :application, 'foo'
      set :deploy_to, '/foo/bar'
    end
  end

  it 'returns used recipe' do
    config.used_recipes.should == [:nginx]
  end
end