require 'thor'
require 'active_support/inflector'
require 'erb'

module ServiceContract
  module Generator
    class CLI < Thor

      desc "protocol NAMESPACE PROTOCOL_NAME VERSION", "generate a new protocol"
      def protocol(namespace, protocol_name, version)
        folder = File.join("contracts", version, "source")
        FileUtils.mkdir_p(folder)
        output_file = File.join(folder, "#{ActiveSupport::Inflector.underscore(protocol_name)}.avdl")
        b = binding()
        write_template("protocol.avdl.erb", output_file, b)
      end

      desc "gem CONTRACT_NAME", "bootstraps a new service_contract"
      def gem(contract_name)
        path = contract_name.gsub("-", "/")
        module_name = ActiveSupport::Inflector.camelize(path)
        module_names = module_name.split("::")

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

        # add service_contract to .gemspec
        gemspec = "#{contract_name}/#{contract_name}.gemspec"
        dependency_line = `grep -m 1 -n '.add_de' #{gemspec}`
        matched = false
        output = ""
        File.open(gemspec, "r") do |file|
          file.each_line do |line|
            puts line
            if !matched && match = line.match(/([^\.]+)\.add_de/)
              puts "matched"
              output += %{#{match[1]}.add_dependency "service_contract"\n}
              matched = true
            end
            output += line
          end
        end
        puts output
        File.open(gemspec, "w") do |file|
          file.write(output)
        end

        # template files
        path_to_root = (Array.new(2 + module_name.split("::").length) {".."}).join("/")
        service_name = ActiveSupport::Inflector.humanize(contract_name)
        b = binding()
        %w(documentation.rb.erb service.rb.erb).each do |template|
          output_file = File.join(contract_name, 'lib', path, File.basename(template, ".erb"))
          write_template(template, output_file, b)
        end

        write_template("module.rb.erb", File.join(contract_name, "lib", "#{path}.rb"), b)
      end

      protected

      def write_template(name, output_file, bind)
        template_folder = File.expand_path("../../../../template", __FILE__)
        input = File.join(template_folder, name)
        erb = ERB.new(File.read(input))
        File.open(output_file, 'w') do |file|
          file.write(erb.result(bind))
        end
      end

    end
  end
end