require 'bindata'
require 'optparse'
require 'ostruct'
@@options  = OpenStruct.new
@@usage = "Usage: xpmglitch.rb [mode n] <inputfile> [output count]"


def range (min, max)
  (rand * (max-min) + min).to_i
end
def rangeFloat (min, max)
  (rand * (max-min) + min)
end
class Array
  def moveInArray(from, to)
    self.insert(to, self.delete_at(from))
  end
end

OptionParser.new do |opts|
  opts.banner = @@usage
  opts.on("-m MODE", String, "select mode (A,B,C,D,E) or blank for random") do |m|
    @@options.mode = m
  end
  opts.on("-h","--help") do |h|
    puts @@usage
    puts "available modes are (A,B,C,D,E) or blank for random"
    exit
  end
end.parse!


def xpm(input, options, outputCount)
  # outputCount = outputCount ? nil : 1
  outputCount == nil ? outputCount=1 : nil
  outputCount = outputCount.to_i-1
  xpmHeader, xpmBody = Array.new,Array.new
  if input == nil
    puts @@usage
    return
  end
  @fileExt = File.extname(input)
  @fileName = File.basename(input).gsub(/\.\w{3,4}/,'')
  @filePath = File.dirname(input)

  if @fileExt != 'xpm'
    convert = true;
    system("convert #{input} import.xpm")
    input = "import.xpm"
  end

  xpmLine = false
  File.open(input).each_line do |s|
    if (!xpmLine)
    xpmHeader << s
    else
    xpmBody << s
    end
    if s.include? "/* pixels */"
    xpmLine = true
    end
  end

  0.upto(outputCount).each do |outputs|
  xpmBodyTemp = Array.new
  xpmBody.each do |a|
    xpmBodyTemp << a[1..a.length-4].scan(/../)
  end
  width = xpmBodyTemp[1].length.to_i
  height = xpmBodyTemp.length.to_i

  if options.mode == nil 
    mode = ["A","B","C","D","E"].sample
  else
    mode = options.mode.upcase
  end
  puts 'mode '+mode
    case mode
     when "A"
      #   # MODE SORT
      xpmBodyTemp.each_with_index do |a,i|
        xpmBodyTemp[i]=a.sort
      end
    when "B"
      # MODE SEGMENTED SLICER

      iterations = range(2,30);
      slant = 0;
      slantAngle = range(-5,5)
      sampleWidth = range(4,width)
      sampleHeight = range(2,width/2)

      startingPoint = range(0,width)
      destinationPoint = range(0,width)

      0.upto(iterations).each_with_index do |a, t|
        xpmBodyTemp.each_with_index do |a,i|
          if i%sampleHeight==0
            slant = 0
            startingPoint = range(0,width-sampleWidth)
            destinationPoint = range(0,width-sampleWidth)
          end

          0.upto(sampleWidth).each_with_index do |row, r|
            xpmBodyTemp[i].moveInArray(startingPoint+r+slant, destinationPoint+r);
          end

          slant+=slantAngle;
        end

      end
    when "C"
      #MODE RANDOMIZE
      xpmBodyTemp.each_with_index do |a,i|
        xpmBodyTemp[i]=a.sort_by{rand}
      end
    when "D"
      #MODE X
      multiplier = range(3,20)
      barWidth = width/multiplier 

      0.upto(multiplier).each_with_index do |multiplier, i|
        slant = range(0,4)
        slant = 2
        x = 0
        tempCollection = Array.new

        xpmBodyTemp.each_with_index do |line,l|
          if width>height
            x = (width/height*slant*width/height);
            x = width-x
          else
            x = height-(height/width*slant*width/height);
            x = height-x
          end
          x = x + barWidth*multiplier

          for v in (-barWidth/2..barWidth/2)
            tempCollection << line[x+v]
          end

          tempCollection=tempCollection.sort{|a,b|( a and b ) ? a <=> b : ( a ? -1 : 1 ) }

          for v in (-barWidth/2..barWidth/2)
            begin
              line[x+v] = tempCollection.pop
            rescue IndexError
            end
          end

          xpmBody[slant]=line
          # slant+=slant
        end

      end
    when "E"
      # MODE DRIZZLE
      iterations = range(1,15);
      phase = 0;
      sampleWidth = range(5,width/2)

      xpmBodyTemp.each_with_index do |a,i|
        0.upto(iterations).each_with_index do |a, t|
          startingPoint = range(0,width-sampleWidth)
          destinationPoint = range(0,width-sampleWidth)

          0.upto(sampleWidth).each_with_index do |row, r|
            xpmBodyTemp[i].moveInArray(startingPoint+r, destinationPoint+r);
          end

        end
      end
    end

    File.open(@filePath+'/export.xpm', 'w') do |xpm|
      xpm.puts xpmHeader
      xpmBodyTemp.each_with_index do |line,s|
        if line.length>0
          if s==xpmBodyTemp.length
            xpm.puts "\"#{line.join}\""
          else
            xpm.puts "\""+line.join+"\","
          end
        end
      end
      xpm.puts "};"
    end


    if(convert)
      u = (0..1).map{65.+(rand(25)).chr}.join.to_s.upcase
      suffix = Time.now.to_i.to_s.split(//).last(5).push(u).join
      system("convert export.xpm #{@fileName}-x-#{mode}-#{suffix}.png")
      puts "#{@fileName}-x-#{mode}-#{suffix}.png"
    end
  end
end

xpm(ARGV[0], @@options, ARGV[1])
system("rm import.xpm")
system("rm export.xpm")
