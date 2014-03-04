RSpec::Matchers.define :have_error_response do

  match do |response|
    begin
      @json = JSON(response.body)

      is_valid_response?
    rescue JSON::ParserError => exception
      @error = "Error will parsing response: #{exception.message}"
    end
  end

  description do
    'have error response'
  end

  failure_message_for_should do
    if @error
      @error
    elsif @json && @json['status']
      "expect #{@json['status']} to be error"
    else
      "expect #{@json} to include status in it's keys"
    end
  end

  failure_message_for_should_not do
    if @error
      @error
    elsif @json && @json['status']
      "expect #{@json['status']} to not be error"
    else
      "expect #{@json} to include status in it's keys"
    end
  end

  def is_valid_response?
    @json && @json['status'] == 'error'
  end
end