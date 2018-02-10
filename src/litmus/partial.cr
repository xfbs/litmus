module Litmus
	# Represents a partial code fragment from a code block in a litmus file,
	# which is combined with other fragments (in the order specified in the
	# fragment itself) to generate a code file.
	class Partial
		getter :attr, :body, :lang, :file, :tags, :mode

		# contstructor properties
		@attr = uninitialized Array(String)
		@body = uninitialized String
		@lines : Range(Int32, Int32) | Nil = nil

		# derived properties
		@lang : String | Nil = nil
		@file : String | Nil = nil
		@tags = uninitialized Array(String)
		@mode = uninitialized Array(String)

		def initialize(@attr, @body)
			@lang = @attr[0]?
			@file = get_attrs("@")[0]?
			@tags = get_attrs("#")
			@mode = get_attrs("!")
		end

		# Get an arbitrary attribute.
		def get_attrs(name)
			@attr
				.map{|a| a.match /^#{name}(.+)$/}
				.select{|a| !a.nil?}
				.map{|a| a.as(Regex::MatchData)[1]}
		end

		# Specify on which lines of the file this partial
		# gets rendered to.
		def set_lines(@range)
		end

		# Turn this partial into a markdown code block.
		def to_markdown(io="")
			io << "###### [][#{file}]"
			io << ", lines #{@range.begin}-#{@range.end}"
			io << "\n\n"
			io << "```#{attr[0]? || ""}"
			io << body
			io << "```"
			io
		end
	end
end
