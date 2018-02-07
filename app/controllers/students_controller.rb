class StudentsController < ApplicationController
  def attendance
    students = Student.where(platoon: params[:platoon]).select {|s| s.first_name != nil}
    students.each do |student|
      attendance_records = student.attendance_records.select {|a| a.date.to_date == DateTime.now.to_date}
      attendance_record = attendance_records.first
      if !attendance_record
        attendance_record = AttendanceRecord.new
        attendance_record.student = student
      end
      attendance_record.description = params[student.first_name] if params[student.first_name]
      attendance_record.date = DateTime.now
      attendance_record.save
    end
    redirect_to controller: 'home', action: 'index', platoon: params[:platoon]
  end
    
end
