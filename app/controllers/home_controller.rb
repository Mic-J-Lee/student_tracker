class HomeController < ApplicationController
  before_action :get_platoon, only: [:index]

  def index
    @assignments = Assignment.all
  end

  private

    def get_platoon
      @students = Student.where(platoon: params[:platoon])
    end

end
