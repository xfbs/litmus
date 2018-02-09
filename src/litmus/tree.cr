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
				file = partial.file_name

				if file
					if !@files[file]?
					  @files[file] = CodeFile.new(file)
					end

					@files[file].add(partial)
				else
					puts "Error: can't associate code block with a file:\n#{partial.inspect}"
				end
			end
			self
		end

		def self.load(data)
			Tree.new.load(data)
		end
	end
end
