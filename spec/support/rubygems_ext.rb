require 'rubygems/user_interaction'
require 'support/path' unless defined?(Spec::Path)

module Spec
  module Rubygems
    def self.setup
      Gem.clear_paths

      ENV['BUNDLE_PATH'] = nil
      ENV['GEM_HOME'] = ENV['GEM_PATH'] = Path.base_system_gems.to_s
      ENV['PATH'] = ["#{Path.root}/bin", "#{Path.system_gem_path}/bin", ENV['PATH']].join(File::PATH_SEPARATOR)

      unless File.exist?("#{Path.base_system_gems}")
        FileUtils.mkdir_p(Path.base_system_gems)
        puts "installing gems for the tests to use..."
        `gem install fakeweb artifice --no-rdoc --no-ri`
        `gem install sinatra --version 1.2.7 --no-rdoc --no-ri`
        # Rake version has to be consistent for tests to pass
        `gem install rake --version 10.0.2 --no-rdoc --no-ri`
        # 3.0.0 breaks 1.9.2 specs
        `gem install builder --version 2.1.2 --no-rdoc --no-ri`
        `gem install rack --no-rdoc --no-ri`
        # ruby-graphviz is used by the viz tests
        `gem install ruby-graphviz --no-rdoc --no-ri` if RUBY_VERSION >= "1.9.3"
      end

      ENV['HOME'] = Path.home.to_s

      Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
    end

    def gem_command(command, args = "", options = {})
      if command == :exec && !options[:no_quote]
        args = args.gsub(/(?=")/, "\\")
        args = %["#{args}"]
      end
      lib  = File.join(File.dirname(__FILE__), '..', '..', 'lib')
      %x{#{Gem.ruby} -I#{lib} -rubygems -S gem --backtrace #{command} #{args}}.strip
    end
  end
end
