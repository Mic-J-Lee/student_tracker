class AssignmentsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:payload]

  def payload
    old_event = false
    should_send_comment = false
    @push_notification = JSON.parse(request.body.read)

    # Handle difference between single github events and github timeline batches
    if params['type'] == 'PullRequestEvent'
      @push_notification = params['payload']
      old_event = true
    end

    if @push_notification['pull_request']
      github_handle = @push_notification['pull_request']['user']['login']
      platoon = @push_notification['pull_request']['url'].split('/')[4]
      repo_name = @push_notification['pull_request']['base']['repo']['name']

      # Stop if assignments do not require pull requests
      return if repo_name.include? 'http'

      # Find/create student.  Should send comment if puller is an actual student and event just happened
      student = Student.find_or_create_by github_handle: github_handle
      assignment = student.assignments.find_by repo_name: repo_name
      if !assignment
        assignment = Assignment.new
        assignment.repo_name = repo_name
        should_send_comment = true unless old_event || !student.first_name
      end

      # Set/update platoon of student, mark assignment complete, give assignment to student
      student.platoon = platoon
      student.save
      assignment.completion = 'complete'
      assignment.student = student

      # Give pairing partner credit
      and_pairing_partners = ''
      if student.first_name
        cohort = Student.where(platoon: platoon)
        cohort.each do |cohort_member|
          if cohort_member.first_name
            if has_pr_pair(student, cohort_member) || has_branch_pair(student, cohort_member)
              paired_assignment = cohort_member.assignments.find_or_create_by repo_name: repo_name
              paired_assignment.completion = 'complete'
              and_pairing_partners += " and #{cohort_member.first_name}" if paired_assignment.save
            end
          end
        end
      end

      # Save and post comment on Pull Request
      if repo_name.downcase.include? 'assessment'
        comment = "Thanks for your hard work, #{student.first_name}! Assessments can take a while to grade, so please be patient."
      elsif repo_name.downcase.include? 'final_capstone'
        should_send_comment = false
      else
        comment = ":+1: You#{and_pairing_partners} got credit!"
      end
      if assignment.save && should_send_comment
        HTTParty.post("#{@push_notification['pull_request']['_links']['comments']['href']}", body: {'body'=> comment}.to_json, headers: {'User-Agent'=> "#{ENV['GH_U']}", 'Authorization'=> "token #{ENV['GH_T']}"})
      end

      # Special cases - group projects everyone gets credit
      if ['boggle', 'ruduku'].include? repo_name
        Student.where(platoon: platoon).each do |cohort_member|
          group_assignment = cohort_member.assignments.find_or_create_by repo_name: repo_name
          group_assignment.completion = 'complete'
          group_assignment.save
        end
      end

    end #of if @push_notification['pull_request']

    # Take Attendance
    if params[:Timestamp]
      date = params[:Timestamp][0..9]
      time = params[:Timestamp][11..18]
      date_time = date + ' ' + time
      cohort = Student.where(platoon: 'echoplatoon') # brittle. add platoon to form?
      cohort.each do |cohort_member|
        if cohort_member.first_name
          if params[:Name].downcase.include? cohort_member.first_name.downcase
            attendance_record = cohort_member.attendance_records.find_or_create_by date: date_time
            attendance_record.description = 'present'
            attendance_record.save
          end
        end
      end
    end

  end #of #payload

  def has_pr_pair(student, cohort_member)
    pr_title_without_puller = @push_notification['pull_request']['title'].downcase.remove(student.first_name.downcase)
    pr_title_without_puller.include?(cohort_member.first_name.downcase)
  end

  def has_branch_pair(student, cohort_member)
    branch_name_without_puller = @push_notification['pull_request']['head']['ref'].downcase.remove(student.first_name.downcase)
    branch_name_without_puller.include?(cohort_member.first_name.downcase)
  end
end
