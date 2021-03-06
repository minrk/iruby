module IRuby
  class Profile
    attr_accessor :iruby_name

    IPYTHON_DIR = `ipython locate`.strip

    # FIXME These should be stored as ERB files
    PROFILE_CONFIG = {}
    PROFILE_CONFIG['ipython_config.py'] = <<-PYTHON
### IRuby custom configuration ###

c.KernelManager.kernel_cmd = ['iruby_kernel', '{connection_file}']
#
## to autorequire a Ruby file (for loading another project's environment),
## add absolute path as third parameter:
#c.KernelManager.kernel_cmd = ['iruby_kernel', '{connection_file}', '~/my_project/config/boot.rb']
#
## if using Bundler, prepend "bundle exec"
## (remember to add 'iruby' to your projects Gemfile)
#c.KernelManager.kernel_cmd = ['bundle', 'exec', 'iruby_kernel', '{connection_file}', '~/my_project/config/boot.rb']

c.Session.key = ''
    PYTHON

    STATIC_DIR = File.join(File.dirname(__FILE__), '..', '..', 'static')

    def initialize(iruby_name='ruby')
      @iruby_name = iruby_name
    end

    def name
      "#{@iruby_name}"
    end

    def path
      File.join(IPYTHON_DIR, "profile_#{name}")
    end

    def create!
      run_ipython_create_profile!
      apply_patches!
      create_static_symlink!
    end

  private
    def run_ipython_create_profile!
      cmd = "ipython profile create '#{name}'"
      puts "=> Run #{cmd}"
      `#{cmd}`
    end

    def apply_patches!
      # FIXME only append if needed!
      PROFILE_CONFIG.each do |file, config|
        file_path = File.join(path, file)
        puts "=> Append extra configuration to #{file_path}"
        File.open(file_path, 'a') do |f|
          f.write("\n#{config}\n")
        end
      end
    end

    def create_static_symlink!
      src, dst = File.join(STATIC_DIR), File.join(path, 'static')
      if not File.exists?(dst)
        puts "=> Symlink #{src} to #{dst}"
        File.symlink(src, dst)
      end
    end
  end
end
