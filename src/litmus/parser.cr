require "./partial"
require "./tree"
require "markd"

module Litmus
	# Parses a given litmus file and returns a tree from it.
	def self.parse(options, filename)
		file_path = File.join(options["basedir"], filename)

		unless File.exists? file_path
			raise "File '#{filename}' not found in '#{options["basedir"]}'."
		end

		# extract code blocks from the file
		file = File.read file_path
		#render = Extracter.new
		#Markdown::Parser.new(file, render).parse
		#code_blocks = render.code_blocks
		options = Markd::Options.new(smart: true)
		document = Markd::Parser.parse(file, options)
		code_blocks = extract(document)

		# load a file tree from the code blocks
		#Tree.load(code_blocks)
		Tree.new
	end

	def self.extract(document)
		walker = document.walker
		code_blocks = [] of Partial

		while event = walker.next
			node, entering = event

			case node.type
			when Markd::Node::Type::CodeBlock
				puts node.fence_language
				puts node.text.inspect
			end
		end

		code_blocks
	end
end
