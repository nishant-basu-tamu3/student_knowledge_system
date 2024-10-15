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
    require 'base64'

    csv_file = params[:csv_file]
    file_contents = File.read(csv_file.path)
    @cleaned_contents = file_contents.gsub("\r\n", "\n")
    names = extract_names_from_csv if params[:csv_file].present?
    images = extract_images_from_html(names) if params[:complete_webpage_file].present?
    if names.present? && images.present? && names.length == images.length
      @course = create_course
      StudentCourse.where(course_id: @course.id).destroy_all
      CSV.parse(@cleaned_contents, headers: true, liberal_parsing: true) do |row|
        cleaned_row = row.to_h
        name_key = cleaned_row.keys.find { |key| key.include?("Name") }
        uin_key = cleaned_row.keys.find { |key| key.include?("UIN") }
        major_key = cleaned_row.keys.find { |key| key.include?("Major") }
        class_key = cleaned_row.keys.find { |key| key.include?("Class") }
        email_key = cleaned_row.keys.find { |key| key.include?("Class") }
        
        if cleaned_row[name_key] && cleaned_row[uin_key] && cleaned_row[major_key] && cleaned_row[class_key] && cleaned_row[email_key]
          save_student(cleaned_row, name_key, uin_key, major_key, class_key, email_key, images)
        else
          redirect_to upload_index_path,
                      notice: 'CSV column contents are different than expected. Please check the format of CSV file.'
          return
        end

      end
    else
      redirect_to upload_index_path, notice: 'Number of images does not match number of students'
      return
    end

    redirect_to courses_url, notice: 'Upload Successful!!'

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

  def extract_names_from_csv
    names = []
    # csv_file = params[:csv_file]
    # file_contents = File.read(csv_file.path)
    # cleaned_contents = file_contents.gsub("\r\n", "\n")

    CSV.parse(@cleaned_contents, headers: true, liberal_parsing: true) do |row|
      cleaned_row = row.to_h
      name_key = cleaned_row.keys.find { |key| key.include?("Name") }
      name = cleaned_row[name_key] if name_key
      names << name unless name.nil? || name.empty?
    end

    names
  end


  def extract_images_from_html(names)
    html_file = params[:complete_webpage_file]
    html_doc = Nokogiri::HTML(File.read(html_file.path))
    images = {}

    names.each do |name|
      name_div = html_doc.at_xpath("//div[contains(text(), '#{name}')]")
      if name_div
        previous_element = name_div.previous_element
        if previous_element && previous_element.name == 'app-imagerosterformatter'
          img_tag = previous_element.at_xpath('.//img')
          images[name] = img_tag.attr('src') if img_tag
        end
      end
    end

    images
  end

  def save_student(cleaned_row, name_key, uin_key, major_key, class_key, email_key, images)
    
    @student_check = Student.where(uin: cleaned_row[uin_key].strip, teacher: current_user.email).first

    # Name is in format last,first
    # TODO: Add error checking for name-array
    name_array = cleaned_row[name_key].split(",")
    
    if !@student_check
      @student = Student.new(
        firstname: name_array[1],
        lastname: name_array[0],
        uin: cleaned_row[uin_key].strip,
        email: cleaned_row[email_key].strip,
        classification: cleaned_row[class_key].strip,
        major: cleaned_row[major_key].strip,
        teacher: current_user.email,
        last_practice_at: Time.now - 121.minutes,
        curr_practice_interval: 120
      )
      @student.save
    else
      @student = Student.update(
        firstname: name_array[1],
        lastname: name_array[0],
        uin: cleaned_row[uin_key].strip,
        email: cleaned_row[email_key].strip,
        classification: cleaned_row[class_key].strip,
        major: cleaned_row[major_key].strip,
        teacher: current_user.email,
      )
    end

    final_key = cleaned_row.keys.find { |key| key.include?("Final") }
    # here is the bug ########################
    Rails.logger.info "Collected all student info #{@student.inspect}"
    Rails.logger.debug "\n\n\n\n################Trying to find image with path: #{@student}\n\n\n\n"
    StudentCourse.find_or_create_by(course_id: @course.id, student_id: @student[0].id,
                                    final_grade: cleaned_row[final_key])
    # TODO: Link image with student
    # @student[0].image = images[cleaned_row[name_key]]

  end

end
