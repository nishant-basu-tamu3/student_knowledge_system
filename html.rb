require 'csv'
require 'nokogiri'
require 'base64'
require 'fileutils'
require 'tempfile'

# Directory to store decoded images
uploads_dir = 'public/uploads'
FileUtils.mkdir_p(uploads_dir) unless Dir.exist?(uploads_dir)

# Read and parse HTML file
html_doc = Nokogiri::HTML(File.open('Howdy Dashboard _ Howdy.htm').read)

# Extract base64 image data
images_paths = html_doc.css('img').map { |img| img['src'].strip }

images = []

images_paths.each_with_index do |path, index|
  puts "Attempting to find image with path or Base64 data: #{path}"

  if path.start_with?('data:text/xml')
    puts "Base64 image (text/xml) found, decoding..."
    
    # Extract and decode Base64 data
    base64_data = path.split(',')[1] # Get the base64 data part
    decoded_image = Base64.decode64(base64_data)

    # Generate a temporary file for the decoded XML data
    temp_image = Tempfile.new(['image', '.xml']) # Storing as .xml since the data is text/xml
    temp_image.binmode
    temp_image.write(decoded_image)
    temp_image.rewind

    # Store the temporary image in the array
    images.push(temp_image)

    # Save the decoded image as a file (e.g., XML)
    file_name = "image_#{index}.xml"  # Assuming the content is XML
    file_path = File.join(uploads_dir, file_name)  # Use File.join to create the path

    File.open(file_path, 'wb') do |file|
      file.write(decoded_image)  # Write the decoded image data
    end

    # Remember to close the temporary file when done
    temp_image.close
  else
    puts "Skipping non-base64 or unsupported image format: #{path}"
  end
end

puts "Decoded images: #{images.map(&:path).inspect}"
puts "Number of images: #{images.length}"