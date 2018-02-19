require "markd"
require "./partial"

module Litmus
  # Describes a markdown-formatted output file that is generated from an input
  # file by parsing it, and transforming the AST to insert information about
  # the partials (this is necessary to show line numbers, for example).
  class OutputFile
    # keeps it's own path (generated from the path of the input file), the ast,
    # the partials in this file (parsed from the input file) and whether or not
    # the ast has already been transformed.
    getter :path, :ast, :partials
    @path         = uninitialized String
    @ast          = uninitialized Markd::Node
    @partials     = uninitialized Array(Partial)
    @transformed  = false

    def initialize(@path, @ast, @partials)
    end

    # Transforms the AST to generate an output file.
    def transform!
      # make sure that this is not accidentally transformed twice.
      if @transformed
        raise "The OutputFile '#{@path}' has already been transformed."
      else
        @transformed = true
      end

      # create a hash of nodes to which partial they belong to, because in the
      # next steps we'll be looking up a lot of nodes and this way is faster
      # than searching the partials array each time.
      known_nodes = {} of Markd::Node => Partial
      partials.each do |partial|
        known_nodes[partial.node] = partial
      end

      # collect all the nodes that we will have to transform into an array.
      # it's not smart to transform them in-place because I'm not sure the
      # Node::Walker was written with that in mind.
      to_transform = [] of Tuple(Markd::Node, Partial)
      walker = @ast.walker
      while state = walker.next
        current, entering = state

        # check if this is a known node
        if partial = known_nodes[current]?
          to_transform << {current, partial} if partial.literate?
        end
      end

      # transform each node, individually.
      to_transform.each do |node, partial|
        transform_node(node, partial)
      end
    end

    # Transforms a single node that belongs to a partial by replacing it with
    # whatever the partial dictates.
    private def transform_node(node : Markd::Node, partial : Partial)
      transformed = partial.to_markdown

      if transformed
        replace(node, transformed)
      else
        node.unlink
      end
    end

    # Replaces one node with another.
    def replace(old : Markd::Node, new : Markd::Node)
      new.next = old.next?
      new.prev = old.prev?
      new.parent = old.parent

      if prev = old.prev?
        prev.next = new
      else
        new.parent?.try {|parent| parent.first_child = new}
      end

      if nextn = old.next?
        nextn.prev = new
      else
        new.parent?.try {|parent| parent.last_child = new}
      end
    end

    # Generates a new markdown file, which is the same as the input file
    # except it has been processed.
    def to_s(io)
      renderer = MarkdownRenderer.new
      renderer.render(@ast).to_s(io)
    end
  end
end
