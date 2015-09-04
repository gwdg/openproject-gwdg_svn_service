require 'open_project/gwdg_svn_service/svn_adapter'
module OpenProject::GwdgSvnService
  module Patches
    module RepositoriesControllerPatch
      def self.included(base)
        base.class_eval do
          unloadable

          include InstanceMethods

          alias_method_chain :edit, :gwdg_svn_service
        end
      end

      module InstanceMethods
        def edit_with_gwdg_svn_service

          logger.debug "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(Entry point)"
          
          #BEGIN: This is a copy from the original "def edit" in repositories_controller.rb
          @repository = @project.repository
          if !@repository
            @repository = Repository.factory(params[:repository_scm])
            @repository.project = @project if @repository
          end
          #END: This is a copy from the original "def edit" in repositories_controller.rb

          # If user tries to create a Subversion repository
          if request.post? && @repository && @repository.scm_name == 'Subversion'
            logger.debug "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(POST: Current edit SCM has the type Subversion)"
            logger.debug "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{@repository.inspect})"

            #Initialize error messages
            @svn_warning_messages = ""
            @svn_error_messages = ""
            
            #Create the object to handle the repository
            svn_adapter = OpenProject::GwdgSvnService::SvnAdapter.new
            
            #Try to create the repository in the file system
            begin
              #Create the repository in file system
              url =  svn_adapter.create_empty_svn(@project)
              #Set the path of the repository to be saved in database
              params[:repository] = {"url"=>url, "path_encoding"=>""}
                
              logger.info "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(Repository was created in #{url})"
              
            # If repository exists
            rescue Exceptions::RepositoryExists => e
              #Set the warning message of the existing repository
              @svn_warning_messages = e.project
              #Set the path of the repository to be saved in database
              url = e.url
              params[:repository] = {"url"=>url, "path_encoding"=>""}

              logger.info "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(Repository exists in #{url})"

            # If repository could not be created
            rescue Exceptions::RepositoryNotCreated => e
              #Set the error message
              @svn_error_messages = e.project
              #Set the path of the repository to empty
              url = ""
              params[:repository] = {"url"=>url, "path_encoding"=>""}

              logger.error "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(Repository could not be created)"
              logger.error "OpenProject GWDG Subversion Service: repositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{e.stderr})"

              # Render the rest of the form to show the error
              #BEGIN: This is a copy from the original "def edit" in repositories_controller.rb
              menu_reload_required = if @repository.persisted? && !@project.repository
                                       @project.reload # needed to reload association
                                     end
            
              respond_to do |format|
                format.js do
                  render template: '/projects/settings/repository',
                         locals: { project: @project,
                                   reload_menu: menu_reload_required }
                end
              end
              #END: This is a copy from the original "def edit" in repositories_controller.rb

              # Return, as it will not save to database
              return
            
            end # rescue
 
          end  
          
          logger.debug "OpenProject GWDG Subversion Service: repositories_controller_patch.rb - edit_with_gwdg_svn_service\n(Repository Params #{params})"
          logger.debug "OpenProject GWDG Subversion Service: repositories_controller_patch.rb - edit_with_gwdg_svn_service\n(Exit point)"

          #Call the original "def edit" in repositories_controller.rb to save to database
          edit_without_gwdg_svn_service
        end
      end
    end
  end
end

RepositoriesController.send(:include, OpenProject::GwdgSvnService::Patches::RepositoriesControllerPatch)

