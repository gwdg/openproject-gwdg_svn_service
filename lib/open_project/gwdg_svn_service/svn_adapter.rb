require 'open3'

module OpenProject::GwdgSvnService
  class SvnAdapter

    def logger
      Rails.logger
    end
   
    def root_path
      @root_path ||= '/home/openprojectdev/openproject/svn/'
    end
 
    def svnadmin_command
      @svnadmin_command ||= 'svnadmin'
    end
    
    def project_svn_repo_url
      @project_svn_repo_url
    end

    def create_empty_svn(project)
      logger.debug "\n*****\nGWDG :\nsvn_adapter.rb - create_empty_svn\n(I am in create_empty svn ---- svn root: #{root_path} command: #{svnadmin_command})\n*****\n"  
      
      @path = root_path + project.identifier  
      @project_svn_repo_url = ""
      
      _, err, code = Open3.capture3(svnadmin_command, 'verify', '-q', @path)
      # If the repository exists
      if code == 0
        msg = "\n*****\nGWDG :\nsvn_adapter.rb - create_empty_svn\n(Repository already exists in file://#{@path})\n*****\n" 
        logger.debug(msg)
        @project_svn_repo_url = "file://#{@path}"
        raise Exceptions::RepositoryExists.new("The repository for project #{project.name} already exists.", @project_svn_repo_url)
        #return "#{@project_svn_repo_url}" 
      end

      _, err, code = Open3.capture3(svnadmin_command, 'create', @path)
      # If the repository could not be created
      if code != 0
        msg = "\n*****\nGWDG :\nsvn_adapter.rb - create_empty_svn\n(Failed to create empty subversion repository with `#{svnadmin_command} create`)\n*****\n"
        logger.error(msg)
        logger.debug("*****\nGWDG: svn_adapter.rb - create_empty_svn\n( #{err})\n*****")
        #TODO Raise Error and cat in patch
        raise Exceptions::RepositoryNotCreated.new("There was an error when creating the repository for project #{project.name}.", "#{svnadmin_command} create", "#{err}")
      else
        @project_svn_repo_url = "file://#{@path}"
      end

      return "#{@project_svn_repo_url}"
    end
  end
end
