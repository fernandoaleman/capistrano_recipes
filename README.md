# Capistrano Recipes [![Build Status](https://travis-ci.org/fernandoaleman/capistrano_recipes.png?branch=master)](https://travis-ci.org/fernandoaleman/capistrano_recipes) [![Dependency Status](https://gemnasium.com/fernandoaleman/capistrano_recipes.png)](https://gemnasium.com/fernandoaleman/capistrano_recipes)

Powerful capistrano recipes to make your rails deployments fast and easy.

## Quickstart Guide

Create a file called 'Capfile' in your application's root directory.

For a single environment add:

```ruby
require 'capistrano/recipes'

use_recipes :bundler, :git, :rails_assets

server 'Add your web server domain or ip here', :app, :web, :db, :primary => true

set :application, "Set application name here"
set :deploy_to,   "/path/to/your/app/here"
set :repository,  "Set repository location here"
set :domain,      "Set domain name here"
```

For a multistage environment add:

```ruby
require 'capistrano/recipes'

use_recipes :bundler, :git, :multistage, :rails_assets

stage :staging, :branch => :dev, :default => true do
  server 'Add your web server domain or ip here', :app, :web, :db, :primary => true
end

stage :production, :branch => :master do
  server 'Add your web server domain or ip here', :app, :web, :db, :primary => true
end

set :application, "Set application name here"
set :deploy_to,   "/path/to/your/app/here"
set :repository,  "Set repository location here"
set :domain,      "Set domain name here"
```

To add a single recipe:
```ruby
use_recipe :bundle
```

To add multiple recipes:
```ruby
use_recipes :bundle, :git, :multistage, :rails_assets
```

## Recipes
| Recipe        | Documentation |
| ------------  | ------------- |
| :bundle       | [Bundle recipe documentation](https://github.com/fernandoaleman/capistrano_recipes/wiki/Bundle) |
| :git          | [Git recipe documentation](https://github.com/fernandoaleman/capistrano_recipes/wiki/Git) |
| :multistage   | [Multistage recipe documentation](https://github.com/fernandoaleman/capistrano_recipes/wiki/Multistage) |
| :rails_assets | [Rails assets recipe documentation](https://github.com/fernandoaleman/capistrano_recipes/wiki/Rails-Assets) |

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano_recipes'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano_recipes

## Documentation
For more detailed information, visit the [wiki](https://github.com/fernandoaleman/capistrano_recipes/wiki).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
