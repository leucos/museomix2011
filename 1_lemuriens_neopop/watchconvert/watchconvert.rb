#!/usr/bin/env ruby

require 'RMagick'
require 'redis'

require 'pp'

$upload_directory = '/home/user/photos/upload/';
$chair_directories = '/home/user/photos/chaises/'
$image_destination = '/home/user/museomix2011/1_lemuriens_neopop/webglue/public/images/'

$excluded_colors = [ # serie gris clair
                     '#979797', 
		     '#959998', 
                     '#797979',
                     '#B6B8B7', # gris clair
                     '#8D8D8F', # gris clair
                     '#A0A0A0', # gris clair
                     '#AFAFAF', # gris souris
                     '#89817F', # gris foncé
                     '#783345', # rose foncé
                     '#9D1B49', # rose clair
                     '#94153E', # rose foncé
		   ]

$debug = true;

$fuzz = ARGV[0] || 2300

redis = Redis.new

def generate_final(person_image, id_auth, id_chair)
  pimage = Magick::Image.read("#{person_image}").first
  cimage = Magick::Image.read("#{$chair_directories}/#{id_chair}.jpg").first

  if pimage.nil?
    puts "Ooops, image is nil !"
    return
  end


  pimage.change_geometry!('850x2000') { |cols, rows, img|
    img.resize!(cols, rows)
  }

  pimage.rotate!(-90)
  
  pimage.fuzz = $fuzz  
  $excluded_colors.each do |c|
    puts "Removing color #{c}" if $debug
    pimage = pimage.transparent(c)
  end
 
  dimage = cimage.composite(pimage,Magick::NorthGravity,25,-100, Magick::OverCompositeOp)
 
  dimage.write("#{$image_destination}/#{id_auth}.jpg") 
  puts "Wrote #{$image_destination}/#{id_auth}.jpg" if $debug
end

# Loop getting posted images 
Dir.entries($upload_directory).each do |file|
  full_path = "#{$upload_directory}/#{file}"
  
  next if file == '.' or file == '..'
  
  puts "Found new image #{full_path}" if $debug

  # get oldest redis entry for id_auth and id_chair
  id_auth = redis.lpop("lemuriens.id_auth")
  id_chair = redis.lpop("lemuriens.id_chair")

  if id_auth.nil? and id_chair.nil? then 
    puts "Omg, no ids in REDIS !"
    next
  else
    puts "Found id_auth/id_chair #{id_auth}/#{id_chair}" if $debug
  end

  # then generate image
  generate_final(full_path, id_auth, id_chair)

  puts "Removing #{full_path}"
  File.delete(full_path)
end
