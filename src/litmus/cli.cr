require "option_parser"
require "diff"
require "colorize"
require "file_utils"
require "./tree"

module Litmus
  # Command line interface.
	module Cli
		# Options struct. Keeps default options in one place.
		struct Options
			property basedir = Dir.current
			property outdir = Dir.current
			property help = false
      property show = false
			property update = false
			property generate = false
			property diff = false
      property all = false
			property files = [] of String
			property input : Array(String) = [] of String
			property parser : OptionParser | Nil = nil
      property verbosity = 2
		end

		# Parse command-line options.
    def self.parse_options!(options = Options.new)
			options.parser = OptionParser.parse! do |p|
				p.banner = "Usage: litmus FILE [OPTIONS]"

        p.on("-o", "--outdir PATH", "Specifies an output directory different from basedir.") do |path|
					options.outdir = path
				end

				p.on("-b", "--basedir PATH", "Set basedir") do |path|
					options.basedir = path

          if options.outdir == Dir.current
            options.outdir = path
          end
				end

				p.on("-u", "--update", "Update files") do
					options.update = true
				end

				p.on("-d", "--diff", "Show diff between existing and generated files.") do
					options.diff = true
				end

				p.on("-g", "--generate", "Generate processed markdown files from the input") do
					options.generate = true
				end

				p.on("-f", "--file FILE", "Only operate on one single file.") do |p|
					options.files << p
				end

				p.on("-h", "--help", "Show this help") do
					options.help = true
				end

				p.on("-q", "--quiet", "Don't show any output") do
					options.verbosity = 5
				end

        p.on("-v", "--verbose", "Be more verbose") do
          options.verbosity -= 1 unless options.verbosity == 0
        end

        p.on("-a", "--all", "Treat all .lit.md files in basedir as inputs.") do
          options.all = true
        end

        p.on("-s", "--show", "Print the contents of the generated code files.") do
          options.show = true
        end
			end

      # anything specified on the command line that is not an option gets treated as an
      # input file.
      options.input += ARGV

      # when -a is specified, search the basedir for input files.
      if options.all
        candidates = Dir[File.join(options.basedir, "*.lit.md")]

        # remove basedir prefix
        candidates.map!{|file| file[options.basedir.size..-1]}

        options.input += candidates
			end

      # deduplicate input files
      options.input.uniq!

      if options.input.size == 0
        options.help = true
      end

			options
		end

		# Select the requested files from the files list, or return all.
		def self.select_files(options, files)
			if options.files.size > 0
				selected_files = [] of CodeFile
				options.files.each do |f|
					file = files.find{|cf| cf.file == f}

					if file
						selected_files << file unless selected_files.includes? file
					else
            LOG.error "file '#{f}' not found in index."
					end
				end

				selected_files
			else
				files
			end
		end

    # Run the command line interface.
		def self.run
			options = parse_options!
      LOG.level = Logger::Severity.new(options.verbosity)

			# show help if requested or when no input file was given.
			if options.help
				puts options.parser
				return
			end

			# parse file tree from the input file.
      begin
        tree = Tree.from(options.input, options.basedir)
        tree.update!
      rescue ex
        if options.verbosity == 0
          LOG.fatal(String.build do |io|
            ex.inspect_with_backtrace(io)
          end.chomp)
        else
          LOG.fatal ex.message
        end
        return
      end

			select_files(options, tree.code_files).each do |f|
				path = File.expand_path(f.file, options.outdir)

				if options.diff
					puts "=== @#{f.file} ==="
					data = ""
					data = File.read(path) if File.exists? path

					Diff.diff(data.to_s, f.to_s).each do |chunk|
						print chunk.data.colorize(
							chunk.append? ? :green :
							chunk.delete? ? :red   : :dark_gray)
					end
				end

        if options.show
          puts "=== #{f.file} ==="
          puts f
        end

				if options.update
					FileUtils.mkdir_p(File.dirname(path))
					File.write(path, f)
				end
			end

			if options.generate
        tree.input_files.each do |input_file|
          puts input_file.output
        end
			end
		end
	end
end
