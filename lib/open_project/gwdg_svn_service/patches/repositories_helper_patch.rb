module OpenProject::GwdgSvnService
  module Patches
    module RepositoriesHelperPatch
      def self.included(base)
        base.class_eval do
          unloadable
          
          include InstanceMethods
          
          alias_method_chain :subversion_field_tags, :gwdg_svn_service
        end
      end
        
      module InstanceMethods
        def subversion_field_tags_with_gwdg_svn_service(form, repository)
          @test = repository && !repository.root_url.blank?
          logger.debug "GWDG GWDG GWDG GWDG #{@test}"
          logger.debug repository.inspect
          if repository && !repository.url.blank?
            url = content_tag('div', class: 'form--field') do
              form.text_field(:url,
                              size: 60,
                              required: true,
                              disabled: true) +
              content_tag('div',
                          'file:///, http://, https://, svn://, svn+[tunnelscheme]://',
                          class: 'form--field-instructions')
            end
          else
            url = ''
          end
          
          url
        end
      end
    end
  end
end

RepositoriesHelper.send(:include, OpenProject::GwdgSvnService::Patches::RepositoriesHelperPatch)
