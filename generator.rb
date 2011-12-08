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

# Creating Rails project
puts "Creating Rails project"
system "rails new #{title}"
Dir.chdir "#{title}" do

  # Editing Gemfile
  f1 = File.open("../generator_files/Gemfile", 'r')
  f2 = File.open("Gemfile", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close

  # Bundle install
  system "bundle install"
  
  # Home page
  system "rails g controller home index"
  system "rm public/index.html"
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
  
  # Creating users
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
  system "rake db:migrate"
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
      f.puts "      #Devise::RegistrationsController.layout \"sign\""
      f.puts "    end"
    end
  end
  f.close
  system "rails g devise:views"
  system "rm app/views/devise/sessions/new.html.erb"
  f1 = File.open("../generator_files/sessions_new.html.haml", 'r')
  f2 = File.open("app/views/devise/sessions/new.html.haml", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  #system "rm app/views/devise/registrations/edit.html.erb"
  f1 = File.open("../generator_files/registrations_edit.html.haml", 'r')
  f2 = File.open("app/views/devise/registrations/edit.html.haml", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  system "rm app/views/devise/registrations/new.html.erb"
  f1 = File.open("../generator_files/registrations_new.html.haml", 'r')
  f2 = File.open("app/views/devise/registrations/new.html.haml", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  lines = []
  f = File.open("app/views/layouts/application.html.haml", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("app/views/layouts/application.html.haml", 'w')
  dontput = -1
  lines.each do |line|
    if dontput > 0
      dontput -= 1
    else
      if line =~ /javascript_include_tag :defaults, :cache => true/
        f.puts "    = javascript_include_tag 'application'"
      else
        if line =~ /web-app-theme\.logout/
          f.puts "              = link_to 'Edit account', '/users/edit'"
          f.puts "            %li"
          f.puts "              = link_to t(\"web-app-theme.logout\", :default => \"Logout\"), destroy_user_session_path, :method => :delete"
        else
          f.puts line
          f.puts "    = javascript_include_tag :defaults" if line =~ /csrf_meta_tag/
        end
      end
    end
    dontput = 4 if line =~ /ul.wat-cf/ and dontput == -1
  end
  f.close
  f1 = File.open("../generator_files/application_controller.rb", 'r')
  f2 = File.open("app/controllers/application_controller.rb", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  lines = []
  f = File.open("app/views/layouts/sign.html.haml", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("app/views/layouts/sign.html.haml", 'w')
  lines.each do |line|
    f.puts line
    f.puts "        %h1 #{title}" if line =~ /#box/
  end
  f.close
  f1 = File.open("../generator_files/seeds.rb", 'r')
  f2 = File.open("db/seeds.rb", 'w')
  while line = f1.gets
    f2.puts line
  end
  f1.close
  f2.close
  #system "rails g devise_invitable:install"
  #system "rails g devise_invitable user"

  # Parsing the BPMN file
  pools = []
  doc.css("definitions process").each do |process|
    pool = {}
    pool["title"] = process["name"]
    pool["title"] = process["id"] if pool["title"] == nil or pool["title"].size < 1
    pool["code"] = pool["title"].gsub(/[^A-z0-9]/,'').downcase
    pool["tasks"] = []
    pool["lanes"] = []
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
            pool["lanes"] << task["lane"] unless pool["lanes"].index(task["lane"])
          end
          break
        end
      end
    end
    pools << pool if pool["tasks"].size > 0
  end
  
  # Creating roles
  system "rails g cancan:ability"
  system "rails generate migration add_roles_mask_to_users roles_mask:integer"
  system "rake db:migrate"
  f1 = File.open("../generator_files/user.rb", 'r')
  f2 = File.open("app/models/user.rb", 'w')
  while line = f1.gets
    f2.puts line
    if line =~ /class User < ActiveRecord::Base/
      roles = "  ROLES = %w[website_administrator "
      roles_titles = "  ROLES_TITLES = {\"website_administrator\" => \"Website Administrator\", "
      pools.each do |pool|
        pool["lanes"].each do |lane|
          roles += "#{pool["code"]}_#{lane["code"]} "
          roles_titles += "\"#{pool["code"]}_#{lane["code"]}\" => \"#{lane["title"]}\", "
        end
      end
      roles = roles[0..-2] + "]"
      roles_titles = roles_titles[0..-3] + "}"
      f2.puts roles
      f2.puts roles_titles
    end
  end
  f1.close
  f2.close
  f = File.open("app/models/ability.rb", 'w')
  f.puts "class Ability"
  f.puts "  include CanCan::Ability\n"
  f.puts "  def initialize(user)"
  f.puts "    user ||= User.new"
  pools.each do |pool|
    pool["lanes"].each do |lane|
      f.puts "    if user.#{pool["code"]}_#{lane["code"]}?"
      f.puts "      can :#{pool["code"]}_#{lane["code"]}, :all"
    end
  end
  f.puts "    end"
  f.puts "  end"
  f.puts "end"
  f.close
  system "rake db:seed"
  
  # Home page layout
  f = File.open("app/views/home/_sidebar.html.haml", 'w')
  f.puts ".block"
  f.puts "  %h3 Pages"
  f.puts "  %ul.navigation"
  pools.each do |pool|
    f.puts "    %li"
    f.puts "      %a{:href => \"#{pool["code"]}\/\"} #{pool["title"]}"
  end
  f = File.open("app/views/home/index.html.haml", 'w')
      f.puts ".block"
      f.puts "  .content"
      f.puts "    %h2.title"
      f.puts "      #{title}"
      f.puts "    .inner"
      f.puts "      Start page for #{title}."
      f.puts "- content_for :sidebar, render(:partial => 'sidebar')"
      f.close
  
  # Creating controllers
  pools.each do |pool|
    if pool["tasks"].size > 0
      command = "rails g controller #{pool["code"]} home"
      pool["tasks"].each do |task|
        command += " #{task["lane"]["code"]}_#{task["code"]}"
      end
      puts command
      system command
      # Controller
      lines = []
      f = File.open("app/controllers/#{pool["code"]}_controller.rb", 'r')
      while line = f.gets
        lines << line
      end
      f.close
      f = File.open("app/controllers/#{pool["code"]}_controller.rb", 'w')
      lines.each do |line|
        f.puts line
        f.puts "    auth(\"#{pool["code"]}_#{line["  def ".size..line.index("_")-1]}\")" if line =~ /def .*_.*/
      end
      f.close
      # Sidebar
      f = File.open("app/views/#{pool["code"]}/_sidebar.html.haml", 'w')
      f.puts ".block"
        pool["lanes"].each do |lane|
          f.puts "  - if current_user.roles.index(\"#{pool["code"]}_#{lane["code"]}\")"
          f.puts "    %h3 #{lane["title"]}"
          f.puts "    %ul.navigation"
          pool["tasks"].each do |task|
            if task["lane"]["code"] == lane["code"]
              f.puts "      %li"
              f.puts "        %a{:href => \"#{task["lane"]["code"]}_#{task["code"]}\"} #{task["title"]}"
            end
          end
        end
      f.close
      # Views
      pool["tasks"].each do |task|
        f = File.open("app/views/#{pool["code"]}/#{task["lane"]["code"]}_#{task["code"]}.html.haml", 'w')
        f.puts ".block"
        f.puts "  .content"
        f.puts "    %h2.title"
        f.puts "      #{task["title"]}"
        f.puts "    .inner"
        f.puts "      Page for #{task["title"]}, accessible by #{task["lane"]["title"]}."
        f.puts "- content_for :sidebar, render(:partial => 'sidebar')"
        f.close
      end
      f = File.open("app/views/#{pool["code"]}/home.html.haml", 'w')
      f.puts ".block"
      f.puts "  .content"
      f.puts "    %h2.title"
      f.puts "      #{pool["title"]}"
      f.puts "    .inner"
      f.puts "      Start page for #{pool["title"]}."
      f.puts "- content_for :sidebar, render(:partial => 'sidebar')"
      f.close
    end
  end
  
  # Configuring routes
  lines = []
  f = File.open("config/routes.rb", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("config/routes.rb", 'w')
  lines.each do |line|
    if line =~ /#{pools.last["code"]}\/home/ # Nao esta correcto!!!!!!!!!
      f.puts "  match \"#{pools.last["code"]}\/\" => \"#{pools.last["code"]}#home\"" # Nao esta correcto!!!!!!!!!
    else
      f.puts line
      f.puts "  root :to => \"home#index\"" if line =~ /::Application.routes.draw do/
    end
  end
  f.close
  
  puts "\nRuby on Rails project #{title} created."
  puts "Administration account:"
  puts "Email: admin@example.com"
  puts "Password: password\n"

end
bpmn.close
