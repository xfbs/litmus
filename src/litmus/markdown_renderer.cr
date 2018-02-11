require "./markd_renderer"

module Litmus
  class MarkdownRenderer < MarkdRenderer
    handle Type::Document do |node, io|
      contents = [] of IO

      children(node) do |child|
        contents << handle(child)
      end

      # make sure there is spacing between content.
      io << contents.join("\n\n")
    end

    handle Type::Heading do |node, io|
      contents = [] of IO

      # build header
      level = node.data["level"]
      level = 1 unless level.is_a? Int
      header = "#" * level + " "
      contents << IO::Memory.new(header)

      # gather header text
      children(node) do |child|
        contents << handle(child)
      end

      io << contents.join
    end

    handle Type::Paragraph do |node, io|
      contents = [] of IO

      children(node) do |child|
        contents << handle(child)
      end

      io << contents.join
    end

    handle Type::Text do |node, io|
      io << node.text
    end

    handle Type::BlockQuote do |node, io|
      contents = [] of IO

      children(node) do |child|
        content = IO::Memory.new
        content << "> "
        content << handle(child).to_s.split("\n").join("\n> ")
        contents << content
      end

      io << contents.join("\n> \n")
    end
  end
end

