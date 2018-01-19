class HomeController < ApplicationController
  before_action :get_platoon, only: [:index]

  def index
    @assignments = Assignment.all
    @assignment_names = []
    @assignments.each do |assignment|
      @assignment_names << assignment.repo_name
    end
    @assignment_names = @assignment_names.uniq
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
  end

  private

    def get_platoon
      @students = Student.where(platoon: params[:platoon])
    end

end
