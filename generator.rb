require "rubygems"
require "nokogiri"
require 'active_support/inflector'

count = 0
title = ""
types = ["integer", "string", "decimal", "float", "boolean", "timestamp"]

ARGV.each do |a|
  title = "#{a}"
  count += 1
end

if count != 2
  puts "Incorrect usage. Should be:"
  puts "ruby generator.rb yourproject.bpmn yourproject.sql"
  exit
else
  if ARGV.first.size < 5 or ARGV.first[-5..-1] != ".bpmn"
    puts "Incorrect usage. First file type must be BPMN"
    exit
  else
    if ARGV.last.size < 4 or ARGV.last[-4..-1] != ".sql"
      puts "Incorrect usage. Second file type must be SQL"
      exit
    else
      title = title[0..-5]
    end
  end
end

# Reading BPMN file
bpmn = File.open("#{title}.bpmn")
doc = Nokogiri::XML(bpmn)
# Reading SQL file
er = File.open("#{title}.sql", 'r')

# Creating Rails project
system "rails new #{title}"
Dir.chdir "#{title}" do

  # Editing Gemfile
  system "cp ../generator_files/Gemfile Gemfile"

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
  system "cp ../generator_files/sessions_new.html.haml app/views/devise/sessions/new.html.haml"
  system "rm app/views/devise/registrations/edit.html.erb"
  system "cp ../generator_files/registrations_edit.html.haml app/views/devise/registrations/edit.html.haml"
  system "rm app/views/devise/registrations/new.html.erb"
  system "cp ../generator_files/registrations_new.html.haml app/views/devise/registrations/new.html.haml"
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
          f.puts "              = current_user.email"
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
  system "cp ../generator_files/application_controller.rb app/controllers/application_controller.rb"
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
  system "cp ../generator_files/seeds.rb db/seeds.rb"

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
  f.puts "    - if current_user.roles.index(\"website_administrator\")"
  f.puts "      %li"
  f.puts "        %a{:href => \"admin\/\"} Administration"
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
  
  # Parsing the SQL file
  models = []
  while line = er.gets
    if line =~ /CREATE[ ]+TABLE[ ]+/
      # Entity
      model = {"name" => line[line.index(".")+2..-5]}
      model["line"] = line
      model["attr"] = []
      model["fk"] = []
      line = er.gets
      # Attributes
      while not line =~ /PRIMARY[ ]+KEY[ ]*\(/ and not line =~ /INDEX[ ]+/
        attribute = {"name" => (/`(.*)`/.match(line)[1..-1]).first}
        attribute["line"] = line
        temptype = (/`.*`[ ]*(.*)[ ]*,/.match(line)[1..-1]).first
        attribute["type"] = nil
        attribute["type"] = "integer" if temptype =~ /INT/
        attribute["type"] = "string" if temptype =~ /TEXT/ or temptype =~ /VARCHAR/
        attribute["type"] = "decimal" if temptype =~ /DECIMAL/
        attribute["type"] = "float" if temptype =~ /FLOAT/
        attribute["type"] = "boolean" if temptype =~ /BOOL/
        attribute["type"] = "timestamp" if temptype =~ /TIMESTAMP/
        attribute["type"] = "auto_increment" if temptype =~ /AUTO_INCREMENT/
        model["attr"] << attribute if attribute["type"]
        line = er.gets
      end
      # Other data
      while not line =~ /ENGINE[ ]*=[ ]*/
        # Primary Key
        if line =~ /PRIMARY[ ]+KEY[ ]*\(/
          model["pk"] = line[line.index("(")+2..line.index(")")-2]
          model["attr"].each do |a|
            if a["name"].eql? model["pk"] and a["type"].eql? "auto_increment"
              model["attr"].delete(a)
            end
          end
        end
        # Foreign Key
        if line =~ /FOREIGN[ ]+KEY[ ]*\(/
          fk = {"attr" => line[line.index("(")+2..line.index(")")-3]}
          line = er.gets
          fk["entity"] = line[line.index(".")+2..line.index("(")-3]
          model["fk"] << fk
          model["attr"].each do |a|
            if a["name"].eql? fk["attr"]
              a["name"] = fk["entity"].downcase
              a["type"] = fk["entity"]
            end
          end
        end
        line = er.gets
      end
      models << model
    end
  end
  
  # Registrations controller
  system "mkdir app/controllers/devise"
  system "cp ../generator_files/registrations_controller.rb app/controllers/devise/registrations_controller.rb"
  #system "cp ../generator_files/_sidebar.html.haml app/views/devise/registrations/_sidebar.html.haml"
  lines = []
  f = File.open("../generator_files/_sidebar.html.haml", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("app/views/devise/registrations/_sidebar.html.haml", 'w')
  lines.each do |line|
    f.puts line
  end
  models.each do |model|
    f.puts "    %li"
    f.puts "      %a{:href => \"/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}\"} #{model["name"]}"
  end
  f.close
  
  # Admin controller
  system "rails g controller admin home"
  system "cp app/views/devise/registrations/_sidebar.html.haml app/views/admin/_sidebar.html.haml"
  f = File.open("app/views/admin/home.html.haml", 'w')
  f.puts ".block"
  f.puts "  .content"
  f.puts "    %h2.title"
  f.puts "      Administration"
  f.puts "    .inner"
  f.puts "      Start page for Administration."
  f.puts "- content_for :sidebar, render(:partial => 'sidebar')"
  f.close
  lines = []
  f = File.open("app/controllers/admin_controller.rb", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("app/controllers/admin_controller.rb", 'w')
    lines.each do |line|
      f.puts line
      f.puts "    return if auth(\"website_administrator\")" if line =~ / def .+/
    end
  f.close
  
  # Generating scaffolds
  models.each do |model|
    command = "rails g scaffold #{model["name"]}"
    model["attr"].each do |a|
      a["name"] = a["name"][0..-model["name"].size-1] if a["name"][a["name"].size-model["name"].size..-1].eql? model["name"]
      command += " #{a["name"]}:#{a["type"]}" if types.index(a["type"])
      command += " #{a["name"]}_id:integer" unless types.index(a["type"])
    end
    command += " && rake db:migrate"
    puts command
    system command
    # Creating relationships
    lines = []
    f = File.open("app/models/#{model["name"].downcase}.rb", 'r')
    while line = f.gets
      lines << line
    end
    f.close
    f = File.open("app/models/#{model["name"].downcase}.rb", 'w')
    lines.each do |line|
      f.puts line
      if line =~ /ActiveRecord::Base/
        model["attr"].each do |a|
          f.puts "  belongs_to :#{a["name"]}" unless types.index(a["type"])
          f.puts "  def to_string"
          f.puts "    return name"
          f.puts "  end"
        end
      end
    end
    f.close
    # Web-app-theme
    system "rm app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/*"
    system "rails g web_app_theme:themed #{ActiveSupport::Inflector.pluralize(model["name"].downcase)} --will-paginate --engine=haml"
    lines = []
    f = File.open("app/controllers/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}_controller.rb", 'r')
    while line = f.gets
      lines << line
    end
    f.close
    f = File.open("app/controllers/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}_controller.rb", 'w')
      lines.each do |line|
        if line =~ /@#{ActiveSupport::Inflector.pluralize(model["name"].downcase)} = #{model["name"]}.all/
          f.puts "    @#{ActiveSupport::Inflector.pluralize(model["name"].downcase)} = #{model["name"]}.page(params[:page])"
        else
          f.puts line
          f.puts "    return if auth(\"website_administrator\")" if line =~ / def .+/
        end
      end
    f.close
    system "cp app/views/devise/registrations/_sidebar.html.haml app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/_sidebar.html.haml"
    # Improving forms
    lines = []
    f = File.open("app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/_form.html.haml", 'r')
    while line = f.gets
      lines << line
    end
    f.close
    f = File.open("app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/_form.html.haml", 'w')
    lines.each do |line|
      if line =~ /= f.number_field/
        count = 0
        model["attr"].each do |a|
          if line.index("#{a["name"]}_id") and line.index("#{a["type"].downcase}_id")
            count += 1
            f.puts "  = select(\"#{model["name"].downcase}\", \"#{a["name"]}_id\", #{a["type"]}.all.collect {|p| [ p.to_string, p.id ] })"
          end
        end
        f.puts line if count == 0
      else
        f.puts line
      end
    end
    f.close
    # Improving list views
    lines = []
    f = File.open("app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/index.html.haml", 'r')
    while line = f.gets
      lines << line
    end
    f.close
    f = File.open("app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/index.html.haml", 'w')
    lines.each do |line|
      if line =~ /= will_paginate @#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/
        f.puts "        = paginate @#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}"
      else
        f.puts line
      end
    end
    f.close
    # Improving object views
    lines = []
    f = File.open("app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/show.html.haml", 'r')
    while line = f.gets
      lines << line
    end
    f.close
    f = File.open("app/views/#{ActiveSupport::Inflector.pluralize(model["name"].downcase)}/show.html.haml", 'w')
    lines.each do |line|
      count = 0
      model["attr"].each do |a|
        if line =~ /= @#{model["name"].downcase}.#{a["type"].downcase}_id/ and not types.index(a["type"])
          count += 1
          f.puts "        = #{a["type"]}.find(@#{model["name"].downcase}.#{a["type"].downcase}_id).to_string"
        end
      end
      f.puts line if count == 0
    end
    f.close
  end
  system "rails g kaminari:views default -e haml"
  
  # Configuring routes
  lines = []
  f = File.open("config/routes.rb", 'r')
  while line = f.gets
    lines << line
  end
  f.close
  f = File.open("config/routes.rb", 'w')
  pages = ["admin"]
  pools.each do |pool|
    pages << pool["code"]
  end
  lines.each do |line|
    if line =~ /\/home/
      pages.each do |page|
        f.puts "  match \"#{page}\/\" => \"#{page}#home\"" if line =~ /#{page}\/home/
      end
    else
      if line =~ /devise_for :users/
        f.puts "  devise_for :users, :controllers => { :registrations => \"devise\/registrations\" }"
      else
        f.puts line
        f.puts "  root :to => \"home#index\"" if line =~ /::Application.routes.draw do/
      end
    end
  end
  f.close
  
  puts "\n\nRuby on Rails project #{title} created.\n"
  puts "Administration account:"
  puts "Email:\t\tadmin@example.com"
  puts "Password:\tpassword\n"

end
bpmn.close
