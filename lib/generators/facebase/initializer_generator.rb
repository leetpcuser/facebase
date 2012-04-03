module Facebase
  class InitializerGenerator < Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    desc "Generator creates the facebase initializer"

    def create_config_files
      copy_file "facebase.rb", "config/initializers/facebase.rb"
    end

  end
end
