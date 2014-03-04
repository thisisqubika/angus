require_relative '../models/user'


class Users < Angus::BaseResource

  USERS = [
    User.new(1, 'John Smith', 33),
    User.new(2, 'John Doe', 44)
  ]

  def show
    user = USERS.find { |user| user[:id] == params[:id].to_i }

    {:profile => user}
  end

  def index
    { :users => USERS }
  end

  def create
    user = User.new(last_id, params[:name], params[:age])

    { :user => user }
  end

  protected

  # This is not a good practice is only for testing propose. Use an
  #   autogenerated id (using db features).
  def last_id
    USERS.map {|user| user['id'] }.max + 1
  end

end