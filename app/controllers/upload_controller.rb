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

    images = []
    csv = []

    # parse csv file
    if (params[:csv_file].blank?)
        redirect_to upload_index_path, notice: 'Please provide a CSV file.'
    end

    csv_file = params[:csv_file].read
    csv = CSV.parse(csv_file, headers: true)
    Rails.logger.info "Collected all student courses #{csv.inspect}"
    # if the csv file contains empty rows, remove the offensive row
    csv.delete_if { |row| row.to_hash.values.all?(&:nil?) }

    
    # when a zip file is uploaded, unzip it
    Zip::File.open(params[:file]) do |zip_file|
      # if the zip file contains a csv file, parse it
      images_paths = []

      zip_file.each do |entry|
        Rails.logger.debug "\n\n#######ZIP entry: #{entry.name} ##############\n\n\n"

        if entry.name.include? '.htm'
          # parse html doc for correct order of pictures, csv & images zip is mismatched but html gets order correct
          html_doc = Nokogiri::HTML(entry.get_input_stream.read)
          images_paths = html_doc.search('img/@src').map { |s| s.text.strip }

          images_paths.each do |path|
            Rails.logger.debug "\n\n\n\n################Trying to find image with path: #{path}\n\n\n\n"
            # error handling .display as path pushed to images_paths doesn't match entry.name,so find_entry doen't work without modyifying path
            if path.include? '.display'
              full_path = path.split('/', 2)
              # puts full_path
              # puts full_path[1]
              images.push(zip_file.find_entry(full_path[1]))
            else
              Rails.logger.debug "\n\n\n\n\n\n##################### hereererer  #######################3\n\n\n\n\n\n\n"
              images.push(zip_file.find_entry(path))
            end
          end
          Rails.logger.debug "images_paths: #{images_paths.inspect}"
          Rails.logger.debug "images: #{images.inspect}"

        # elsif entry.name.include? '.csv'
        #   # parse
        #   csv = CSV.parse(entry.get_input_stream.read, headers: true)
        #   Rails.logger.info "Collected all student courses #{csv.inspect}"
        #   # if the csv file contains empty rows, remove the offensive row
        #   csv.delete_if { |row| row.to_hash.values.all?(&:nil?) }
        # end
      end
    end

    # if number of rows in csv file is equal to number of images in zip file, then proceed. Otherwise, throw an error
    if !csv.empty? && (csv.length == images.length)
      # create course entry
      @course = Course.find_or_create_by(course_name: params[:course_temp], teacher: current_user.email,
                                         section: params[:section_temp], semester: params[:semester_temp])
      StudentCourse.where(course_id: @course.id).destroy_all

      csv.zip(images).each do |row, image|
        uuid = "#{SecureRandom.uuid}-#{row['UIN'].strip}"

        # if the columns are not null, then proceed
        Rails.logger.info "Collected student #{row.inspect}"
        if row['Name'] && row['UIN'] && row['Major'] && row['Class'] && row['Email']
          @student = Student.where(uin: row['UIN'].strip, teacher: current_user.email).first
          # Name is in format last,first
          # TODO: Add error checking for name-array
          name_array = row['Name'].split(",")

          if !@student
            @student = Student.new(
              firstname: name_array[1].strip,
              lastname: name_array[0].strip,
              uin: row['UIN'].strip,
              email: row['Email'].strip,
              classification: row['Class'].strip,
              major: row['Major'].strip,
              teacher: current_user.email,
              last_practice_at: Time.now - 121.minutes,
              curr_practice_interval: 120
            )
            @student.save
          else
            @student.update(
              firstname: name_array[1].strip,
              lastname: name_array[0].strip,
              uin: row['UIN'].strip,
              email: row['Email'].strip,
              classification: row['Class'].strip,
              major: row['Major'].strip,
              teacher: current_user.email
            )
          end
          StudentCourse.find_or_create_by(course_id: @course.id, student_id: @student.id,
                                          final_grade: row['Final'])

          Tempfile.open([uuid]) do |tmp|
            image.extract(tmp.path) { true }
            @student.image.attach(io: File.open(tmp), filename: uuid)
          end
        else
          redirect_to upload_index_path,
                      notice: 'CSV column contents are different than expected. Please check the format of CSV file.'
          return
        end
      end
      redirect_to courses_url, notice: 'Upload successful!'
    else
      redirect_to upload_index_path, notice: 'Number of images does not match number of students'
    end
  end
  end
end