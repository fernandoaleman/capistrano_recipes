# 1.0.5 - May 21, 2013
- Added remote_directory_exists? and remote_file_exists? methods
- Fixed bug to check if git repo already exists during setup in git recipe

# 1.0.4 - May 21, 2013
- Fixed bug when creating database in mysql recipe
- Fixed bug when creating database name in mysql.yml.erb template

# 1.0.3 - May 20, 2013
- Fixed bug to set shared_children in Proc
- Added start to cold task in git recipe

# 1.0.2 - May 19, 2013
- Fixed bug in git recipe to go to current_path instead of deploy_to path
- Updated git spec test
- Fixed syntax in mysql recipe
- Added creating pids_path and sockets_path on setup
- Fixed syntax in nginx.vhost.erb template
- Fixed bug in use_recipe
- Fixed bug when naming recipes with underscore

# 1.0.1 - May 19, 2013
- Fixed syntax in nginx.vhost.erb template

# 1.0.0 - May 18, 2013
- Initial release