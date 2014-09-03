module ServiceContract
  module Generator
    module CLI
      class Contract < Thor
        desc "new"

        desc "gem CONTRACT_NAME", "bootstraps a new service_contract"
        def gem(contract_name)
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
          Dir.glob(File.expand_path("../../../../template/*.erb", __FILE__)).each do |template|
            erb = ERB.new(File.read(template))
            output_file = File.join(contract_name, 'lib', path, File.basename(template, ".erb"))
            puts "writing template: #{output_file}"
            File.open(output_file, 'w') do |file|
              file.write(erb.result(b))
            end
          end
        end
      end
    end
  end
end