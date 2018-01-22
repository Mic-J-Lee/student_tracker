class AssignmentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:payload]

  def payload
    push_notification = JSON.parse(request.body.read)
    # Handle difference between single github events and github timeline batches
    if params['type'] == 'PullRequestEvent'
      push_notification = params['payload']
    end

    if push_notification['pull_request']
      github_handle = push_notification['pull_request']['user']['login']
      platoon = push_notification['pull_request']['url'].split('/')[4]

      # Handle difference between single github events and github timeline batches
      if push_notification['repository']
        repo_name = push_notification['repository']['name']
      else
        repo_name = push_notification['pull_request']['base']['repo']['name']
      end

      # Find student/assignment, create if needed
      student = Student.find_by github_handle: github_handle
      if !student 
        student = Student.new
        student.github_handle = github_handle
      end
      assignment = student.assignments.find_by repo_name: repo_name
      if !assignment
        assignment = Assignment.new
        assignment.repo_name = repo_name
      end

      # Save as complete
      student.platoon = platoon
      student.save
      assignment.student = student
      assignment.completion = 'complete'
      assignment.save

      # Give pairing partner credit
      if student.first_name
        pr_title = push_notification['pull_request']['title']
        pr_title_without_pusher = pr_title.downcase.remove(student.first_name.downcase)
        cohort = Student.where(platoon: platoon)
        cohort.each do |cohort_member|
          if cohort_member.first_name
            if pr_title_without_pusher.include? cohort_member.first_name.downcase
              paired_assignment = cohort_member.assignments.find_by repo_name: repo_name
              if !paired_assignment
                paired_assignment = Assignment.new
                paired_assignment.repo_name = repo_name
                paired_assignment.student = cohort_member
              end
              paired_assignment.completion = 'complete'
              paired_assignment.save
            end
          end
        end
      end

    end
  end
  
end


