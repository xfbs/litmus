require "markdown/renderer"

module Litmus
	class Extracter
		include Markdown::Renderer
		getter :code_blocks

		@cur_block = nil
		@code_blocks = [] of Hash(String, Array(String))

		def initialize()
		end

		def begin_code(lang)
			lang = lang || ""
			@cur_block = {"attr" => lang.split(" "), "code" => [] of String}
		end

		def end_code
			if block = @cur_block
				@code_blocks << block
			else
				raise "end_code called without begin_code - oops"
			end
		end

		def text(text)
			if block = @cur_block
				block["code"] << text
			end
		end

		def begin_paragraph; end
		def end_paragraph; end
		def begin_italic; end
		def end_italic; end
		def begin_bold; end
		def end_bold; end
		def begin_header(level); end
		def end_header(level); end
		def begin_inline_code; end
		def end_inline_code; end
		def begin_quote; end
		def end_quote; end
		def begin_unordered_list; end
		def end_unordered_list; end
		def begin_ordered_list; end
		def end_ordered_list; end
		def begin_list_item; end
		def end_list_item; end
		def begin_link(url); end
		def end_link; end
		def image(url, alt); end
		def horizontal_rule; end
	end
end
