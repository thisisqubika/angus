module HtmlRender

  def self.render(response, html)
    response['Content-Type'] = 'text/html;charset=utf-8'

    response.write(html)
  end

end