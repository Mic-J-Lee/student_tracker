class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [:show]
  skip_before_action :verify_authenticity_token, only: [:payload]

  def payload
    puts 'this works from github!'
    push = JSON.parse(request.body.read)
    # puts "I got some JSON: #{push.inspect}"
    print JSON.pretty_generate(push)
    if push['pull_request']
      github_handle = push['pull_request']['user']['login']
      repo_name = push['repository']['name']
      student = Student.find_by github_handle: github_handle
      assignment = Assignment.find_by repo_name: repo_name
      if !student 
        student = Student.new
        student.github_handle = github_handle
      end
      if !assignment
        assignment = Assignment.new
        assignment.repo_name = repo_name
      end
      assignment.student = student
      assignment.completion = 'complete'
      assignment.save
    end
  end

  def show
  end

  private
    def set_assignment
      @assignment = Assignment.friendly.find(params[:id])
    end
  
end


