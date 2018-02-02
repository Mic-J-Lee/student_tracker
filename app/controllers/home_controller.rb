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
    @assignment_names = @assignment_names.uniq.reverse

    #make hash with each student's progress, calculate grades
    @student_progress = {}
    @student_grades = {}
    @students.each do |student|
      @student_progress[student.github_handle] = @assignment_names.map { |assignment_name|
        if student.assignments.find_by(repo_name: assignment_name)
          student.assignments.find_by(repo_name: assignment_name).completion 
        else 
          'incomplete'
        end 
      }
      progress = @student_progress[student.github_handle]
      incomplete_length = (progress - ['complete']).length
      @student_grades[student.github_handle] = (100 * (1 - incomplete_length.to_f/progress.length)).round(2)
    end

    #list of platoons for dropdown
    @platoons = [''] + Student.pluck(:platoon).uniq.compact
    @platoon = params[:platoon]

    #attendance
    attendance_records = AttendanceRecord.all.select{|attendance_record|attendance_record.student.platoon == params[:platoon]}
    @class_dates = attendance_records.pluck(:date).uniq.compact.map { |date_time| date_time.to_date  }
    if @class_dates.uniq!
      @class_dates.reverse!
    end
    @attendance_percentages = {}
    @student_attendance = {}
    @students.each do |student|
      @student_attendance[student.first_name] = @class_dates.map { |class_date|
        attendance_records = student.attendance_records.select {|a| a.date.to_date == class_date}
        if attendance_records.first
          attendance_records.first.description || 'unknown'
        end
      }
      attendance = @student_attendance[student.first_name]
      absent_length = attendance.count('absent')
      @attendance_percentages[student.first_name] = (100 * (1 - absent_length.to_f/attendance.length)).round(2)
    end

  end

  private

    def get_platoon
      @students = Student.where(platoon: params[:platoon]).select {|s| s.first_name != nil}
    end

end
