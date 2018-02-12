require "./partial"

module Litmus
  # Represents a code file, that is built from `Partial`s in the `InputFile`s
  # and forms, along with other files, the index.
	class CodeFile
		getter :file

    # Path of this codefile
		@file = uninitialized String

    # Body, represented as list of partials.
		@body = [] of Partial

		def initialize(@file)
		end

    # Convenience method to add a partial.
    def <<(partial)
      @body << partial
    end

    # Add a partial to this CodeFile.
		def add(partial)
      self << partial
		end

		def find_by_tags(tags=[] of String)
			loop do
				selected = @body
					.each_with_index
					.select{|c| (0...tags.size).all?{|n| c[0].tags[n]? == tags[n]?}}
					.map{|c| c[1]}
					.to_a

				if selected.size != 0 || tags.size == 0
					return selected.to_a
				end

				tags = tags[0..-2]
			end
		end

    # Renders this partial.
    def to_s(io)
      @body.each do |partial|
        io << partial.body
      end

      io
    end
	end
end
