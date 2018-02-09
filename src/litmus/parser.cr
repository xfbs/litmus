require "./extract_code_blocks"
require "markdown/parser"


module Litmus
	def self.parse(options, filename)
		unless File.exists? File.join(filename)
			raise "File #{filename} not found in #{Dir.current}."
		end

		file = File.read filename
		render = Render.new

		Markdown::Parser.new(file, render).parse
	end
end
