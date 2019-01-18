module Jekyll
  module ColophonFilter
    def add_colophon(input)
      fn_pos = input.index '<section class="footnotes">'
      lp_pos = (fn_pos) ? input.rindex('</p>', fn_pos) : input.rindex('</p>')
      output = (lp_pos) ? input.insert(lp_pos, '&nbsp;&#10042;') : input
    end
  end
end

Liquid::Template.register_filter(Jekyll::ColophonFilter)

