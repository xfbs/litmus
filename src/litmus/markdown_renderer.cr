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
        contents << prefix("> ", handle(child))
      end

      io << contents.join("\n> \n")
    end

    handle Type::Code do |node, io|
      # todo: escape backticks in code.
      io << "`"
      io << node.text
      io << "`"
    end

    handle Type::CodeBlock do |node, io|
      if node.fenced?
        io << "```"
        if language = node.fence_language
          io << language
        end
        io << "\n"
        io << node.text
        io << "```"
      else
        prefix("    ", node.text.chomp, io)
      end
    end
  end
end

