RSpec::Matchers.define :have_in_message do |expected_message|
  match do |response|
    begin
      @json = JSON.parse(response.body)
      is_valid_response?(expected_message)
    rescue JSON::ParserError => exception
      @error = "Error while parsing response: #{exception.message}"
      false
    end
  end

  description do
    "have in message #{expected_message.inspect}"
  end

  failure_message do
    if @error
      @error
    elsif @json && @json['messages']
      "expected #{@json['messages']} to include #{expected_message}"
    else
      "expected #{@json.inspect} to include messages in its keys"
    end
  end

  failure_message_when_negated do
    if @error
      @error
    elsif @json && @json['messages']
      "expected #{@json['messages']} not to include #{expected_message}"
    else
      "expected #{@json.inspect} to include messages in its keys"
    end
  end

  def is_valid_response?(expected_message)
    return false unless @json && @json['messages']

    @actual   = @json['messages']
    @expected = expected_message

    @actual.include?(@expected)
  end
end
