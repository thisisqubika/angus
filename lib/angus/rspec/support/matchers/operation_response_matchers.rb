require 'rspec'

RSpec::Matchers.define :have_no_data do
  match do |operation_response|
    operation_response.body == {}
  end

  failure_message_for_should do |operation_response|
    "expected that #{operation_response.body} would be {}"
  end

  failure_message_for_should_not do |operation_response|
    "expected that #{operation_response.body} would not be {}"
  end

  description do
    "have no data"
  end
end

RSpec::Matchers.define :be_success do
  match do |operation_response|
    operation_response.success?
  end

  failure_message_for_should do |operation_response|
    "expected that (#{operation_response.http_status_code}, #{operation_response.status}) would be (200, success)"
  end

  failure_message_for_should_not do |operation_response|
    "expected that (#{operation_response.http_status_code}, #{operation_response.status}) would not be (200, success)"
  end

  description do
    "be a (200, success) response"
  end
end

RSpec::Matchers.define :be_unauthorized do
  match do |operation_response|
    operation_response.unauthorized?
  end

  failure_message_for_should do |operation_response|
    "expected that (#{operation_response.http_status_code}, #{operation_response.status}) would be (401, unauthorized)"
  end

  failure_message_for_should_not do |operation_response|
    "expected that (#{operation_response.http_status_code}, #{operation_response.status}) would not be (401, unauthorized)"
  end

  description do
    'be a (401, unauthorized) response'
  end
end

RSpec::Matchers.define :be_forbidden do
  match do |operation_response|
    operation_response.forbidden?
  end

  failure_message_for_should do |operation_response|
    "expected that (#{operation_response.http_status_code}, #{operation_response.status}) would be (403, error)"
  end

  failure_message_for_should_not do |operation_response|
    "expected that (#{operation_response.http_status_code}, #{operation_response.status}) would not be (403, error)"
  end

  description do
    "be a (403, error) response"
  end
end

RSpec::Matchers.define :contain_message do |level = nil, key = nil, description = nil|
  match do |operation_response|
    operation_response.messages.find do |message|
      level_and_key_matches = message['level'] == level.to_s && message['key'] == key

      description_matches = true

      if level_and_key_matches && description.present?
        description_matches = message['dsc'] == description
      end

      level_and_key_matches && description_matches
    end
  end

  failure_message_for_should do |operation_response|
    "message expected to contain #{level}, #{key}, #{description}"
  end

  failure_message_for_should_not do |operation_response|
    "message expected to not contain #{level}, #{key}, #{description}"
  end

  description do
    "contains a message"
  end
end

RSpec::Matchers.define :contain_element do |name, *value|
  match do |operation_response|
    if value.empty?
      operation_response.body.include?(name.to_s)
    else
      # we only take into account the first received value
      first_value = value.first
      operation_response.body[name.to_s] == first_value
    end
  end

  failure_message_for_should do |operation_response|
    message = "response expected to contain #{name}"
    if !value.empty?
      message += " = #{value}"
    end

    message
  end

  failure_message_for_should_not do |operation_response|
    message = "response expected not to contain #{name}"
    if !value.empty?
      message += " = #{value}"
    end

    message
  end

  description do
    "contains an element"
  end
end
