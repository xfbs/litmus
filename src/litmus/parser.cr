require "./extracter"
require "./tree"
require "markdown/parser"


module Litmus
	# Parses a given litmus file and returns a tree from it.
	def self.parse(options, filename)
		file_path = File.join(options["basedir"], filename)

		unless File.exists? file_path
			raise "File '#{filename}' not found in '#{options["basedir"]}'."
		end

		# extract code blocks from the file
		file = File.read file_path
		render = Extracter.new
		Markdown::Parser.new(file, render).parse
		code_blocks = render.code_blocks

		# load a file tree from the code blocks
		Tree.load(code_blocks)
	end
end
