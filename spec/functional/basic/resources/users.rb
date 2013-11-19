require_relative '../exceptions/user_errors'

class Users < Angus::BaseResource
  USERS = [{ :id => 1, :name => 'ac/dc' }, { :id => 2, :name => 'madonna' }]

  def get_user
    user = USERS.find { |user| user[:id] == params[:user_id].to_i }

    raise UserNotFound.new(params[:user_id]) unless user

    { :profile => user }
  end

  def get_users
    { :users => USERS }
  end

end