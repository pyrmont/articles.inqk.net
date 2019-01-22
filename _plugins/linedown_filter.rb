module Jekyll
  module LinedownFilter
    def linedownify(input)
      @context.registers[:site].
        find_converter_instance(Jekyll::Converters::Markdown).
        convert(input.to_s).gsub(/<\/?p>/,'')
    end
  end
end

Liquid::Template.register_filter(Jekyll::LinedownFilter)

