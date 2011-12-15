class AdminController < ApplicationController
  def home
    return if auth("website_administrator")
  end

end
