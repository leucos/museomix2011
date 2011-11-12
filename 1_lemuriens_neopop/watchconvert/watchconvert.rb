#!/usr/bin/env ruby

require "RMagick"

directory = ARGV[0];

# Loop getting 
image = Magick::Image.read(ARGV[0]).first


Dir.entries(".")


image.fuzz = 8000
#image = image.transparent('#FEE2B0')
image = image.transparent('#C6C7B2')

image.write("photo.jpg")
