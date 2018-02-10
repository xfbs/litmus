require "./partial"
require "./code_file"

module Litmus
	class Tree
		@files = {} of String => CodeFile

		def initialize
		end

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

		def files
			@files.values
		end

		def self.load(data)
			Tree.new.load(data)
		end
	end
end
