class UsersController < ApplicationController

  #Displays User Management Section
  def index

    @icoFolder = icoFolder("icoFolder")

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

    @user_role =  UserRole.find_by_user_id(@user.user_id)


    @targeturl = "/view_users"

    render :layout => "facility"

  end

  #Displays All Users
  def view

    @section = "View Users"

    @targeturl = "/users"

    render :layout => "facility"
  end

  #Adds A New User
  def new

    @user = User.new

    @section = "Create User"

    @targeturl = "/user"

    render :layout => "touch"

  end

  # Edits Selected User
  def edit

    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Update User"))

    @user = User.find(params[:id])

    @section = "Edit User"

    @targeturl = "/view_users"

    render :layout => "touch"

  end

  #Creates A New User
  def create

      @targeturl = "/user"
	person_type = PersonType.where(name: 'User').first

	core_person = CorePerson.create(person_type_id: person_type.id)
	person_name = PersonName.create(person_id: core_person.person_id, first_name: params[:user]['person']['first_name'], last_name: params[:user]['person']['last_name'])

	person_name_code = PersonNameCode.create(person_name_id: person_name.person_name_id, first_name_code: params[:user]['person']['first_name'].soundex, last_name_code: params[:user]['person']['last_name'].soundex )

	[['Administrator', 1], ['Nurse', 2], ['Midwife', 2], ['Data clerk', 3]].each do |r, l|
	  Role.create(role: r, level: l)
	end

	role = Role.where(role:  params[:user]['user_role']['role']).first

	@user = User.create(username: params[:user]['username'], password: params[:user]['password'], creator: 1, person_id: core_person.person_id)

	@user_role = UserRole.create(user_id: @user.id, role_id: role.id)

	loc_tags = ['Country','District','Village','Traditional Authority','Health facility']
	loc_tags.each do |t|
	  LocationTag.create(name: t)
	end

	User.current = User.first

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
     #raise params.inspect

     @user = User.find(params[:id])
       #if params["user"]["password"].present? && params["user"]["password"].length > 1
          @person_name = PersonName.find_by_person_id(@user.person_id)
	  @person_name.update_attributes(:first_name => params["user"]["person"]["first_name"], :last_name => params["user"]["person"]["last_name"])
	  #@user_role =  UserRole.find_by_user_id(@user.user_id)
	  # @user_role.update_attributes(:role => params["user"]["user_role"]["role"])
	  @user.update_attributes(:password => params["user"]["password"])

       #end
    respond_to do |format|
      #if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false) and @user.update_attributes(user_params)

        if @user.present?
        format.html { redirect_to @user, :notice => 'User was successfully updated.' }
        format.json { render :show, :status => :ok, :location => @user }
        else
        format.html { render :edit }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
      end
  end

  #Displays All Users
  def query_users

    results = []

    users = User.all
      users.each do |user|
    	next if user.core_person.blank? || user.core_person.person_name.blank?

    	record = {
          	"username" => "#{user.username}",
          	"name" => "#{user.core_person.person_name.first_name} #{user.core_person.person_name.last_name}",
          	"user_id" => "#{user.user_id}",
          	"role" => "#{(UserRole.find_by_user_id(user.user_id).role.role rescue "")}",
         	"active" => (user.active rescue false)
      	    	}
       	results << record
    end

    render :text => results.to_json
  end

  #Deletes Selected User
  def destroy

     @user = User.find(params[:id])
     #raise @user.inspect
     @user.destroy
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

      user.update_attributes(:active => false, :un_or_block_reason => params[:reason]) if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)

    end

    redirect_to "/view_users" and return

  end

  #Gives Back Bloked User Access Rights
  def unblock_user

    user = User.find(params[:id]) rescue nil

    if !user.nil?

      user.update_attributes(:active => true, :un_or_block_reason => params[:reason]) if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
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

    name = params[:id].strip rescue ""

    results = []

    if name.length > 1

      users = User.by_username.key(name).limit(10).each

    else

      users = User.by_username.limit(10).each

    end

    users.each do |user|

      next if user.username.strip.downcase == User.current_user.username.strip.downcase

      record = {
                "username" => "#{user.username}",
          	"name" => "#{user.core_person.person_name.first_name} #{user.core_person.person_name.last_name}",
          	"user_id" => "#{user.user_id}",
          	"role" => "#{(UserRole.find_by_user_id(user.user_id).role.role rescue "")}",
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

      next if user.username.strip.downcase == User.current_user.username.strip.downcase

      record = {
          	"username" => "#{user.username}",
          	"name" => "#{user.core_person.person_name.first_name} #{user.core_person.person_name.last_name}",
          	"user_id" => "#{user.user_id}",
          	"role" => "#{(UserRole.find_by_user_id(user.user_id).role.role rescue "")}",
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

    @user = User.current_user

    render :layout => "facility"

  end

  def change_password
    #redirect_to "/" and return if !(User.current_user.activities_by_level("Facility").include?("Change own password"))

    @section = "Change Password"

    @targeturl = "/"

    @user = User.current_user

    render :layout => "facility"

  end

  def update_password

    user = User.current_user

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

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :active, :create_at, :creator, :first_name, :last_name, :notify, :password, :role, :updated_at)
  end

  def check_if_user_admin

    @search = icoFolder("search")

    @admin = ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)

  end


end
