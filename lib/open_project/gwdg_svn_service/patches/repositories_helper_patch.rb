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
          logger.debug "\n*****\nGWDG :\nrepositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(GWDG GWDG GWDG GWDG #{@test})\n*****\n"
          logger.debug "\n*****\nGWDG :\nrepositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(GWDG GWDG GWDG GWDG #{@repository.inspect})\n*****\n"
          if repository && !repository.url.blank? # If repository exists in DB, it will show the fields
            url = content_tag('div', class: 'form--field') do
              form.text_field(:url,
                              size: 60,
                              required: true,
                              disabled: true) +
              content_tag('div',
                          'file:///, http://, https://, svn://, svn+[tunnelscheme]://',
                          class: 'form--field-instructions')
            end
          else # If repository does not exist, it will show nothing
            url = ''
          end
          
          # Returns the code to show the url fields of the repository
          url
        end


        def svn_error_messages_for(message)
          render(:partial => 'projects/settings/svn_error_messages',
                :locals => {:svn_error_message => message})
        end

        def svn_warning_messages_for(message)
          render(:partial => 'projects/settings/svn_warning_messages',
                :locals => {:svn_warn_message => message})
        end
        
      end
    end
  end
end

RepositoriesHelper.send(:include, OpenProject::GwdgSvnService::Patches::RepositoriesHelperPatch)
