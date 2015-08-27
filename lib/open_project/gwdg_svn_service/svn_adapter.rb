require 'open3'

module OpenProject::GwdgSvnService
  class SvnAdapter

    def logger
      Rails.logger
    end
   
    def root_path
      @root_path ||= '/home/openproject/openproject/svn/'
    end
 
    def svnadmin_command
      @svnadmin_command ||= 'svnadmin'
    end

    def create_empty_svn(project)
      logger.debug "I am in create_empty svn ---- svn root: #{root_path} command: #{svnadmin_command}"  
      
      @path = root_path + project.identifier  

      _, err, code = Open3.capture3(svnadmin_command, 'verify', '-q', @path)

      if code == 0
        return "file://#{@path}" 
      end

      _, err, code = Open3.capture3(svnadmin_command, 'create', @path)
      if code != 0
        msg = "Failed to create empty subversion repository with `#{svnadmin_command} create`"
        logger.error(msg)
        logger.debug("Error output is #{err}")
        #TODO Raise Error and cat in patch
      end

      return "file://#{@path}"
    end
  end
end
