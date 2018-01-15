class HomeController < ApplicationController
  def index
    @assignments = Assignment.all
  end

  def payload
  end
end
