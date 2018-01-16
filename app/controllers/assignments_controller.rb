class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show]
  skip_before_action :verify_authenticity_token, only: [:payload]
  rescue_from ActiveRecord::RecordNotFound, with: :incomplete

  def payload
    push_notification = JSON.parse(request.body.read)
    if push_notification['pull_request']
      github_handle = push_notification['pull_request']['user']['login']
      repo_name = push_notification['repository']['name']
      student = Student.find_by github_handle: github_handle
      platoon = student.platoon
      assignment = student.assignments.find_by repo_name: repo_name
      if !student 
        student = Student.new
        student.github_handle = github_handle
        student.platoon = 'unknown'
      end
      if !assignment
        assignment = Assignment.new
        assignment.repo_name = repo_name
      end
      assignment.student = student
      assignment.completion = 'complete'
      assignment.save
      if student.first_name
        pr_title = push_notification['pull_request']['title']
        pr_title_without_pusher = pr_title.downcase.remove(student.first_name.downcase)
        cohort = Student.where(platoon: platoon)
        cohort.each do |cohort_member|
          if pr_title_without_pusher.include? cohort_member.first_name.downcase
            paired_assignment = cohort_member.assignments.find_by repo_name: repo_name
            if !paired_assignment
              paired_assignment = Assignment.new
              assignment.repo_name = repo_name
            end
            paired_assignment.student = cohort_member
            paired_assignment.completion = 'complete'
            paired_assignment.save
          end
        end
      end
    end
  end

  def show
  end

  def incomplete
    render 'incomplete'
  end

  private
    def set_assignment
      @assignment = Assignment.friendly.find(params[:id])
    end
  
end


