#!/usr/bin/env ruby

require 'RMagick'
require 'redis'

upload_directory = '/home/user/photos/upload/';
chair_directories = '/home/user/photos/chaises/'
image_destination = '/home/user/museomix2011/1_lemuriens_neopop/webglue/public/images/'

excluded_colors = [ '#B3B3B3' ]

fuzz = ARGV[0] || 8000

redis = Redis.new

# Loop getting posted images 
Dir.entries(upload_directory). do |file|
  # get oldest redis entry for id_auth and id_chair
  id_auth = redis.lpop("lemuriens.id_auth")
  id_chair = redis.lpop("lemuriens.id_chair")
  
  # then generate image
  generate_final(file, id_auth, id_chair)
  file.delete
end

def generate_final(person_image, id_auth, id_chair)
  image = Magick::Image.read(file)
  image.fuzz = 8000
  
  image.rotate!(-90)
  
  excluded_colors.each do |c|
    image = image.transparent(c)
  end
  
  image.write("#{}/#{id_auth}.jpg") 
}
