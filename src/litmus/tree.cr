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

		# Load the given code_blocks into this tree.
		def load_input(input)
			@input_files << input

			input.partials.each do |partial|
				load_partial(partial)
			end

			self
		end

		def load_partial(partial)
			file = partial.file

			if file
				if !@code_files[file]?
					@code_files[file] = CodeFile.new(file)
				end

				@code_files[file].add(partial)
			else
				puts "Error: no filename specified for partial: \n#{partial.inspect}"
			end
		end

		# Return the `CodeFile`s of this tree as an array.
		def code_files
			@code_files.values
		end

		# Construct a new `Tree` with the given data pre-loaded.
		def self.from(file : String, base=Dir.current)
			Tree.new.load_input(InputFile.read(file, base))
		end
	end
end
