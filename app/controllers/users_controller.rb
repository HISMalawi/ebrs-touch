class UsersController < ApplicationController

  #Displays User Management Section
  def index

    @icoFolder = icoFolder("icoFolder")
    #raise @icoFolder.inspect
    @section = "User Management"

    @targeturl = "/"

    @targettext = "Finish"

    render :layout => "facility"
  end

  #Displays The Created User
  def show

    @section = "View User"

    @user = User.find(params[:id])

    @person_name = PersonName.find_by_person_id(@user.person_id)

    @user_role = @user.user_role.role

    @targeturl = "/view_users"

    render :layout => "facility"

  end

  #Displays All Users whose status = Active
  def view

    @users = User.where(location_id: SETTINGS['location_id'])

    @section = "View Users"

    @targeturl = "/users"

    render :layout => "data_table"

  end

  #Adds A New User
  def new

    @user = User.new

    @section = "Create User"

    @targeturl = "/users"

    if application_mode == "DC"
       @roles = Role.where(level: "DC").map(&:role)
    else
       @roles = Role.where(level: "FC").map(&:role)
    end

    render :layout => "touch"

  end

  # Edits Selected User
  def edit

    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Update User"))

    @user = User.find(params[:id])

    @section = "Edit User"

    @targeturl = "/view_users"

    if application_mode == "DC"
       @roles = [''] + Role.where(level: "DC").map(&:role)
    else
       @roles = [''] + Role.where(level: "FC").map(&:role)
    end

    @role = @user.user_role.role.role

    render :layout => "touch"

  end

  #Creates A New User
  def create

      @targeturl = "/user"

      similar_users = User.where(username: params[:user]['username'], location_id: SETTINGS['location_id'])
      if similar_users.count > 0
        raise "User with Username = #{params[:user]['username']} Already Exists, Please Try Another Username".to_s
      end

      core_person = CorePerson.create(person_type_id: PersonType.where(:name => 'User').last.id)
      person_name = PersonName.create(person_id: core_person.person_id,
                                  first_name: params[:user][:first_name],
                                  last_name: params[:user][:last_name])

      person_name_code = PersonNameCode.create(person_name_id: person_name.person_name_id,
                                           first_name_code: params[:user][:first_name].soundex,
                                           last_name_code: params[:user][:last_name].soundex)

      role = Role.where("role = ? AND level = ?",
                    params[:user]['user_role']['role'],
                    application_mode == "DC" ? "DC" : "FC").first

      @user = User.create(username: params[:user]['username'],
                      password: params[:user]['password'],
                      creator: User.current.user_id,
                      person_id: core_person.person_id,
                      last_password_date: Time.now,
                      email: params[:user]['email'])

      @user_role = UserRole.create(user_id: @user.id,
                               role_id: role.id)

      respond_to do |format|
        if @user.present?
              format.html { redirect_to @user, :notice => 'User was successfully created.' }
              format.json { render :show, :status => :created, :location => @user }
        else
              format.html { render :new }
              format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
    end
  end

  def update

    @user = User.find(params[:id])

    if request.referrer.match('edit_account')
      @user.preferred_keyboard = params[:user][:preferred_keyboard]
      @user.save!
      redirect_to '/users/my_account' and return
    end

    if params[:user][:plain_password].present? && params[:user][:plain_password].length > 1
      @user.update_attributes(password_hash: params[:user][:plain_password],
        password_attempt: 0, last_password_date: Time.now)
    end

    respond_to do |format|
      role = User.current.user_role.role.role
      if ((role.strip.downcase.match(/Administrator/i) rescue false) ? true : false) and @user.update_attributes(user_params)

        if params[:user][:first_name].present? && params[:user][:last_name].present?
          @user.core_person.person_name.update_attributes(voided: true, void_reason: 'Edited')
          person_name = PersonName.create(person_id: @user.person_id,
            first_name: params[:user][:first_name],
            last_name: params[:user][:last_name])

          PersonNameCode.create(person_name_id: person_name.person_name_id,
            first_name_code: params[:user][:first_name].soundex,
            last_name_code: params[:user][:last_name].soundex )
        end

        if (params[:user][:user_role][:role].present? rescue false)
            role=@user.user_role.update_attributes(
                role_id: Role.where(role: params[:user][:user_role][:role]).last.id
            )
        end

        if @user.present?
          format.html { redirect_to @user, :notice => 'User was successfully updated.' }
          format.json { render :show, :status => :ok, :location => @user }
        else
          format.html { render :edit }
          format.json { render :json => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end


  #Displays All Users
  def query_users

    results = []

    users = User.where(location_id: SETTINGS['location_id'])
      users.each do |user|
    	next if user.core_person.blank? || user.core_person.person_name.blank?

    	record = {
          	"username" => "#{user.username}",
          	"name" => "#{user.core_person.person_name.first_name} #{user.core_person.person_name.last_name}",
          	"role" => "#{user.user_role.role.role}",
          	"user_id" => "#{user.user_id}",
         	"active" => (user.active rescue false)
      	    	}

      	results << record
    end

    render :text => results.to_json
  end

  #Deletes Selected User
  def destroy

    if ((User.current.user_role.role.role.strip.downcase.match(/Administrator/i) rescue false) ? true : false)
      @user.update_attributes(voided: true)
    end

    respond_to do |format|
      format.html { redirect_to "/view_users", :notice => 'User was successfully destroyed.' }
      format.json { head :no_content }
    end

  end

  #Revokes User Access Rights
  def block

    @users = User.all.each

    @section = "Block User"

    @targeturl = "/users"

    render :layout => "facility"

  end

  #Gives Back Bloked User Access Rights
  def unblock

    @users = User.all.each

    @section = "Unblock User"

    @targeturl = "/users"

    render :layout => "facility"

  end

  #Revokes User Access Rights
  def block_user

    user = User.find(params[:id]) rescue nil

    if !user.nil?
      role = User.current.user_role.role.role.strip rescue nil
      if ((role.downcase.match(/Administrator/i) rescue false) ? true : false)
        user.update_attributes(active: false,
          :un_or_block_reason => params[:reason])
      end
    end

    redirect_to "/view_users" and return

  end

  #Gives Back Bloked User Access Rights
  def void_user

    user = User.find(params[:id]) rescue nil

    if !user.nil?
      role = User.current.user_role.role.role.strip rescue nil
      if ((role.downcase.match(/Administrator/i) rescue false) ? true : false)
        user.update_attributes(voided: true,
          :void_reason => "Removed from system by (user_id): #{User.current.id}")
      end
    end

    redirect_to "/view_users" and return

  end

  #Gives Back Bloked User Access Rights
  def unblock_user

    user = User.find(params[:id]) rescue nil

    if !user.nil?
      role = User.current.user_role.role.role.strip rescue nil
      if ((role.downcase.match(/Administrator/i) rescue false) ? true : false)
        user.update_attributes(active: true,
          :un_or_block_reason => params[:reason])
      end
    end

    redirect_to "/view_users" and return

  end

  def search

    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    @section = "Search for User"

    @targeturl = "/users"

    render :layout => "facility"

  end

  def search_by_username

    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))
    @users = User.all

    results = []

    @users.each do |user|

      next if user.username.strip.downcase == User.current.username.strip.downcase

      record = {
          "user_id" => "#{user.id}",
          "username" => "#{user.username}",
          "fname" => "#{user.core_person.person_name.first_name}",
          "lname" => "#{user.core_person.person_name.last_name}",
          "role" => "#{user.user_role.role.role}",
          "active" => (user.active rescue false)
      }

      results << record

    end

    render :text => results.to_json

  end

  def search_by_active

    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("View Users"))

    status = params[:status] == "true" ? true : false

    results = []

    users = User.by_active.key(status).limit(10).each

    users.each do |user|

      next if user.username.strip.downcase == User.current.username.strip.downcase

      record = {
          "username" => "#{user.username}",
          "fname" => "#{user.core_person.person_name.first_name}",
          "lname" => "#{user.core_person.person_name.last_name}",
          "role" => "#{user.user_role.role.role}",
          "active" => (user.active rescue false)
      }

      results << record

    end

    render :text => results.to_json

  end



  def username_availability
    user = User.get_active_user(params[:search_str])
    render :text => user = user.blank? ? 'OK' : 'N/A' and return
  end

  def my_account
    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Change own password"))

    @section = "My Account"

    @targeturl = "/"

    @user = User.current

    render :layout => "facility"

  end

  def change_password
    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Change own password"))

    @section = "Change Password"

    @targeturl = "/"

    @user = User.current

    render :layout => "facility"

  end



  def update_password

    user = User.current

    result = user.password_matches?(params[:old_password])

    if user && !user.password_matches?(params[:old_password])
    	 result = "not same"
    elsif user && user.password_matches?(params[:new_password])
    	 result = "same"
    else
      user.update_attributes(:password_hash => params[:new_password], :password_attempt => 0, :last_password_date => Time.now)
      flash["notice"] = "Your new password has been changed succesfully"

    end

    render :text => result

  end

  def change_keyboard
    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Change own password"))

    @section = "Change Password"

    @targeturl = "/"

    @user = User.current

    render :layout => "touch"

  end

  def update_keyboard
      user = User.current
      if user.present?
          user.update_attributes(:preferred_keyboard => params[:keyboard].downcase)
          redirect_to "/users/my_account"
      else
          redirect_to "/users/my_account"
      end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :active, :create_at, :creator, :email, :notify, :plain_password, :updated_at)
  end

  def check_if_user_admin

    @search = icoFolder("search")

    @admin = ((User.current.user_role.role.role.strip.downcase.match(/Administrator/i) rescue false) ? true : false)

  end


end
