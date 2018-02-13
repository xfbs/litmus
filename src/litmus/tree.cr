require "./partial"
require "./code_file"
require "./input_file"

module Litmus
	# Represents a virtual file tree of `CodeFile`s, which are generated
	# from code_blocks partials
	class Tree
		getter :input_files

		@code_files = {} of String => CodeFile
		@input_files = [] of InputFile

		def initialize
		end

    # Load an input file and all of it's partials into this tree.
		def load_input(input)
			@input_files << input

			input.partials.each do |partial|
				load_partial(partial)
			end

			self
		end

    # Load a partial into this tree.
		def load_partial(partial)
      if partial.literate?
        if file = partial.file
          if !@code_files[file]?
            @code_files[file] = CodeFile.new(file)
          end

          @code_files[file].add(partial)
        else
          LOG.error "No source file specified in partial at #{partial.source}."
        end
      end
		end

		# Return the `CodeFile`s of this tree as an array.
		def code_files
			@code_files.values
		end

		# Construct a new `Tree` with the given data pre-loaded.
		def self.from(files : Array(String), base=Dir.current)
      tree = Tree.new

      files.each do |file|
        tree.load_input(InputFile.read(file, base))
      end

      tree
		end

    def update!
      @code_files.values.each do |code_file|
        code_file.resolve_partials!
      end

      @input_files.each do |input_file|
        input_file.output.transform!
      end
    end
	end
end
