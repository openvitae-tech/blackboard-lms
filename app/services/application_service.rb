# WORKAROUND:
# Adding to autoload_paths or eager_load_paths in application.rb didn't work as expected
# therefore doing this workaround. All the service modules will be loaded from application_service.rb
#
# modules related to user management
require_relative 'user_management/roles'