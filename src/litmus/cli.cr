require "option_parser"
require "diff"
require "colorize"
require "file_utils"
require "./tree"
require "./logger"

module Litmus
  # Options class. Keeps default options in one place.
  class Options
    property logger = Logger.default
    property basedir = Dir.current
    property outdir = Dir.current
    property codedir = Dir.current
    property help = false
    property update = false
    property generate = false
    property files = [] of String
    property input : Array(String) = [] of String
    property help_text : String | Nil = nil
    property verbosity = 2

    def validate!
      validated_input = [] of String

      @input.reduce({} of String => Bool) do |duplicate, cur|
        if duplicate[cur]? == false
          duplicate[cur] = true
        else
          duplicate[cur] = false
          validated_input << cur
        end

        duplicate
      end.select do |file, duplicate|
        duplicate == true
      end.each do |file, _|
        @logger.warn "Input file '#{file}' was specified multiple times as "\
          "argument, but it will only be parsed once."
      end

      @input = validated_input

      unless Dir.exists? @basedir
        raise "Basedir '#{@basedir}' doesn't exist or isn't a directory."
      end

      unless Dir.exists? @outdir
        raise "Outdir '#{@outdir}' doesn't exist or isn't a directory."
      end

      unless Dir.exists? @codedir
        raise "Codedir '#{@codedir}' doesn't exist or isn't a directory."
      end
    end
  end

  # Command line interface.
	module Cli
		# Parse command-line options.
    def self.parse_options!(opt = Options.new)
			parser = OptionParser.parse! do |p|
				p.banner = "Usage: litmus FILE [OPTIONS]"
        p.separator "Actions"
				p.on("-h", "--help", "Show this help"){ opt.help = true }
				p.on("-u", "--update", "Update code files"){ opt.update = true }
				p.on("-g", "--generate", "Generate markdown files from input"){ opt.generate = true }

        p.separator "Paths"
        p.on("-o", "--outdir PATH", "Output directory for markdown files.") do |path|
          opt.outdir = path
        end

        p.on("-c", "--codedir PATH", "Output directory for code files") do |path|
          opt.codedir = path
        end

        p.separator "Verbosity"
				p.on("-q", "--quiet", "Don't show any output") do
					opt.verbosity = 5
				end

        p.on("-v", "--verbose", "Be more verbose") do
          opt.verbosity -= 1 unless opt.verbosity == 0
        end
			end

      opt.logger.log_level(opt.verbosity)
      opt.input += ARGV

      # if no input files are specified, shoe help.
      if opt.input.size == 0
        opt.help = true
      end

      if opt.help
        opt.help_text = parser.to_s
      end

			opt
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
            #LOG.error "file '#{f}' not found in index."
					end
				end

				selected_files
			else
				files
			end
		end

    def self.run!
      begin
        opt = parse_options!
      rescue ex
        Logger.default.fatal ex
        return false
      end

      begin
        opt.validate!
      rescue ex
        opt.logger.fatal ex
        return false
      end

      run(opt)
    end

    # Run the command line interface.
		def self.run(opt)
			# show help if requested or when no input file was given.
			if opt.help
				puts opt.help_text
				return
			end

      log = opt.logger

      tree = Tree.new

			# parse file tree from the input file.
      begin
        opt.input.each do |file|
          log.info "Reading and parsing input file '#{file}'."
          input_file = InputFile.read(log, file, Dir.current)

          log.info "Adding input file '#{file}' to internal file tree."
          tree.load_input(input_file)
        end
      rescue ex
        log.fatal ex
        return
      end

      # update tree with files
      log.info "Updating internal file tree."
      tree.update!

		  #select_files(opt, tree.code_files).each do |f|
      tree.code_files.each do |f|
				path = File.expand_path(f.file, opt.outdir)

				if opt.update
					FileUtils.mkdir_p(File.dirname(path))
					File.write(path, f)
				end
			end

			if opt.generate
        tree.input_files.each do |input_file|
          puts input_file.output.path
          puts input_file.output
        end
			end
		end
	end
end
