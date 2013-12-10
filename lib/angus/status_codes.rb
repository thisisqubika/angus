module Angus
  module StatusCodes

    # TODO remove HTTP_STATUS from all constants
    HTTP_STATUS_CODE_OK                     = 200

    HTTP_STATUS_CODE_FORBIDDEN              = 403
    HTTP_STATUS_CODE_NOT_FOUND              = 404
    HTTP_STATUS_CODE_CONFLICT               = 409
    HTTP_STATUS_CODE_UNPROCESSABLE_ENTITY   = 422

    HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR  = 500

    def self.included(base)
      self.constants.each do |const|
        unless base.const_defined?(const)
          base.const_set(const, self.const_get(const))
        end
      end
    end

  end
end