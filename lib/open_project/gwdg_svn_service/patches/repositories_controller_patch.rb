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
          logger.debug "\n*****\nGWDG:\nrepositories_controller_patch.rb - edit_with_gwdg_svn_service0\n(Entry point)\n*****\n"
          @repository = @project.repository
          if !@repository
            @repository = Repository.factory(params[:repository_scm])
            @repository.project = @project if @repository
          end

          if request.post? && @repository && @repository.scm_name == 'Subversion'
            logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service1\n(Current edit SCM has the type: Subversion ::::: #{@repository.inspect})\n*****\n"
            @svn_warning_messages = ""
            svn_adapter = OpenProject::GwdgSvnService::SvnAdapter.new
            begin
              url =  svn_adapter.create_empty_svn(@project)
              params[:repository] = {"url"=>url, "path_encoding"=>""}
              logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service2\n(Repository created)\n*****\n"
            rescue => e
              #logger.debug "Error repo existsA"
              if e.is_a?(Exceptions::RepositoryExists)
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(Exceptions::RepositoryExists)\n*****\n"
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{e.message})\n*****\n"
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{e.url})\n*****\n"
                @svn_warning_messages = e.message
                url = e.url
                params[:repository] = {"url"=>url, "path_encoding"=>""}
              else
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(Exceptions::RepositoryNotCreated)\n*****\n"
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{e.message})\n*****\n"
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{e.program})\n*****\n"
                logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service\n(#{e.stderr})\n*****\n"
                @svn_error_messages = e.message
                url = ""
                params[:repository] = {"url"=>url, "path_encoding"=>""}

                  
                #This produces an infinite loop
                #edit
                
                #This continues the normal execution and produces
                #an error because url is not set
                #edit_without_gwdg_svn_service  
                  
                #################3  
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
                ####################


                return
              end
              logger.debug "\n*****\nGWDG:\nrepositories_control_patch.rb - edit_with_gwdg_svn_service3\n(Repository exists)\n*****\n"
              #logger.debug "Error repo existsB"
            end
                       
 
#            return #later we remove this and continue
          end  
          
          logger.debug "\n*****\nGWDG:\nrepositories_controller_patch.rb - edit_with_gwdg_svn_service4\n(Repository Params #{params})\n*****\n"

          edit_without_gwdg_svn_service
        end
      end
    end
  end
end

RepositoriesController.send(:include, OpenProject::GwdgSvnService::Patches::RepositoriesControllerPatch)

