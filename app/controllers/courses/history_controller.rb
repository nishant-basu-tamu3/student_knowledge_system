# frozen_string_literal: true

module Courses
  # History controller class
  class HistoryController < CoursesController
    # before_action :authenticate_user!
    # before_action :authenticate_by_session
    include CoursesHelper
    before_action :set_course, only: %i[show]

    def show
      @course_records = Course.where(course_name: Course.where(id: params[:id])[0].course_name,
                                     teacher: current_user.email)
    end
  end
end
