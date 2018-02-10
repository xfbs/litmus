require "./partial"
require "./code_file"

module Litmus
	# Represents a virtual file tree of `CodeFile`s, which are generated
	# from code_blocks partials
	class Tree
		@files = {} of String => CodeFile

		def initialize
		end

		# Load the given code_blocks into this tree.
		def load(code_blocks)
			code_blocks.each do |cblk|
				partial = Partial.new(cblk["attr"], cblk["code"])
				file = partial.file

				if file
					if !@files[file]?
					  @files[file] = CodeFile.new(file)
					end

					@files[file].add(partial)
				else
					puts "Error: no filename specified for partial: \n#{partial.inspect}"
				end
			end
			self
		end

		# Return the `CodeFile`s of this tree as an array.
		def files
			@files.values
		end

		# Construct a new `Tree` with the given data pre-loaded.
		def self.load(data)
			Tree.new.load(data)
		end
	end
end
