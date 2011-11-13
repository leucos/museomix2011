#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'RMagick'
require 'redis'
require 'yaml'

$config = YAML.load_file("config.yaml")

$config['fuzz'] ||= 2300

def generate_final(person_image, id_auth, id_chair)
  pimage = Magick::Image.read("#{person_image}").first
  cimage = Magick::Image.read("#{$config["paths"]["chair_directories"]}/#{id_chair}.jpg").first

  if pimage.nil?
    puts "Ooops, image is nil !"
    return
  end


  pimage.change_geometry!('850x2000') { |cols, rows, img|
    img.resize!(cols, rows)
  }

  pimage.rotate!(-90)
  
  pimage.fuzz = $config['fuzz']  
  $config['colors']['excluded_colors'].each do |c|
    puts "Removing color #{c}" if $config['debug']
    pimage = pimage.transparent(c)
  end
 
  dimage = cimage.composite(pimage,Magick::NorthGravity,25,-100, Magick::OverCompositeOp)
 
  dimage.write("#{$config["paths"]["image_destination"]}/#{id_auth}.jpg") 
  puts "Wrote #{$config["paths"]["image_destination"]}/#{id_auth}.jpg" if $config['debug']
end

def loop
  puts "loop" if $config['debug']
  redis = Redis.new

  # Loop getting posted images 
  Dir.entries($config["paths"]["upload_directory"]).each do |file|
    full_path = "#{$config["paths"]["upload_directory"]}/#{file}"
  
    next if file == '.' or file == '..'
  
    puts "Found new image #{full_path}" if $config['debug']

    # get oldest redis entry for id_auth and id_chair
    id_auth = redis.lpop("lemuriens.id_auth")
    id_chair = redis.lpop("lemuriens.id_chair")

    if id_auth.nil? and id_chair.nil? then 
      puts "Omg, no ids in REDIS !"
      next
    else
      puts "Found id_auth/id_chair #{id_auth}/#{id_chair}" if $config['debug']
    end

    # then generate image
    generate_final(full_path, id_auth, id_chair)

    puts "Removing #{full_path}" if $config['debug']
    File.delete(full_path)
  end
end

while true do
  loop
  sleep 1
end

