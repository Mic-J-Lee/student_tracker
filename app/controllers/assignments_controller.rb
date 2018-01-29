class AssignmentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:payload]

  def payload
    old_event = false
    push_notification = JSON.parse(request.body.read)
    # Handle difference between single github events and github timeline batches
    if params['type'] == 'PullRequestEvent'
      push_notification = params['payload']
      old_event = true
    end

    if push_notification['pull_request']
      github_handle = push_notification['pull_request']['user']['login']
      platoon = push_notification['pull_request']['url'].split('/')[4]
      should_send_comment = false

      # Handle difference between single github events and github timeline batches
      if old_event
        repo_name = push_notification['pull_request']['base']['repo']['name']
      else
        repo_name = push_notification['repository']['name']
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
        should_send_comment = true unless old_event || !student.first_name
      end

      # Save as complete
      student.platoon = platoon
      student.save
      assignment.student = student
      assignment.completion = 'complete'
      pairing_partners = []
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
              pairing_partners << " and #{cohort_member.first_name}"
            end
          end
        end
      end
      pairing_partners = pairing_partners.join
      if repo_name.downcase.include?('assessment')
        body = "Thanks for your assessment, #{student.first_name}! Assessments take a while to grade, so please be patient."
      else 
        body = ":+1: You#{pairing_partners} got credit!"
      end
      if assignment.save && should_send_comment
        HTTParty.post("#{push_notification['pull_request']['_links']['comments']['href']}", body: {'body'=> body}.to_json, headers: {'User-Agent'=> "#{ENV['GH_U']}", 'Authorization'=> "token #{ENV['GH_T']}"})
      end
    end
  end
  
end


