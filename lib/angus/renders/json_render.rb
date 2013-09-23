module JsonRender

  def self.render(response, json)
    response['Content-Type'] = 'application/json'

    response.write(JSON(json, :ascii_only => true))
  end

end