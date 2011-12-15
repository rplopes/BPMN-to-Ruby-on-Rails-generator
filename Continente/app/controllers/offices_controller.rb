class OfficesController < ApplicationController
  # GET /offices
  # GET /offices.json
  def index
    return if auth("website_administrator")
    @offices = Office.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @offices }
    end
  end

  # GET /offices/1
  # GET /offices/1.json
  def show
    return if auth("website_administrator")
    @office = Office.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @office }
    end
  end

  # GET /offices/new
  # GET /offices/new.json
  def new
    return if auth("website_administrator")
    @office = Office.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @office }
    end
  end

  # GET /offices/1/edit
  def edit
    return if auth("website_administrator")
    @office = Office.find(params[:id])
  end

  # POST /offices
  # POST /offices.json
  def create
    return if auth("website_administrator")
    @office = Office.new(params[:office])

    respond_to do |format|
      if @office.save
        format.html { redirect_to @office, :notice => 'Office was successfully created.' }
        format.json { render :json => @office, :status => :created, :location => @office }
      else
        format.html { render :action => "new" }
        format.json { render :json => @office.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /offices/1
  # PUT /offices/1.json
  def update
    return if auth("website_administrator")
    @office = Office.find(params[:id])

    respond_to do |format|
      if @office.update_attributes(params[:office])
        format.html { redirect_to @office, :notice => 'Office was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @office.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /offices/1
  # DELETE /offices/1.json
  def destroy
    return if auth("website_administrator")
    @office = Office.find(params[:id])
    @office.destroy

    respond_to do |format|
      format.html { redirect_to offices_url }
      format.json { head :ok }
    end
  end
end
