require 'thor'
require 'active_support/inflector'
require 'erb'

module ServiceContract
  module Generator
    class CLI < Thor

      desc "new CONTRACT_NAME", "bootstraps a new service_contract"
      def new(contract_name)
        path = contract_name.gsub("-", "/")
        module_name = ActiveSupport::Inflector.camelize(path)

        # create directory structure
        commands = [
          # create gem stub
          %{bundle gem #{contract_name}},

          # create contracts folder
          %{mkdir -p #{contract_name}/contracts/},
          %{touch #{contract_name}/contracts/},

          # append tasks to Rakefile
          %{echo "require 'service_contract/tasks'" >> #{contract_name}/Rakefile}
        ]
        commands.each do |command|
          puts command
          `#{command}`
        end

        # template files
        path_to_root = "PATH/TO/ROOT"
        service_name = ActiveSupport::Inflector.humanize(contract_name)
        b = binding()
        Dir.glob(File.expand_path("../../../../template/*.erb", __FILE__)).each do |template|
          erb = ERB.new(File.read(template))
          output_file = File.join(contract_name, 'lib', path, File.basename(template, ".erb"))
          File.open(output_file, 'w') do |file|
            file.write(erb.result(b))
          end
        end
      end

    end
  end
end