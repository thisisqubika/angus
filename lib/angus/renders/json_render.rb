module JsonRender

  def self.render(response, json)
    response['Content-Type'] = 'application/json'

    json = if json.is_a?(String)
             json
           else
             JSON(json, :ascii_only => true)
           end

    response.write(json)
  end

end