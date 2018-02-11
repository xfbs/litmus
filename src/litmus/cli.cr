require "option_parser"
require "diff"
require "colorize"
require "file_utils"
require "./tree"

module Litmus
	module Cli
		# Options struct. Keeps default options in one place.
		struct Options
			property basedir = Dir.current
			property outdir = Dir.current
			property help = false
			property update = false
			property generate = false
			property quiet = false
			property diff = false
			property files = [] of String
			property input : String | Nil = nil
			property parser : OptionParser | Nil = nil
		end

		# Parse command-line options.
		def self.parse_options!
			options = Options.new
			options.parser = OptionParser.parse! do |p|
				p.banner = "Usage: litmus FILE [OPTIONS]"

				p.on("-o", "--outdir PATH", "Set output directory") do |path|
					options.outdir = path
				end

				p.on("-b", "--basedir PATH", "Set basedir") do |path|
					options.basedir = path
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
					options.quiet = true
				end
			end

			if ARGV.size == 1
				options.input = ARGV[0]
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
						puts "Error: file '#{f}' not found in index."
					end
				end

				selected_files
			else
				files
			end
		end

		def self.run
			options = parse_options!

			# show help if requested or when no input file was given.
			if options.help || !options.input
				puts options.parser
				return
			end

			# parse file tree from the input file.
			tree = Tree.from(options.input.as(String), options.basedir)

			select_files(options, tree.code_files).each do |f|
				path = File.expand_path(f.file, options.outdir)

				if options.diff
					puts "=== @#{f.file} ==="
					data = ""
					data = File.read(path) if File.exists? path

					Diff.diff(data.to_s, f.render.to_s).each do |chunk|
						print chunk.data.colorize(
							chunk.append? ? :green :
							chunk.delete? ? :red   : :dark_gray)
					end
				end

				if options.update
					FileUtils.mkdir_p(File.dirname(path))
					File.write(path, f.render)
				end
			end

			if options.generate
        puts tree.input_files.map{|i| i.generate}.join
			end
		end
	end
end
