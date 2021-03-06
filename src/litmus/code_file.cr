require "./partial"

module Litmus
  # Represents a code file, that is built from `Partial`s in the `InputFile`s
  # and forms, along with other files, the index.
	class CodeFile
		getter :file

    # Path of this codefile
		@file = uninitialized String

    # Body, represented as list of partials.
		@body = [] of Partial

    @log = uninitialized Logger

		def initialize(@log, @file)
		end

    # Convenience method to add a partial.
    def <<(partial)
      add(partial)
    end

    # Add a partial to this CodeFile.
		def add(partial) : Int32?
      if partial.replace
        add_replace(partial)
      elsif !partial.before?
        add_after(partial)
      elsif !partial.after?
        add_before(partial)
      else
        @log.error "Partial at #{partial.source} specified both 'before' and 'after' modes."
        nil
      end
		end

    # Adds a partial in 'after' mode.
    private def add_after(partial)
      if partial.pad
        _, base_tag_len = resolve(partial.tags)
        padding = partial.to_padding
        padding.tags = padding.tags[0...base_tag_len]
        pos = self << padding
        @body.insert(pos.as(Int32) + 1, partial)
        return
      end

      base, tag_match_len = resolve(partial.tags)

      if partial.after?.try{|t| t.size != 0}
        matched_tags = partial.tags[0...tag_match_len]

        partial.after?.try do |tags|
          tags.each do |tag|
            matched_tags << tag
          end
        end

        base, matched_tags_matches = resolve(matched_tags)

        if matched_tags_matches == tag_match_len
          match_error(partial, "after", matched_tags, matched_tags_matches)
        elsif matched_tags_matches < matched_tags.size
          match_warning(partial, "after", matched_tags, matched_tags_matches)
        end
      end

      @body.insert(base.end, partial)
      base.end
    end

    private def match_error(partial, mode, tags, match_len)
      @log.error "Couldn't match any of the tags "\
        "specified in '#{mode}' mode of partial at #{partial.source}: "\
        "no match for tags '#{tags.map{|t| "##{t}"}.join(' ')}', ignoring "\
        "tags '#{tags[match_len..-1].map{|t| "##{t}"}.join(' ')}'."
    end

    private def match_warning(partial, mode, tags, match_len)
      @log.warn "Couldn't match some of the tags "\
        "specified in '#{mode}' mode of partial at #{partial.source}: "\
        "no match for tags '#{tags.map{|t| "##{t}"}.join(' ')}', ignoring "\
        "tags '#{tags[match_len..-1].map{|t| "##{t}"}.join(' ')}'."
    end

    # Adds a partial an 'before' mode.
    private def add_before(partial)
      base, tag_match_len = resolve(partial.tags)

      if partial.before?.try{|t| t.size != 0}
        matched_tags = partial.tags[0...tag_match_len]

        partial.before?.try do |tags|
          tags.each do |tag|
            matched_tags << tag
          end
        end

        base, matched_tags_matches = resolve(matched_tags)

        if matched_tags_matches == tag_match_len
          match_error(partial, "before", matched_tags, matched_tags_matches)
        elsif matched_tags_matches < matched_tags.size
          match_warning(partial, "before", matched_tags, matched_tags_matches)
        end
      end

      @body.insert(base.begin, partial)
      base.begin
    end

    # Adds a partial in replace mode
    private def add_replace(partial)
      base, match_depth = resolve(partial.tags)
      first, last = base.begin, base.end

      if after = partial.after?
        after_tags = partial.tags[0...match_depth]
        after_tags += after
        after_base, depth = resolve(after_tags)

        if depth == match_depth
          match_error(partial, "after", after_tags, depth)
        elsif depth < after_tags.size
          match_warning(partial, "after", after_tags, depth)
        end

        first = after_base.end
      end

      if before = partial.before?
        before_tags = partial.tags[0...match_depth]
        before_tags += before
        before_base, depth = resolve(before_tags)

        if depth == match_depth
          match_error(partial, "before", before_tags, depth)
        elsif depth < before_tags.size
          match_warning(partial, "before", before_tags, depth)
        end

        last = before_base.begin
      end

      num_to_replace = last - first

      if num_to_replace < 0
        @log.error "Illegal bounds in 'replace' mode of partial at #{partial.source}, "\
          "skipping partial."
        return
      else
        if num_to_replace == 0
          @log.warn "Bounds in 'replace' mode of partial at #{partial.source} too restrictive: "\
            "nothing will be replaced."
        end

        num_to_replace.times do
          @body.delete_at(first)
        end
      end

      @body.insert(first, partial)
      first
    end

    # Resolve some tags into a matching range and a depth.
    private def resolve(tags=[] of String)
      tags.size.downto(1) do |tsize|
        # find first partial that matches the tags
				first = @body.each_with_index
          .find(nil){|p| (0...tsize).all?{|n| p[0].tags[n]? == tags[n]?}}.try{|r| r[1]}

        last = @body.size
        if first
          last = @body.each_with_index.skip(first)
            .find({nil, last}){|p| (0...tsize).any?{|n| p[0].tags[n]? != tags[n]?}}[1]
        end

				if first
          return {first...last, tsize}
				end
			end

      return {0...@body.size, 0}
		end

    # Renders this partial.
    def to_s(io)
      @body.each do |partial|
        partial.body.each do |line|
          first = false
          io << line
          io << "\n"
        end
      end

      io
    end

    # Todo
    def resolve_partials!
      line = 0

      @body.each do |partial|
        partial.set_dest(line...line+partial.body.size)
        line += partial.body.size
      end
    end
	end
end
