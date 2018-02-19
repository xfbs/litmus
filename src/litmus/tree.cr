require "./partial"
require "./code_file"
require "./input_file"
require "./loggable"

module Litmus
	# Represents a virtual file tree of `CodeFile`s, which are generated
	# from code_blocks partials
	class Tree
    include Loggable

		getter :input_files, :finalized
    @code_files = uninitialized Hash(String, CodeFile)
		@input_files = [] of InputFile
    @options = uninitialized Options
    @finalized = false

		def initialize(@options)
      @log = @options.logger

      @code_files = Hash(String, CodeFile).new do |hash, file|
        hash[file] = CodeFile.new(@log, file)
      end
		end

    # Load an input file and all of it's partials into this tree.
		def <<(input)
			@input_files << input

			input.partials.each do |partial|
				load_partial(partial)
			end

			self
		end

    # Load a partial into this tree.
    private def load_partial(partial)
      if partial.literate?
        if file = partial.file
          @code_files[file] << partial
        else
          error "No source file specified in partial at #{partial.source}."
        end
      end
		end

		# Return the `CodeFile`s of this tree as an array.
		def code_files
			@code_files.values
		end

    def finalize!
      raise "File tree already finalized" if @finalized

      @code_files.values.each do |code_file|
        code_file.resolve_partials!
      end

      @input_files.each do |input_file|
        input_file.output.transform!
      end

      @finalized = true
    end
	end
end
