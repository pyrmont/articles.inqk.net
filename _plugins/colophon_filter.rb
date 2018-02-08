module Jekyll
  module ColophonFilter
    def colophon(input)
      fn_pos = input.index '<div class="footnotes">'
      lp_pos = (fn_pos) ? input.rindex('</p>', fn_pos) : input.rindex('</p>')
      output = (lp_pos) ? input.insert(lp_pos, ' &#10042;') : input
    end
  end
end

Liquid::Template.register_filter(Jekyll::ColophonFilter)

