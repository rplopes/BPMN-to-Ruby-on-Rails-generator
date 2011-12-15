class StoresController < ApplicationController
  # GET /stores
  # GET /stores.json
  def index
    return if auth("website_administrator")
    @stores = Store.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @stores }
    end
  end

  # GET /stores/1
  # GET /stores/1.json
  def show
    return if auth("website_administrator")
    @store = Store.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @store }
    end
  end

  # GET /stores/new
  # GET /stores/new.json
  def new
    return if auth("website_administrator")
    @store = Store.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @store }
    end
  end

  # GET /stores/1/edit
  def edit
    return if auth("website_administrator")
    @store = Store.find(params[:id])
  end

  # POST /stores
  # POST /stores.json
  def create
    return if auth("website_administrator")
    @store = Store.new(params[:store])

    respond_to do |format|
      if @store.save
        format.html { redirect_to @store, :notice => 'Store was successfully created.' }
        format.json { render :json => @store, :status => :created, :location => @store }
      else
        format.html { render :action => "new" }
        format.json { render :json => @store.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stores/1
  # PUT /stores/1.json
  def update
    return if auth("website_administrator")
    @store = Store.find(params[:id])

    respond_to do |format|
      if @store.update_attributes(params[:store])
        format.html { redirect_to @store, :notice => 'Store was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @store.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    return if auth("website_administrator")
    @store = Store.find(params[:id])
    @store.destroy

    respond_to do |format|
      format.html { redirect_to stores_url }
      format.json { head :ok }
    end
  end
end
