require_relative '../exceptions/user_errors'
require_relative '../models/user'


class Users < Angus::BaseResource
  USERS = [{ :id => 1, :name => 'ac/dc', 'last_login' => DateTime.now, :birth_date => Date.today,
             :gender => :male, :roles => [1, 2, 3] },
           User.new(2, 'madonna', DateTime.now, Date.today, :female)]

  def get_user
    user = if params[:user_id] == '3'
             { :id => 3 }
           else
             USERS.find { |user| user[:id] == params[:user_id].to_i }
           end

    raise UserNotFound.new(params[:user_id]) unless user

    { :profile => user }
  end

  def get_users
    { :users => USERS }
  end

  def create_user
    { :messages => [:UserCreatedSuccessfully] }
  end

  def delete_user
    if params[:id] == '2'
      { :messages => [:UserAlreadyDeleted] }
    else
      { :messages => [:UserDeletedSuccessfully] }
    end
  end
end