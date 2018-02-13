require "./partial"
require "./tree"
require "./output_file"
require "markd"

module Litmus
  # Represents a LitmusMarkdown input file.
	class InputFile
    getter :file, :base, :path, :partials

		@file = uninitialized String
		@data = uninitialized String
		@base = uninitialized String
		@path = uninitialized String
		@ast  = uninitialized Markd::Node
    @output   = uninitialized OutputFile
		@partials = [] of Partial

		def initialize(@data, @file, @base=Dir.current, @path=File.join(@base, @file))
			options = Markd::Options.new(smart: true)
			@ast = Markd::Parser.parse(@data, options)

      generate_partials!
      generate_output!
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
        file_parts << "gen"
      else
				file_parts.insert(-2, "gen")
			end

			file = File.join(file_parts)
		end

    # Parse and return the partials.
    private def generate_partials!
      walker = @ast.walker

      while event = walker.next
        node, entering = event

        case node.type
        when Markd::Node::Type::CodeBlock
          @partials << Partial.new(node, self)
        end
      end
		end

    private def generate_output!
      @output = OutputFile.new(out_path, @ast, @partials)
    end

    def to_output
      # fixme: clone the @doc?
      @output
    end

    # Generates a new markdown file, which is the same as the input file
    # except it has been processed.
    def to_s(io)
      @data.to_s(io)
    end
	end
end
