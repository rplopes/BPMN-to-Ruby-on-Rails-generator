require "rubygems"
require "nokogiri"

count = 0
title = ""

ARGV.each do|a|
  title = "#{a}"
  count += 1
end

if count != 1
  puts "Incorrect usage. Should be:"
  puts "ruby generator.rb bpmn.bpmn"
  exit
else
  if title.size < 5 or title[-5..-1] != ".bpmn"
    puts "Incorrect usage. File type must be BPMN"
    exit
  else
    title = title[0..-6]
    puts title
  end
end

# Reading BPMN file
bpmn = File.open("#{title}.bpmn")
doc = Nokogiri::XML(bpmn)
#doc.css("definitions process").each do |process|
#  puts process
#end

# Creating Rails project
puts "Creating Rails project"
system "rails new #{title}"
Dir.chdir "#{title}" do

  # Editing Gemfile
  puts "Editing Gemfile"
  f1 = File.open("../generator_files/Gemfile", 'r')
  f2 = File.open("Gemfile", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close

  # Bundle install
  puts "Installing required gems"
  system "bundle install"

  # Parsing the BPMN file
  puts "Parsing the BPMN file"
  pools = []
  doc.css("definitions process").each do |process|
    pool = {}
    pool["title"] = process["name"]
    pool["title"] = process["id"] if pool["title"] == nil or pool["title"].size < 1
    pool["code"] = pool["title"].gsub(/[^A-z0-9]/,'').downcase
    pool["tasks"] = []
    tasks = []
    process.css("laneSet lane").each do |role|
      lane = {}
      lane["title"] = role["name"]
      lane["title"] = pool["title"] if lane["title"] == nil or lane["title"].size < 1
      lane["code"] = lane["title"].gsub(/[^A-z0-9]/,'').downcase
      role.css("flowNodeRef").each do |node|
        tasks << {"id" => node.text, "lane" => lane}
      end
    end
    process.css("task, exclusiveGateway, startEvent, endEvent").each do |node|
      tasks.each do |task|
        if task["id"] == node["id"]
          if node["name"] != nil and node["name"].size > 0
            task["title"] = node["name"]
            task["code"] = task["title"].gsub(/[^A-z0-9]/,'').downcase
            pool["tasks"] << task
          end
          break
        end
      end
    end
    pools << pool if pool["tasks"].size > 0
  end
  
  # Creating controllers
  puts "Creating controllers"
  pools.each do |pool|
    if pool["tasks"].size > 0
      command = "rails g controller #{pool["code"]}"
      pool["tasks"].each do |task|
        command += " #{task["lane"]["code"]}_#{task["code"]}"
      end
      puts command
      system command
    end
  end
  
  # Assigning titles
  puts "Assigning titles"
  pools.each do |pool|
    lines = []
    f = File.open("app/controllers/#{pool["code"]}_controller.rb", 'r')
    while line = f.gets
      lines << line
    end
    f.close
    f = File.open("app/controllers/#{pool["code"]}_controller.rb", 'w')
    lines.each do |line|
      f.puts line
      if line =~ /  def /
        pool["tasks"].each do |task|
          if line["  def ".size..-2] == "#{task["lane"]["code"]}_#{task["code"]}"
            f.puts "    @title = '#{task["title"]}'"
            break
          end
        end
      end
    end
    f.close
  end
  
  # Editing layout
  puts "Editing layout"
  f1 = File.open("../generator_files/application.html.erb", 'r')
  f2 = File.open("app/views/layouts/application.html.erb", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  f1 = File.open("../generator_files/application.css", 'r')
  f2 = File.open("app/assets/stylesheets/application.css", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  
  puts "Finished"

end
bpmn.close
