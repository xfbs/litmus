module Litmus
	class Partial
		@attr = uninitialized Array(String)
		@code = uninitialized Array(String)

		def initialize(@attr, @code)
		end

		def file_name
			names = get_attrs("file")
			names[0]?
		end

		def type_name
			types = get_attrs("type")
			types[0]?
		end

		def tags
			get_attrs("tag")
		end

		def get_attrs(name)
			@attr
				.map{|a| a.match /^#{name}:(.+)$/}
				.select{|a| !a.nil?}
				.map{|a| a.as(Regex::MatchData)[1]}
		end
	end
end
