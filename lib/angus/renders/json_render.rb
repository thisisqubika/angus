module JsonRender

  def self.convert(json)
    if json.is_a?(String)
       json
     else
       JSON(json, :ascii_only => true)
     end
  end

  def self.render(response, json)
    response['Content-Type'] = 'application/json'

    response.write(convert(json))
  end

end