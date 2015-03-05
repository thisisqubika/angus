require 'json'

require 'angus/responses'

# Wraps the response return from an operation invocation
class OperationResponse

  def initialize(rack_response)
    @rack_response = rack_response
    @parsed_response = JSON(rack_response.body)
  end

  def body
    @parsed_response
  end

  def messages
    @parsed_response['messages'] || []
  end

  def wraps?(rack_response)
    @rack_response == rack_response
  end

  def success?
    @parsed_response['status'] == 'success' &&
      http_status_code == Angus::Responses::HTTP_STATUS_CODE_OK
  end

  def unauthorized?
    @parsed_response['status'] == 'error' &&
      http_status_code == Angus::Responses::HTTP_STATUS_CODE_UNAUTHORIZED
  end

  def forbidden?
    @parsed_response['status'] == 'error' &&
      http_status_code == Angus::Responses::HTTP_STATUS_CODE_FORBIDDEN
  end

  def not_found?
    @parsed_response['status'] == 'error' &&
      http_status_code == Angus::Responses::HTTP_STATUS_CODE_NOT_FOUND
  end

  def conflict?
    @parsed_response['status'] == 'error' &&
      http_status_code == Angus::Responses::HTTP_STATUS_CODE_CONFLICT
  end

  def unprocessable_entity?
    @parsed_response['status'] == 'error' &&
      http_status_code == Angus::Responses::HTTP_STATUS_CODE_UNPROCESSABLE_ENTITY
  end

  def http_status_code
    @rack_response.status
  end

  def status
    @parsed_response['status']
  end
end
