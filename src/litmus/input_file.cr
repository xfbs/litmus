require "./partial"
require "./tree"
require "markd"

module Litmus
	class InputFile
		@file = uninitialized String
		@data = uninitialized String
		@base = uninitialized String
		@path = uninitialized String
		@doc = uninitialized Markd::Node
		@partials : Array(Partial) | Nil = nil

		def initialize(@data, @file, @base=Dir.current, path=File.join(@base, @file))
			options = Markd::Options.new(smart: true)
			@doc = Markd::Parser.parse(@data, options)
		end

		def self.read(file, base=Dir.current)
			path = File.join(base, file)

			unless File.exists? path
				raise "File '#{file}' not found in '#{base}'."
			end

			# extract code blocks from the file
			data = File.read path

			InputFile.new(data, file, base, path)
		end

		def partials
			if partials = @partials
				partials
			else
				walker = @doc.walker
				partials = [] of Partial

				while event = walker.next
					node, entering = event

					case node.type
					when Markd::Node::Type::CodeBlock
						attr = node.fence_language.split(' ')
						body = node.text
						pos = node.source_pos
						partials << Partial.new(attr, body)
					end
				end

				@partials = partials
			end
		end
	end
end


