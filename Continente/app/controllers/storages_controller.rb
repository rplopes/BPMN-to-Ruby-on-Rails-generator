class StoragesController < ApplicationController
  # GET /storages
  # GET /storages.json
  def index
    return if auth("website_administrator")
    @storages = Storage.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @storages }
    end
  end

  # GET /storages/1
  # GET /storages/1.json
  def show
    return if auth("website_administrator")
    @storage = Storage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @storage }
    end
  end

  # GET /storages/new
  # GET /storages/new.json
  def new
    return if auth("website_administrator")
    @storage = Storage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @storage }
    end
  end

  # GET /storages/1/edit
  def edit
    return if auth("website_administrator")
    @storage = Storage.find(params[:id])
  end

  # POST /storages
  # POST /storages.json
  def create
    return if auth("website_administrator")
    @storage = Storage.new(params[:storage])

    respond_to do |format|
      if @storage.save
        format.html { redirect_to @storage, :notice => 'Storage was successfully created.' }
        format.json { render :json => @storage, :status => :created, :location => @storage }
      else
        format.html { render :action => "new" }
        format.json { render :json => @storage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /storages/1
  # PUT /storages/1.json
  def update
    return if auth("website_administrator")
    @storage = Storage.find(params[:id])

    respond_to do |format|
      if @storage.update_attributes(params[:storage])
        format.html { redirect_to @storage, :notice => 'Storage was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @storage.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /storages/1
  # DELETE /storages/1.json
  def destroy
    return if auth("website_administrator")
    @storage = Storage.find(params[:id])
    @storage.destroy

    respond_to do |format|
      format.html { redirect_to storages_url }
      format.json { head :ok }
    end
  end
end
