# frozen_string_literal: true

# Course Helper
module CoursesHelper
  def sort_link(column:, label:)
    link_to(label, list_courses_path(column:))
  end

  def set_course
    @course = Course.find_by(teacher: current_user.email, id: params[:id])
    return unless @course.nil?

    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Given course not found.' }
      format.json { head :no_content }
    end
  end
end
