class IncidentsController < ApplicationController
  # GET /incidents
  # GET /incidents.json
  def index
    return if auth("website_administrator")
    @incidents = Incident.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @incidents }
    end
  end

  # GET /incidents/1
  # GET /incidents/1.json
  def show
    return if auth("website_administrator")
    @incident = Incident.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @incident }
    end
  end

  # GET /incidents/new
  # GET /incidents/new.json
  def new
    return if auth("website_administrator")
    @incident = Incident.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @incident }
    end
  end

  # GET /incidents/1/edit
  def edit
    return if auth("website_administrator")
    @incident = Incident.find(params[:id])
  end

  # POST /incidents
  # POST /incidents.json
  def create
    return if auth("website_administrator")
    @incident = Incident.new(params[:incident])

    respond_to do |format|
      if @incident.save
        format.html { redirect_to @incident, :notice => 'Incident was successfully created.' }
        format.json { render :json => @incident, :status => :created, :location => @incident }
      else
        format.html { render :action => "new" }
        format.json { render :json => @incident.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /incidents/1
  # PUT /incidents/1.json
  def update
    return if auth("website_administrator")
    @incident = Incident.find(params[:id])

    respond_to do |format|
      if @incident.update_attributes(params[:incident])
        format.html { redirect_to @incident, :notice => 'Incident was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @incident.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /incidents/1
  # DELETE /incidents/1.json
  def destroy
    return if auth("website_administrator")
    @incident = Incident.find(params[:id])
    @incident.destroy

    respond_to do |format|
      format.html { redirect_to incidents_url }
      format.json { head :ok }
    end
  end
end
