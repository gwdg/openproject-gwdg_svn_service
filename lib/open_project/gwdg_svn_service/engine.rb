# Prevent load-order problems in case openproject-plugins is listed after a plugin in the Gemfile
# or not at all
require 'open_project/plugins'

module OpenProject::GwdgSvnService
  class Engine < ::Rails::Engine
    engine_name :openproject_gwdg_svn_service

    include OpenProject::Plugins::ActsAsOpEngine

    def self.settings
      {
        default: { 'svn_url_prefix' => nil,
                   'svn_repository_root' => nil
        },
        partial: 'settings/gwdg_svn_service_settings.html.erb'
      }
    end

    register 'openproject-gwdg_svn_service',
             :author_url => 'http://www.gwdg.de',
             :requires_openproject => '>= 3.0.0pre13',
             settings: settings do end

    config.to_prepare do 
      [ 
         :repositories_helper, :repositories_controller
      ].each do |sym|
        require_dependency "open_project/gwdg_svn_service/patches/#{sym}_patch"
      end
    end

  end
end
