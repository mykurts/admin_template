require "fileutils"
require "shellwords"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path

  # Get source for template
  require "tmpdir"
  source_paths.unshift(tempdir = Dir.mktmpdir("admin-"))
  at_exit { FileUtils.remove_entry(tempdir) }
  git clone: [
    "--quiet",
    "git@github.com:mykurts/admin_template.git",
    tempdir
  ].map(&:shellescape).join(" ")

  Dir.chdir(tempdir) { git checkout: 'master' }

end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_5?
  Gem::Requirement.new(">= 5.2.0", "< 6.0.0.beta1").satisfied_by? rails_version
end

def rails_6?
  Gem::Requirement.new(">= 6.0.0.alpha", "< 7").satisfied_by? rails_version
end

def rails_7?
  Gem::Requirement.new(">= 7.0.0.alpha", "< 8").satisfied_by? rails_version
end

def master?
  ARGV.include? "--master"
end

def add_sidekiq?
  @sidekiq_add = ask("Do you want to add sidekiq in your application?", :limited_to => ["yes", "no"])
end

def simplified_version
  rails_version.version.split(".").first(2).join('.')
end

def add_gems

  gem 'phonelib'
  gem 'slack-notifier'
  gem 'carrierwave'
  gem 'fog-aws'
  gem 'json-schema'
  gem 'devise_token_auth'
  if rails_7? || master?
    gem "devise", github: "ghiculescu/devise", branch: "patch-2"
  else
    gem 'devise'
  end
  gem 'aes-everywhere'
  if add_sidekiq? == 'yes'
    gem 'sidekiq', '~> 6.2'
  end
  gem 'fcm'

  # Add labels
  inject_into_file "Gemfile", "\n # A simple wrapper for posting to slack channels \n", before: "gem 'slack-notifier'"
  inject_into_file "Gemfile", "\n # Phone validation and formatting using google libphonenumber library data \n", before: "gem 'phonelib'"
  inject_into_file "Gemfile", "\n # File uploads handling \n", before: "gem 'carrierwave'"
  inject_into_file "Gemfile", "\n # Ruby JSON Schema Validator \n", before: "gem 'json-schema'"
  inject_into_file "Gemfile", "\n # Authentication \n", before: "gem 'devise_token_auth'"
  inject_into_file "Gemfile", "\n\n # Encryption", after: "gem 'devise'"
  inject_into_file "Gemfile", "\n\n # other gems", after: "gem 'aes-everywhere'"

  if rails_5?
    gem 'webpacker', '~> 5.3'
  end
end


def add_administrator
 
  generate "devise:install"

  inject_into_file 'config/environments/development.rb',"config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }\n", :before => /^end/
  generate :devise, "account/administrator", "first_name", "last_name"

  if Gem::Requirement.new("> 5.2").satisfied_by? rails_version
    gsub_file "config/initializers/devise.rb", /  # config.secret_key = .+/, "  config.secret_key = Rails.application.credentials.secret_key_base"
  end

  content = <<~RUBY
    \tdef name
        "\#{self.first_name} \#{self.last_name}"
    \tend
  RUBY

  insert_into_file 'app/models/account/administrator.rb',"#{content}", :before => /^end/
  copy_file 'config/routes.rb', force: true

end


def add_webpack
  # Rails 6+ comes with webpacker by default, so we can skip this step
  return if rails_6?

  # Our application layout already includes the javascript_pack_tag,
  # so we don't need to inject it
  rails_command 'webpacker:install'
end

def add_javascript

  content = <<-JS
const webpack = require('webpack')
environment.plugins.append('Provide', new webpack.ProvidePlugin({
  Rails: '@rails/ujs'
}))
  JS

  insert_into_file 'config/webpack/environment.js', content + "\n", before: "module.exports = environment"
end

def add_hotwire
  rails_command "hotwire:install"
end

