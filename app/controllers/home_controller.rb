class HomeController < ApplicationController
  def index
  end
  def teacher_details
    @teacher = Instructor.find(params[:id])
  end
  def team
    @teachers = Instructor.all
  end
  def courses
    @courses = Course.all.includes(:instructor)
  end
  def course_details
    @course = Course.find(params[:id])
    @instructor = @course.instructor
  end
end
