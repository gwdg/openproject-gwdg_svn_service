require 'open3'

module OpenProject::GwdgSvnService
  class SvnAdapter

    def logger
      Rails.logger
    end
 
    def svnadmin_command
      @svnadmin_command ||= 'svnadmin'
    end
    
    def create_empty_svn(project)
      logger.debug "OpenProject GWDG Subversion Service: svn_adapter.rb - create_empty_svn\n(Entry point)"  

      # Sets the path of the repository
      project_svn_repo_path = Setting.plugin_openproject_gwdg_svn_service["svn_repository_root"] + project.identifier  
      
      # Sets the URL of the repository, it will not be used in case of any error when creating the repository in the file system
      project_svn_repo_url = Setting.plugin_openproject_gwdg_svn_service["svn_url_prefix"] + project_svn_repo_path
      
      # Check if the repository exists
      _, err, code = Open3.capture3(svnadmin_command, 'verify', '-q', project_svn_repo_path)
      
      # If the repository exists
      if code == 0
        logger.info "OpenProject GWDG Subversion Service: svn_apdater.rb - create_empty_svn\n(Repository already exists in #{project_svn_repo_path})"

        # Raise warning exception
        raise Exceptions::RepositoryExists.new(" #{project.name}.", project_svn_repo_url)
      end

      # Create an empty repository
      _, err, code = Open3.capture3(svnadmin_command, 'create', project_svn_repo_path)
      
      # If the repository could not be created
      if code != 0
        logger.error "OpenProject GWDG Subversion Service: svn_apdater.rb - create_empty_svn\n(Failed to create empty repository with `#{svnadmin_command} create` in #{project_svn_repo_path})"
        logger.error "OpenProject GWDG Subversion Service: svn_apdater.rb - create_empty_svn\n(Error message: #{err})"

        # Raise error exception
        raise Exceptions::RepositoryNotCreated.new(" #{project.name}.", "#{svnadmin_command} create", "#{err}")
      end
              
      logger.info "OpenProject GWDG Subversion Service: svn_apdater.rb - create_empty_svn\n(Repository was created with `#{svnadmin_command} create` in #{project_svn_repo_path})"
      logger.debug "OpenProject GWDG Subversion Service: svn_apdater.rb - create_empty_svn\n(Exit point)"

      # Return the URL of the repository
      return "#{project_svn_repo_url}"
    end
  end
end
