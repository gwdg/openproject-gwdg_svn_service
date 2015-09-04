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
          logger.debug "OpenProject GWDG Subversion Service: repositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(Entry point)"
          logger.debug "OpenProject GWDG Subversion Service: repositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(#{@repository.inspect})"
          
          # If repository exists in DB, it will show the fields
          if repository && !repository.url.blank?
            logger.debug "OpenProject GWDG Subversion Service: repositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(Repository exists in database)"
            
            # Create the URL fields of the repository stored in database
            #BEGIN: This is a copy from the original "ef subversion_field_tags(form, repository)" in repositories_helper.rb
            url = content_tag('div', class: 'form--field') do
              form.text_field(:url,
                              size: 60,
                              required: true,
                              disabled: true) +
              content_tag('div',
                          'file:///, http://, https://, svn://, svn+[tunnelscheme]://',
                          class: 'form--field-instructions')
            end
            #END: This is a copy from the original "ef subversion_field_tags(form, repository)" in repositories_helper.rb

            # Copy the form fields
            url_form_fields = url
            
          # If repository does not exist, it will show nothing
          else
            logger.debug "OpenProject GWDG Subversion Service: repositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(Repository does not exist in database)"
            
            # Sets the repository URL form fields to empty
            url_form_fields = ''
          end

          logger.debug "OpenProject GWDG Subversion Service: repositories_helper_patch.rb - subversion_field_tags_with_gwdg_svn_service\n(Exit point)"
          
          # Return the the URL form fields of the repository to be shown
          url_form_fields
        end #subversion_field_tags_with_gwdg_svn_service

        
        # Render the warning or error messages in case the repository was not created
        def svn_warning_error_messages_for(message, type)
          render(:partial => "projects/settings/svn_#{type}_messages",
                :locals => {"svn_#{type}_message".to_sym => message})
        end
        
      end
    end
  end
end

RepositoriesHelper.send(:include, OpenProject::GwdgSvnService::Patches::RepositoriesHelperPatch)
