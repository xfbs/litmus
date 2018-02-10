require "./extracter"
require "./tree"
require "markdown/parser"


module Litmus
	def self.parse(options, filename)
		unless File.exists? File.join(filename)
			raise "File #{filename} not found in #{Dir.current}."
		end

		file = File.read filename
		render = Extracter.new

		Markdown::Parser.new(file, render).parse

		code_blocks = render.code_blocks

		tree = Tree.load(code_blocks)

		files = tree.files

		files.each do |file|
			puts "#{file.file}: #{file}"
			puts file.render
		end
	end
end
