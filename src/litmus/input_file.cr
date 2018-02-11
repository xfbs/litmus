require "./partial"
require "./tree"
require "markd"

module Litmus
  # Represents a LitmusMarkdown input file.
	class InputFile
    getter :file, :base, :path
		@file = uninitialized String
		@data = uninitialized String
		@base = uninitialized String
		@path = uninitialized String
		@doc = uninitialized Markd::Node
		@partials : Array(Partial) | Nil = nil

		def initialize(@data, @file, @base=Dir.current, @path=File.join(@base, @file))
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

		# Generates a path for the processed inputfile.
    #
    # Input files should be named `file.lit.md`, which will generate
    # a file with the same name but without the `lit`, in this case
    # `file.md`. If the files aren't named like this, this function
    # will improvise.
    #
    # `yourfile.lit.md` => `yourfile.md`
    # `yourfile.md`     => `yourfile.gen.md`
    # `yourfile`        => `yourfile.gen`
		def out_path
      file_parts = @file.split('.')

			pos_lit = file_parts.reverse.index{|part| part == "lit"}

			if pos_lit && pos_lit != 0
				file_parts.delete_at(pos_lit)
      elsif pos_lit == 1
        pos_list << "gen"
      else
				file_parse.insert(-2, "gen")
			end

			file = File.join(file_parts)
			File.expand_path(file, @base)
		end

    # Parse and return the partials.
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
						partials << Partial.new(node, self)
					end
				end

				@partials = partials
			end
		end

    # Generates a new markdown file, which is the same as the input file
    # except it has been processed.
    def generate
      known_nodes = {} of Markd::Node => Partial
      partials.each do |partial|
        known_nodes[partial.node] = partial
      end

      walker = @doc.walker
      while state = walker.next
        current, entering = state

        # check if this is a known node
        if partial = known_nodes[current]?
          # process partial
        end
      end

      renderer = MarkdownRenderer.new
      renderer.render(@doc).to_s
    end
	end
end


