require "option_parser"
require "diff"
require "colorize"
require "file_utils"
require "./parser"

module Litmus
	module Cli
		def self.run
			options = {
				"outdir" => Dir.current,
				"basedir" => Dir.current
			} of String => String
			show_help = false
			update = false
			quiet = false
			diff = false

			parser = OptionParser.parse! do |p|
				p.banner = "Usage: litmus FILE [OPTIONS]"

				p.on("-o", "--outdir=PATH", "Set output directory") do |path|
					options["outdir"] = path
				end

				p.on("-b", "--basedir=PATH", "Set basedir") do |path|
					options["basedir"] = path
				end

				p.on("-u", "--update", "Update files") do
					update = true
				end

				p.on("-d", "--diff", "Show diff between existing and generated files.") do
					diff = true
				end

				p.on("-h", "--help", "Show this help") do
					show_help = true
				end

				p.on("-q", "--quiet", "Don't show any output") do
					quiet = true
				end
			end

			if ARGV.size != 1
				show_help = true
			end

			if show_help
				puts parser
				return
			end

			filename = ARGV[0]
			tree = Litmus.parse(options, filename)

			tree.files.each do |f|
				path = File.expand_path(f.file, options["outdir"])

				if diff
					puts "=== @#{f.file} ==="
					data = ""
					data = File.read(path) if File.exists? path

					Diff.diff(data.to_s, f.render.to_s).each do |chunk|
						print chunk.data.colorize(
							chunk.append? ? :green :
							chunk.delete? ? :red   : :dark_gray)
					end
				end

				if update
					FileUtils.mkdir_p(File.dirname(path))
					File.write(path, f.render)
				end
			end
		end
	end
end
