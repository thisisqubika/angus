require_relative '../exceptions/user_errors'
require_relative '../models/user'

class Users < Angus::BaseResource

  before :before_filter_method, :exclude => [:get_user]
  before { |resource| resource; resource.before_filter_block }

  after :after_filter_method, :only => [:get_users, :get_user]
  after { |resource, response| resource.after_filter_block }

  USERS = [User.new(2, 'madonna', DateTime.now, Date.today, :female)]

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

  def before_filter_method; end

  def before_filter_block; end

  def after_filter_method(response); end

  def after_filter_block; end

  def exclude_filter_method; end

  def only_filter_method; end

end