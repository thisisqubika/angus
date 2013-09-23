module HtmlRender

  def self.render(response, html)
    response['Content-Type'] = 'text/html'

    response.write(html)
  end

end