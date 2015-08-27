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
          @repository = @project.repository
          if !@repository
            @repository = Repository.factory(params[:repository_scm])
            @repository.project = @project if @repository
          end

          if request.post? && @repository && @repository.scm_name == 'Subversion'
            logger.debug "Current edit SCM has the type: Subversion ::::: #{@repository.inspect}"
            
            svn_adapter = OpenProject::GwdgSvnService::SvnAdapter.new
            url =  svn_adapter.create_empty_svn(@project)
            params[:repository] = {"url"=>url, "path_encoding"=>""}           
 
#            return #later we remove this and continue
          end  
          
          logger.debug "Repository Params #{params}"

          edit_without_gwdg_svn_service
        end
      end
    end
  end
end

RepositoriesController.send(:include, OpenProject::GwdgSvnService::Patches::RepositoriesControllerPatch)

