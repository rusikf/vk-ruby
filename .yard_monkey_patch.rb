require 'redcarpet'

# выкинуть после публикации гема с этой строчкой кода
# https://github.com/lsegal/yard/blob/master/lib/yard/templates/helpers/html_helper.rb#L57

module YARD::Templates::Helpers::HtmlHelper

  def html_markup_markdown(text)
    provider = markup_class(:markdown)

    if provider.to_s == 'RDiscount'
      provider.new(text, :autolink).to_html
    elsif provider.to_s == 'RedcarpetCompat'
      provider.new(text, :no_intraemphasis, :gh_blockcode,
                         :fenced_code, :autolink, 
                         :tables, #
                         :lax_spacing).to_html
    else
      provider.new(text).to_html
    end
  end

end