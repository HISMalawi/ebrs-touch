class UsersController < ApplicationController

  #Displays User Management Section
  def index
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
	#raise @user.inspect
    @user_role = UserRole.find(@user.user_id)

    @targeturl = "/view_users"

    render :layout => "facility"

  end

  #Displays All Users
  def view

    @users = User.all.each

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

    @user = User.find(params[:id])

    @section = "Edit User"

    @targeturl = "/view_users"

    render :layout => "touch"

  end

  #Creates A New User
  def create

      @targeturl = "/user"
      #user = User.find(params[:user]['username'])

      #if user.present?
        #flash["notice"] = "User already already exists"
         #redirect_to "/user/new" and return
      #end
      core_person = CorePerson.create(person_type_id: 1)
      person_name = PersonName.create(person_id: core_person.person_id, first_name: params[:user]['person']['first_name'], last_name: params[:user]['person']['last_name'] )
      person_name_code = PersonNameCode.create(person_name_id: person_name.person_name_id, first_name_code: params[:user]['person']['first_name'].soundex, last_name_code: params[:user]['person']['last_name'].soundex )

      @user = User.create(username: params[:user]['username'], plain_password: params[:user]['plain_password'], location_id: 1, uuid: 1, role_id: 1, email: "admin@admin.com", person_id: core_person.person_id)
      user_role = UserRole.create(user_role_id: @user.user_id, role: params[:user]['user_role']['role'], level: 1, voided: 0)

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

    if request.referrer.match('edit_account')
      @current_user.preferred_keyboard = params[:user][:preferred_keyboard]
      @current_user.save!
      #Audit.create(record_id: @current_user.id, audit_type: "Audit", level: "User", reason: "Updated user preference")
      redirect_to '/users/my_account' and return
    end

    if params[:user][:plain_password].present? && params[:user][:plain_password].length > 1
      @user.update_attributes(:password_hash => params[:user][:plain_password], :password_attempt => 0, :last_password_date => Time.now)
       #Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Updated user password")
    end
 #raise @user.inspect
    respond_to do |format|
      #if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false) and @user.update_attributes(user_params)
         #Audit.create(record_id: @user.id, audit_type: "Audit", level: "User", reason: "Updated user")
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
          	"user_id" => "#{user.user_id}",
          	"name" => "#{user.core_person.person_name.first_name} #{user.core_person.person_name.last_name}",
          	"roles" => "#{user.user_role.role}",
         	"active" => (user.active rescue true)
      	    	}

      	results << record
    end

    render :text => results.to_json
  end

  #Deletes Selected User
  def destroy

    @user.destroy if ((User.current_user.role.strip.downcase.match(/admin/) rescue false) ? true : false)
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


end
