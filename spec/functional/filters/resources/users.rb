require_relative '../exceptions/user_errors'
require_relative '../models/user'

class Users < Angus::BaseResource
  before :before_filter_method, except: [:get_user]
  before { |resource| resource.before_filter_block }

  after :after_filter_method, only: [:get_users, :get_user]
  after { |resource, response| resource.after_filter_block }

  USERS = [User.new(2, 'madonna', DateTime.now, Date.today, :female)].freeze

  def get_user
    user_id = params[:user_id].to_s

    user =
      if user_id == '3'
        { id: 3 }
      else
        USERS.find { |u| u[:id] == user_id.to_i }
      end

    raise UserNotFound.new(user_id) unless user

    { profile: user }
  end

  def get_users
    { users: USERS }
  end

  def create_user
    { messages: [:UserCreatedSuccessfully] }
  end

  def delete_user
    if params[:id].to_s == '2'
      { messages: [:UserAlreadyDeleted] }
    else
      { messages: [:UserDeletedSuccessfully] }
    end
  end

  def before_filter_method; end
  def before_filter_block; end
  def after_filter_method(response); end
  def after_filter_block; end
  def exclude_filter_method; end
  def only_filter_method; end
end
