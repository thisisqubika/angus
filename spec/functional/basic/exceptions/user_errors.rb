class UserNotFound < StandardError
  def initialize(id)
    @id = id
  end

  def message
    "User with id=#@id not found"
  end
end