module Litmus
	class Partial
		@attr = uninitialized Array(String)
		@body = uninitialized Array(String)

		def initialize(@attr, @body)
		end

		def file
			get_attrs("@")[0]?
		end

		def tags
			get_attrs("#")
		end

		def mode
			get_attrs("!")
		end

		def get_attrs(name)
			@attr
				.map{|a| a.match /^#{name}(.+)$/}
				.select{|a| !a.nil?}
				.map{|a| a.as(Regex::MatchData)[1]}
		end

		def body
			@body.join
		end
	end
end
