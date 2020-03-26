#
#  Create AppIcon iOS
#
require 'json'
require 'fileutils'

####################
## HELP FUNCTION
####################
# returns the name of the last directory in a filepath
# useful for finding the names of .imageset and .appiconset
def lastdir file, ext; return File.basename dir(file).split('/')[-1], ext end

# returns filepath
def dir file; return File.dirname file end

# returns extension
def ext file; return File.extname file end

# returns basename, removing extension
def base file, ext; return File.basename file, ext end

# returns object contents of json
def parse json; return JSON.parse File.read json end

# writes to file
def write file, contents; return File.write file, contents end

def run cmd; return `#{cmd}`.to_s end

# returns width of image (integer)
def width_of image; return run("sips #{image} -g pixelWidth").split(' ').last.to_i end

# resizes image
def scale_to_width sourcename, new_width, new_height, outname; run "sips -s format png -z #{new_height} #{new_width} #{sourcename} --out #{outname}" end

# create folder if need
def create_folder_if_needed path; Dir.mkdir(path) unless File.exists?(path) end


####################
## CONSTANT
####################
$guide_json_file_ios = "#{Dir.pwd}/guide_ios.json"
$guide_json_file_android = "#{Dir.pwd}/guide_android.json"

# output
guide_output_file_folder = "#{Dir.pwd}/output"
$output_ios = "#{guide_output_file_folder}/ios"
$output_android = "#{guide_output_file_folder}/android"

# get image source from input
$input_file_icon = ARGV.shift
# raise "invalid source image file" unless input_file_icon
puts $input_file_icon
if $input_file_icon == nil
	puts "invalid source image path"
	exit 1
end

# get format (iOS, Android) type from input (ios, android, all)
input_generate_format = ARGV.shift
if !["all", "ios", "android"].include?(input_generate_format)
	puts "invalid generate format type: choose one (all, ios or android)"
	exit 1
end

####################
## PRIVATE
####################
# generate ios format
def generate_ios input_file, json_file, output
	guide_json = parse json_file

	for item in guide_json["images"] do 
		image_size = item["size"].split('x')

		scale = Integer(item["scale"].gsub('x', ''))

		image_name = item["filename"]
		
		out = "#{output}/#{image_name}"

		scale_to_width input_file, (image_size[0].to_f*scale).to_i.to_s, (image_size[1].to_f*scale).to_i.to_s, "\"" + out + "\""

	    puts out
	end
end 

# generate android format
def generate_android input_file, json_file, output
	guide_json = parse json_file

	for item in guide_json["images"] do 

		image_size = item["size"].split('x')

		image_folder_name = item["foldername"]
		
		out_folder = "#{output}/#{image_folder_name}"
		
		create_folder_if_needed out_folder

		out = "#{out_folder}/ic_launcher.png"

		scale_to_width input_file, image_size[0].to_i.to_s, image_size[1].to_i.to_s, "\"" + out + "\""

	    puts out
	end
end

def make_ios
	create_folder_if_needed $output_ios
	generate_ios $input_file_icon, $guide_json_file_ios, $output_ios
end

def make_android
	create_folder_if_needed $output_android
	generate_android $input_file_icon, $guide_json_file_android, $output_android
end

####################
## MAIN
####################
create_folder_if_needed guide_output_file_folder
if input_generate_format == "all"
	make_ios
	make_android
elsif input_generate_format == "ios" 
	make_ios
else # android
	make_android
end

####################
## END
####################