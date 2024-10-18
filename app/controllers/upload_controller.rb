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

    names = extract_names_from_csv if params[:csv_file].present?
    images = extract_images_from_html(names) if params[:complete_webpage_file].present?
    if names.present? && images.present? && names.length == images.length
      @course = create_course
      StudentCourse.where(course_id: @course.id).destroy_all
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

  def extract_names_from_csv
    names = []
    csv_file = params[:csv_file]
    file_contents = File.read(csv_file.path)
    cleaned_contents = file_contents.gsub("\r\n", "\n")

    CSV.parse(cleaned_contents, headers: true, liberal_parsing: true) do |row|
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
end
