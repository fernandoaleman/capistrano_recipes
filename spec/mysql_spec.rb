require 'spec_helper'

describe 'mysql' do

  before do
    mock_config do
      use_recipe :mysql
    end
  end

  it 'returns used recipe' do
    config.used_recipes.should == [:mysql]
  end
end