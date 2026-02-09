RSpec::Matchers.define :have_error_response do
  match do |response|
    begin
      @json = JSON.parse(response.body)
      is_valid_response?
    rescue JSON::ParserError => exception
      @error = "Error while parsing response: #{exception.message}"
      false
    end
  end

  description do
    'have error response'
  end

  failure_message do
    if @error
      @error
    elsif @json && @json['status']
      "expected #{@json['status']} to be error\n#{@json.inspect}"
    else
      "expected #{@json.inspect} to include status in its keys"
    end
  end

  failure_message_when_negated do
    if @error
      @error
    elsif @json && @json['status']
      "expected #{@json['status']} not to be error\n#{@json.inspect}"
    else
      "expected #{@json.inspect} to include status in its keys"
    end
  end

  def is_valid_response?
    @json && @json['status'] == 'error'
  end
end
