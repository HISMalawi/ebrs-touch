class PersonController < ApplicationController
  def index
  end

  def show
  end

  def new
     @person = Person.new

     @section = "New Person"
     render "_form"
  end

  def create
  end
end
