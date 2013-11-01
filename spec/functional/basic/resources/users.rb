class Users < Angus::BaseResource
  USERS = [{ :id => 1, :name => 'ac/dc' }, { :id => 2, :name => 'madonna' }]

  def get_user
    { :profile => USERS.find { |user| user[:id] == params[:user_id].to_i } }
  end

  def get_users
    { :users => USERS }
  end

end