class PersonController < ApplicationController
  def index
  end

  def show
  end

  def new
     @person = PersonName.new

     @section = "New Person"
     render :layout => "touch"
  end

  def create
  end
end