def copy_templates
  directory 'vendor'
  directory 'app/assets/images'
  directory 'app/assets/stylesheets/admin'
  directory 'app/javascript/packs/admin'

  
  directory 'config/routes'

  directory 'config/database'
  directory 'lib/protocol'

  directory 'app/services'
  directory 'app/controllers/concerns'
  directory 'app/controllers/admin'
  directory 'app/views/admin'
  directory 'app/views/layouts/admin'

  if @sidekiq_add == 'yes'
    copy_file 'config/initializers/sidekiq.rb'
    copy_file 'config/sidekiq.yml'
    directory 'config/sidekiq_service'
  end

  copy_file 'config/initializers/encryption.rb'
  copy_file 'config/initializers/routing_draw.rb'
  copy_file 'config/carrierwave.yml'
  copy_file 'config/configurable.yml'
  copy_file 'app/controllers/api_controller.rb'
  copy_file 'app/controllers/admin_controller.rb'
  copy_file 'app/helpers/application_helper.rb', force: true
  copy_file 'config/initializers/phonelib.rb'
  copy_file 'config/initializers/carrierwave.rb'
  copy_file 'config/initializers/slack_notifier.rb'
  copy_file 'db/seeds.rb', force: true
  
  insert_into_file 'config/initializers/assets.rb', "Rails.application.config.assets.paths << Rails.root.join('vendor', 'metronic')"
  content = <<~RUBY

      \t \tconfig.generators.system_tests = nil

      \t \t# Attach specific database if provided
      \t \tif ENV['RAILS_DATABASE_ENV'].present?
      \t \tend

      \t \tconfig.time_zone = 'Asia/Manila'
      \t \tconfig.action_cable.disable_request_forgery_protection = true

      \t \t# ENV configurables
      \t \tconfig.settings = YAML.load(ERB.new(File.read("\#{Rails.root}/config/configurable.yml")).result).deep_symbolize_keys
      
      \t \t# ENV Carrierwave
      \t \tconfig.carrierwave = YAML.load(ERB.new(File.read("\#{Rails.root}/config/carrierwave.yml")).result).deep_symbolize_keys
      \t \tRails.autoloaders.main.ignore(Rails.root.join('lib/protocol/encrypted_connection.rb'))
  RUBY

  environment 'config.action_cable.allowed_request_origins = [/http:\/\/*/, /https:\/\/*/]', env: 'production'

  insert_into_file "config/application.rb", "\n #{content}\n", after: "config.load_defaults #{simplified_version}"
  insert_into_file "config/application.rb", "\n \t\t" << '  self.paths["config/database"] = "config/database/#{ENV["RAILS_DATABASE_ENV"]}.yml" ', after: "if ENV['RAILS_DATABASE_ENV'].present?"
  if @sidekiq_add == 'yes'
    sidekiq_route = <<~RUBY
      \tauthenticate :administrator do
        \tmount Sidekiq::Web => '/sidekiq'
      \tend
    RUBY
    insert_into_file "config/application.rb", "\n \t\tconfig.active_job.queue_adapter = :sidekiq \n \t\t", before: "config.time_zone = 'Asia/Manila'"
    insert_into_file "config/routes/admin.routes.rb","require 'sidekiq/web'\n\n", before: "root to: 'admin/pages#dashboard'"
    insert_into_file "config/routes/admin.routes.rb","\n#{sidekiq_route}\n",after: "namespace :admin do"
  end

  gsub_file "app/javascript/packs/application.js", /import Turbolinks from "turbolinks"/, '// import Turbolinks from "turbolinks"'
  gsub_file "app/javascript/packs/application.js", /Turbolinks.start()/, '// Turbolinks.start()'
  gsub_file "app/javascript/packs/application.js", /ActiveStorage.start()/, '// ActiveStorage.start()'
  gsub_file "app/javascript/packs/application.js", /import \* as ActiveStorage from "@rails\/activestorage"/, '// import * as ActiveStorage from "@rails/activestorage"'
end


def stop_spring
  run "spring stop"
end


# Main setup
add_template_repository_to_source_path

add_gems

after_bundle do
  stop_spring
  add_webpack
  add_javascript
  copy_templates
  add_administrator
  

  # Commit everything to git
  unless ENV["SKIP_GIT"]
    git :init
    git add: "."
    # git commit will fail if user.email is not configured
    begin
      git commit: %( -m 'Initial commit' )
    rescue StandardError => e
      puts e.message
    end
  end

  say
  say "  #{original_app_name} app successfully created!", :blue
  say
  say "  To get started with your new app:", :green
  say "  cd #{original_app_name}"
  say
  say "  # Update config/database.yml and config/database/local.yml with your database credentials"
  say
  say "  rails db:create db:migrate"
  say
  say "  Please check db/seeds.rb then rails db:seed"
  say
  say "  Please replace app/assets/images, login page and admin content design. Thank you..", :green
  say
end
