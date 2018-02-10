require "./partial"
require "./tree"
require "markd"

module Litmus
	# Parses a given litmus file and returns a tree from it.
	def self.parse(options, filename)
		# load a file tree from the partials
		Tree.from(filename, options["basedir"])
	end
end
