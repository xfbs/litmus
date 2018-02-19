require "option_parser"
require "colorize"
require "file_utils"
require "./tree"
require "./logger"
require "./loggable"
require "./options"

module Litmus
  # Command line interface.
	class Cli
    include Loggable

    def initialize(@opt = Options.new)
      @log = @opt.logger
    end

		# Parse command-line options.
    def parse_args!
			parser = OptionParser.parse! do |p|
				p.banner = "Usage: #{PROGRAM_NAME} FILE [OPTIONS]"
        p.separator "Actions"
				p.on("-h", "--help", "Show this help"){ @opt.help = true }
				p.on("-u", "--update", "Update code files from input files"){ @opt.update = true }
				p.on("-g", "--generate", "Generate markdown files from input files"){ @opt.generate = true }
        p.on("-r", "--recursive PATH", "Load all .lit.md files inside PATH") do |dir|
          @opt.recursive_dirs << dir
        end

        p.separator "Paths"
        p.on("-c", "--codedir PATH", "Output directory for code files") do |path|
          @opt.codedir = path
        end

        p.separator "Verbosity"
				p.on("-q", "--quiet", "Don't show any output") do
					@opt.verbosity = 5
				end

        p.on("-v", "--verbose", "Be more verbose") do
          @opt.verbosity -= 1 unless @opt.verbosity == 0
        end
			end

      @opt.logger.log_level(@opt.verbosity)
      @opt.input_files += ARGV

      # if no input files are specified, show help.
      @opt.help = true if @opt.input_files.size == 0
      @opt.help_text = parser.to_s if @opt.help?

      @opt.validate!
      self
		end

    # Run the command line interface.
		def run!
			# show help if requested or when no input file was given.
			if @opt.help?
				puts @opt.help_text
				return
			end

      tree = Tree.new(@opt)

			# parse file tree from the input file.
      begin
        @opt.input_files.each do |file|
          info "Reading and parsing input file '#{file}'."
          input_file = InputFile.read(@log, file, Dir.current)

          info "Adding input file '#{file}' to internal file tree."
          tree << input_file
        end
      rescue ex
        fatal ex
        return
      end

      # update tree with files
      info "Updating internal file tree."
      tree.finalize!

      tree.code_files.each do |f|
				path = File.expand_path(f.file, @opt.outdir)

				if @opt.update?
					FileUtils.mkdir_p(File.dirname(path))
					File.write(path, f)
				end
			end

			if @opt.generate?
        tree.input_files.each do |input_file|
          out = File.open(input_file.output.path, "w")
          out.puts(input_file.output)
          out.close
        end
			end
		end
	end
end
