class HomeController < ApplicationController
  before_action :get_platoon, only: [:index]

  def index

    #get list of all assignments that has active pull request
    @assignment_names = []
    Assignment.all.each do |assignment|
      if assignment.repo_name && assignment.student && assignment.student.platoon == params[:platoon]
        @assignment_names << assignment.repo_name
      end
    end
    @assignment_names = @assignment_names.uniq

    #make hash with each student's progress
    @student_progress = {}
    @students.each do |student|
      @student_progress[student.github_handle] = @assignment_names.map { |assignment_name|
        if student.assignments.find_by(repo_name: assignment_name)
          student.assignments.find_by(repo_name: assignment_name).completion 
        else 
          'incomplete'
        end 
      }
    end

    #list of platoons for dropdown
    @platoons = Student.pluck(:platoon).uniq - [nil]
    @platoon = params[:platoon]
  end

  private

    def get_platoon
      @students = Student.where(platoon: params[:platoon]).select {|s| s.first_name != nil}
    end

end
