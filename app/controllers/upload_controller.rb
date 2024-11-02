# frozen_string_literal: true

# Upload controller class
class UploadController < ApplicationController
  before_action :require_user!
  # before_action :authenticate_user!
  # before_action :authenticate_by_session

  def index; end

  def parse
    require 'zip'
    require 'csv'
    require 'securerandom'
    require 'nokogiri'

    names = extract_data_from_csv('Name') if params[:csv_file].present?
    images = extract_images_from_html(names) if params[:complete_webpage_file].present?
    if names.present? && images.present? && names.length == images.length
      @course = create_course
      destroy_existing_students_from_course(@course.id)
      process_students(names, images)
      redirect_to courses_url, notice: 'Upload successful!'
    else
      redirect_to upload_index_path, notice: 'Number of images does not match number of students'
    end
  end

  private

  def create_course
    Course.find_or_create_by(
      course_name: params[:course_temp],
      teacher: current_user.email,
      section: params[:section_temp],
      semester: params[:semester_temp]
    )
  end

  def extract_data_from_csv(column_key)
    data = []
    csv_file = params[:csv_file]
    file_contents = File.read(csv_file.path)
    cleaned_contents = file_contents.gsub("\r\n", "\n")

    CSV.parse(cleaned_contents, headers: true, liberal_parsing: true) do |row|
      cleaned_row = row.to_h
      key = cleaned_row.keys.find { |k| k.include?(column_key) }
      value = cleaned_row[key] if key
      data << value unless value.nil? || value.empty?
    end

    data
  end

  def extract_images_from_html(names)
    html_file = params[:complete_webpage_file]
    html_doc = Nokogiri::HTML(File.read(html_file.path))
    images = {}

    names.each do |name|
      name_div = html_doc.at_xpath("//div[contains(text(), '#{name}')]")
      next unless name_div

      previous_element = name_div.previous_element
      if previous_element && previous_element.name == 'app-imagerosterformatter'
        img_tag = previous_element.at_xpath('.//img')
        images[name] = img_tag.attr('src') if img_tag
      end
    end

    images
  end

  def get_existing_student(uin)
    Student.where(uin:, teacher: current_user.email).first
  end

  def destroy_existing_students_from_course(course_id)
    StudentCourse.where(course_id:).destroy_all
  end

  def process_students(names, images)
    names.each do |name|
      name_parts = name.strip.split(' ', 2)
      firstname = name_parts[1]
      lastname = name_parts[0] || ''
      student_data = extract_row_data_for_name(name)

      next unless student_data

      @student = get_existing_student(student_data['UIN'])

      if @student.nil?
        @student = Student.new(
          firstname:,
          lastname:,
          uin: student_data['UIN'],
          major: student_data['MAJOR'],
          email: student_data['EMAIL'],
          classification: student_data['CLASS'],
          teacher: current_user.email,
          base64_image: images[name],
          last_practice_at: Time.now - 121.minutes,
          curr_practice_interval: 120
        )
        @student.save
      else
        @student.update(
          firstname:,
          lastname:,
          uin: student_data['UIN'],
          major: student_data['MAJOR'],
          email: student_data['EMAIL'],
          classification: student_data['CLASS'],
          teacher: current_user.email,
          base64_image: images[name]
        )
      end

      StudentCourse.find_or_create_by(course_id: @course.id, student_id: @student.id,
                                      final_grade: 'A')
    end
  end

  def extract_row_data_for_name(name)
    csv_file = params[:csv_file]
    file_contents = File.read(csv_file.path)
    cleaned_contents = file_contents.gsub("\r\n", "\n")

    CSV.parse(cleaned_contents, headers: true, liberal_parsing: true) do |row|
      name_key = row.headers.find { |h| h.include?('Name') }

      if row[name_key].strip == name.strip
        email_key = row.headers.find { |h| h.include?('Email') }
        major_key = row.headers.find { |h| h.include?('Major') }
        uin_key = row.headers.find { |h| h.include?('UIN') }
        class_key = row.headers.find { |h| h.include?('Class') }
        return {
          'EMAIL' => row[email_key].strip,
          'MAJOR' => row[major_key].strip,
          'UIN' => row[uin_key].strip,
          'CLASS' => row[class_key].strip
        }
      end
    end
    nil
  end
end
