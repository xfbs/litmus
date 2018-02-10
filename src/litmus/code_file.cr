require "./partial"

module Litmus
	class CodeFile
		getter :file

		@file = uninitialized String
		@body = [] of Partial

		def initialize(@file)
		end

		def add(partial)
			tags = partial.tags

			unless partial.mode.size > 0
				append(partial, tags)
				return
			end

			partial.mode.each do |m|
				unless parsed = m.match(/^([a-z]+)(?:\[(-?[0-9]+)(?:\.\.(-?[0-9]+)+)?\])?$/)
					puts "Error: can't parse #{m}"
					next
				end

				cmd = parsed[1]?
				range_start = parsed[2]?.try &.to_i
				range_end = parsed[3]?.try &.to_i || range_start

				range = nil
				range = Range.new(range_start, range_end) if range_end

				case cmd
				when "append"
					append(partial, tags, range)
				when "prepend"
					prepend(partial, tags, range)
				when "insert"
					insert(partial, tags, range)
				when "replace"
					replace(partial, tags, range)
				else
					raise "Error: illegal mode encountered: #{m}"
				end
			end
		end

		def append(partial, tags=[] of String, pos=nil)
			@body << partial
		end

		def prepend(partial, tags=[] of String, pos=nil)
		end

		def insert(partial, tags=[] of String, pos=nil)
		end

		def replace(partial, tags=[] of String, pos=nil)
		end

		def select(tags=[] of String)
		end

		def render
			@body.map{|p| p.body}.join
		end
	end
end
