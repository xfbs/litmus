module Litmus
	# Represents a partial code fragment from a code block in a litmus file,
	# which is combined with other fragments (in the order specified in the
	# fragment itself) to generate a code file.
	class Partial
		@attr = uninitialized Array(String)
		@body = uninitialized Array(String)
		@lines : Range(Int32, Int32) | Nil = nil

		def initialize(@attr, @body)
		end

		# Which file does this partial belong to?
		def file
			get_attrs("@")[0]?
		end

		# Which tags (selectors) does this partial have?
		def tags
			get_attrs("#")
		end

		# Which modes does this partial specify?
		def mode
			get_attrs("!")
		end

		# Get an arbitrary attribute.
		def get_attrs(name)
			@attr
				.map{|a| a.match /^#{name}(.+)$/}
				.select{|a| !a.nil?}
				.map{|a| a.as(Regex::MatchData)[1]}
		end

		# Returns the body (code) of the partial
		def body
			@body.join
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
