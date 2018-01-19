class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show]
  skip_before_action :verify_authenticity_token, only: [:payload, :payload2]
  rescue_from ActiveRecord::RecordNotFound, with: :incomplete

  def payload
    push_notification = JSON.parse(request.body.read)
    if params['type'] == 'PullRequestEvent'
      push_notification = params['payload']
    end
    if push_notification['pull_request']
      github_handle = push_notification['pull_request']['user']['login']
      if push_notification['repository']
        repo_name = push_notification['repository']['name']
      else
        repo_name = push_notification['pull_request']['base']['repo']['name']
      end
      student = Student.find_by github_handle: github_handle
      if !student 
        student = Student.new
        student.github_handle = github_handle
        student.platoon = 'unknown'
      end
      assignment = student.assignments.find_by repo_name: repo_name
      if !assignment
        assignment = Assignment.new
        assignment.repo_name = repo_name
      end
      if student.platoon == 'unknown'       #just for now
        student.platoon = 'echoplatoon'     #just for now
      end                                   #just for now
      student.save
      assignment.student = student
      assignment.completion = 'complete'
      assignment.save
      if student.first_name
        platoon = student.platoon
        pr_title = push_notification['pull_request']['title']
        pr_title_without_pusher = pr_title.downcase.remove(student.first_name.downcase)
        cohort = Student.where(platoon: platoon)
        cohort.each do |cohort_member|
          if cohort_member.first_name
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
  end

  def payload2
    if params['type'] == 'PullRequestEvent'
      pp params['payload']['pull_request']['base']['repo']['name']
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


