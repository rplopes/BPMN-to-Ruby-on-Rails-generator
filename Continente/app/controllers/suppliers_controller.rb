class SuppliersController < ApplicationController
  # GET /suppliers
  # GET /suppliers.json
  def index
    return if auth("website_administrator")
    @suppliers = Supplier.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @suppliers }
    end
  end

  # GET /suppliers/1
  # GET /suppliers/1.json
  def show
    return if auth("website_administrator")
    @supplier = Supplier.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @supplier }
    end
  end

  # GET /suppliers/new
  # GET /suppliers/new.json
  def new
    return if auth("website_administrator")
    @supplier = Supplier.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @supplier }
    end
  end

  # GET /suppliers/1/edit
  def edit
    return if auth("website_administrator")
    @supplier = Supplier.find(params[:id])
  end

  # POST /suppliers
  # POST /suppliers.json
  def create
    return if auth("website_administrator")
    @supplier = Supplier.new(params[:supplier])

    respond_to do |format|
      if @supplier.save
        format.html { redirect_to @supplier, :notice => 'Supplier was successfully created.' }
        format.json { render :json => @supplier, :status => :created, :location => @supplier }
      else
        format.html { render :action => "new" }
        format.json { render :json => @supplier.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /suppliers/1
  # PUT /suppliers/1.json
  def update
    return if auth("website_administrator")
    @supplier = Supplier.find(params[:id])

    respond_to do |format|
      if @supplier.update_attributes(params[:supplier])
        format.html { redirect_to @supplier, :notice => 'Supplier was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @supplier.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /suppliers/1
  # DELETE /suppliers/1.json
  def destroy
    return if auth("website_administrator")
    @supplier = Supplier.find(params[:id])
    @supplier.destroy

    respond_to do |format|
      format.html { redirect_to suppliers_url }
      format.json { head :ok }
    end
  end
end
