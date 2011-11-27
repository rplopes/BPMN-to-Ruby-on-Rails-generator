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
  
  # Home page
  system "rails g controller home index"
  system "rm public/index.html"
  lines = []
  f = File.open("config/routes.rb", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("config/routes.rb", 'w')
  lines.each do |line|
    f.puts line
    f.puts "  root :to => \"home#index\"" if line =~ /::Application.routes.draw do/
  end
  f.close
  system "rake db:create"
  system "rails g web_app_theme:theme --engine=haml --app-name=\"#{title}\""
  system "rails g web_app_theme:assets"
  system "cp $(bundle show web-app-theme)/spec/dummy/public/images/* app/assets/images/web-app-theme/ -r"
  system "rm app/views/layouts/application.html.erb"
  lines = []
  f = File.open("app/assets/stylesheets/web-app-theme/themes/default/style.css", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("app/assets/stylesheets/web-app-theme/themes/default/style.css", 'w')
  lines.each do |line|
    if line =~ /.flash .error, .flash .error-list/
      f.puts ".flash .error, .flash .error-list, .flash .alert {"
    else
      f.puts line
    end
  end
  f.close
  
  # Creating users and roles
  system "rails g devise:install"
  system "rails g devise user"
  lines = []
  f = File.open("config/initializers/devise.rb", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("config/initializers/devise.rb", 'w')
  lines.each do |line|
    if line =~ /config.scoped_views = true/
      f.puts "  config.scoped_views = true"
    else
      f.puts line
    end
  end
  f.close
  system "rails g web_app_theme:theme sign --layout-type=sign --engine=haml --app-name=\"#{title}\""
  lines = []
  f = File.open("config/application.rb", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("config/application.rb", 'w')
  lines.each do |line|
    f.puts line
    if line =~ /config.assets.version = '1.0'/
      f.puts "    config.to_prepare do"
      f.puts "      Devise::SessionsController.layout \"sign\""
      f.puts "      Devise::RegistrationsController.layout \"sign\""
      f.puts "    end"
    end
  end
  f.close
  system "rails g devise:views"
  f1 = File.open("../generator_files/sessions_new.html.haml", 'r')
  f2 = File.open("app/views/devise/sessions/new.html.haml", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  f1 = File.open("../generator_files/registrations_new.html.haml", 'r')
  f2 = File.open("app/views/devise/registrations/new.html.haml", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  system "rake db:migrate"
  lines = []
  f = File.open("app/views/layouts/application.html.haml", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("app/views/layouts/application.html.haml", 'w')
  lines.each do |line|
    if line =~ /javascript_include_tag :defaults, :cache => true/
      f.puts "    = javascript_include_tag 'application'"
    else
      if line =~ /t("web-app-theme.logout", :default => "Logout")/
        f.puts "              = link_to t(\"web-app-theme.logout\", :default => \"Logout\"), destroy_user_session_path, :method => :delete"
      else
        f.puts line
      end
    end
  end
  f.close
  f1 = File.open("../generator_files/application_controller.rb", 'r')
  f2 = File.open("app/controllers/application_controller.rb", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close

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
      #puts "Web-app-theme for pool"
      #system "rails g web_app_theme:themed #{pool["code"]}s --will-paginate --engine=haml"
    end
  end
  
  # Assigning titles
#  puts "Assigning titles"
#  pools.each do |pool|
#    lines = []
#    f = File.open("app/controllers/#{pool["code"]}_controller.rb", 'r')
#    while line = f.gets
#      lines << line
#    end
#    f.close
#    f = File.open("app/controllers/#{pool["code"]}_controller.rb", 'w')
#    lines.each do |line|
#      f.puts line
#      if line =~ /  def /
#        pool["tasks"].each do |task|
#          if line["  def ".size..-2] == "#{task["lane"]["code"]}_#{task["code"]}"
#            f.puts "    @title = '#{task["title"]}'"
#            break
#          end
#        end
#      end
#    end
#    f.close
#  end
  
  # Editing layout
#  puts "Editing layout"
#  f1 = File.open("../generator_files/application.html.erb", 'r')
#  f2 = File.open("app/views/layouts/application.html.erb", 'w')
#  while line = f1.gets
#    f2.puts line
#  end
#  f1.close
#  f2.close
#  f1 = File.open("../generator_files/application.css", 'r')
#  f2 = File.open("app/assets/stylesheets/application.css", 'w')
#  while line = f1.gets
#    f2.puts line
#  end
#  f1.close
#  f2.close
  
  puts "Finished"

end
bpmn.close
