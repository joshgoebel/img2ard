#!/usr/bin/env ruby
require 'rubygems'
require 'chunky_png'

class AssetFile
  attr :name
  attr :files

  def initialize(name)
    @name = name
    @files = []
  end

  def filename
    "#{name}.h"
  end

  def to_define_name
    name.upcase + "_H"
  end

  def to_s
    header = "#ifndef #{to_define_name}\n#define #{to_define_name}\n\n"
    footer = "#endif\n"
    core = @files.map(&:to_s).join("")
    header + core + footer
  end
end


class ImageCharArray
  PER_LINE = 10
  attr :name
  attr :width
  attr :height
  attr :data

  def initialize(img, name)
    @width = img.width
    @height = img.height
    @name = name
    @data = []
  end

  def variable_name
    File.basename(name,".*")
  end

  def to_s
    header = "// #{File.basename(name)} / #{width}x#{height}\n"
    header += "PROGMEM const unsigned char #{variable_name}[] = {\n"
    core = ""
    @data.each_with_index do |x, i|
      hex = x==0 ? "00" : x.to_s(16).upcase
      point = "0x" + hex
      core << point
      core << ", " unless i==@data.size-1
      core << "\n" if (i+1)%PER_LINE==0
    end
    footer ="\n};\n\n"
    header + core + footer
  end
end

resource = AssetFile.new("assets")

files = Dir.glob("./assets/**/*.png")
files.each do |file|
  img = ChunkyPNG::Image.from_file(file)
  # puts img.inspect
  out = ImageCharArray.new(img, file)
  puts "#{file}: #{img.width}x#{img.height}"

  bits_last_page = img.height % 8
  bytes_high = img.height / 8
  bytes_high +=1 if bits_last_page>0

  (0..bytes_high - 1).each do |ypage|
    (0..img.width - 1).each do |x|
      # how many bits does this line hold
      bits = 8
      # if we've reached the bottom there are fewer bits to load
      bits = bits_last_page if bytes_high-1==ypage and bits_last_page > 0
      byte = 0
      (0..bits-1).each do |bit_height|
        px = img[x, ypage*8 + bit_height]
        # print ChunkyPNG::Color.to_hex(px)
        # right now we only care about black/white so convert to greyscale
        c = ChunkyPNG::Color.grayscale_teint(px)
        # puts("#{file} #{x}, #{ypage}, #{c} #{px}")
        if c > 0
          byte += (1 << (bit_height))
        end
      end
      out.data << byte
    end
  end
  # puts out.inspect
  resource.files << out
end

File.open(resource.filename,"w") do |f|
  f.write resource.to_s
end
puts "\n#{resource.filename} compiled."
