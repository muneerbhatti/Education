class HomeController < ApplicationController
  def index
  end
  def teacher_details
  end
  def courses
    @courses = Course.all.includes(:instructor)
  end
  def course_details
    @course = Course.find(params[:id])
    @instructor = @course.instructor
  end
end
