RSpec::Matchers.define :have_in_message do |expected_message|

  match do |response|
    begin
      @json = JSON(response.body)

      is_valid_response?(expected_message)
    rescue JSON::ParserError => exception
      @error = "Error will parsing response: #{exception.message}"
    end
  end

  description do
    "have in message #{expected_message.inspect}"
  end

  failure_message_for_should do
    if @error
      @error
    elsif @json && @json['messages']
      "expect #{@json['messages']} to include #{expected_message}"
    else
      "expect #{@json} to include messages in it's keys"
    end
  end

  failure_message_for_should_not do
    if @error
      @error
    elsif @json && @json['messages']
      "expect #{@json['messages']} not to include #{expected_message}"
    else
      "expect #{@json} to include messages in it's keys"
    end
  end

  def is_valid_response?(expected_message)
    if @json && @json['messages']
      @actual   = @json['messages']
      @expected = expected_message

      @actual.include?(@expected)
    else
      false
    end
  end
end