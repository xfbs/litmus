require "option_parser"
require "./parser"

module Litmus
	module Cli
		def self.run
			options = {} of String => String
			show_help = false

			parser = OptionParser.parse! do |p|
				p.banner = "Usage: litmus FILE [OPTIONS]"

				p.on("-o", "--outdir=PATH", "Set output directory") do |path|
					options["outdir"] = path
				end

				p.on("-b", "--basedir=PATH", "Set basedir") do |path|
					options["basedir"] = path
				end

				p.on("-h", "--help", "Show this help") do
					show_help = true
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
			Litmus.parse(options, filename)
		end
	end
end
