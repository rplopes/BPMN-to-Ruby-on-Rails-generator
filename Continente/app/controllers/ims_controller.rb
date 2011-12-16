class ImsController < ApplicationController
  def home
  end

  def servicedesk_loggingandclassification
    auth("ims_servicedesk")
  end

  def servicedesk_knowledgedatabasequery
    auth("ims_servicedesk")
    @resolved_incident = Incident.find(params[:id]) if params[:id]
    unless @resolved_incident
      incidents = Incident.where("resolution IS NOT NULL")
      @incidents = []
      incidents.each do |incident|
        @incidents << incident if incident.resolution.size > 0
      end
    end
  end

  def infrastructureresponsible_productincidentresolution
    auth("ims_infrastructureresponsible")
    @incident = Incident.find(params[:id]) if params[:id]
    if @incident
      if params[:resolution] and params[:resolution].size > 0
        @incident.resolution = params[:resolution]
        @incident.state = "resolved"
        @incident.save
        redirect_to ims_infrastructureresponsible_productincidentresolution_path, :notice => 'Incident was successfully closed.'
      end
    else
      incidents = Incident.find_all_by_state("infrastructureresponsible")
      incidents ||= []
      @incidents = []
      incidents.each do |incident|
        @incidents << incident if not incident.resolution or incident.resolution.size == 0
      end
    end
  end

  def suppliersmanager_logisticsincidentresolution
    auth("ims_suppliersmanager")
    @incident = Incident.find(params[:id]) if params[:id]
    if @incident
      if params[:resolution] and params[:resolution].size > 0
        @incident.resolution = params[:resolution]
        @incident.state = "resolved"
        @incident.save
        redirect_to ims_suppliersmanager_logisticsincidentresolution_path, :notice => 'Incident was successfully closed.'
      end
    else
      incidents = Incident.find_all_by_state("suppliersmanager")
      incidents ||= []
      @incidents = []
      incidents.each do |incident|
        @incidents << incident if not incident.resolution or incident.resolution.size == 0
      end
    end
  end

  def technicalstaff_technicalincidentresolution
    auth("ims_technicalstaff")
    @incident = Incident.find(params[:id]) if params[:id]
    if @incident
      if params[:resolution] and params[:resolution].size > 0
        @incident.resolution = params[:resolution]
        @incident.state = "resolved"
        @incident.save
        redirect_to ims_technicalstaff_technicalincidentresolution_path, :notice => 'Incident was successfully closed.'
      end
    else
      incidents = Incident.find_all_by_state("technicalstaff")
      incidents ||= []
      @incidents = []
      incidents.each do |incident|
        @incidents << incident if not incident.resolution or incident.resolution.size == 0
      end
    end
  end

  def boardofdirectors_criticalincidentresolution
    auth("ims_boardofdirectors")
    @incident = Incident.find(params[:id]) if params[:id]
    if @incident
      if params[:resolution] and params[:resolution].size > 0
        @incident.resolution = params[:resolution]
        @incident.state = "resolved"
        @incident.save
        redirect_to ims_boardofdirectors_criticalincidentresolution_path, :notice => 'Incident was successfully closed.'
      end
    else
      incidents = Incident.find_all_by_state("boardofdirectors")
      incidents ||= []
      @incidents = []
      incidents.each do |incident|
        @incidents << incident if not incident.resolution or incident.resolution.size == 0
      end
    end
  end

  def servicedesk_resolved
    auth("ims_servicedesk")
    if params[:resolution] and params[:resolution].size > 0
      incident = session[:current_incident]
      incident.resolution = params[:resolution]
      incident.state = "resolved"
      incident.save
      session[:current_incident] = nil
      redirect_to ims_servicedesk_loggingandclassification_path, :notice => 'Incident was successfully closed.'
    end
  end

  def servicedesk_delegation
    auth("ims_servicedesk")
    if params[:delegation]
      incident = session[:current_incident]
      incident.state = params[:delegation]
      incident.save
      session[:current_incident] = nil
      redirect_to ims_servicedesk_loggingandclassification_path, :notice => 'Incident was successfully delegated.'
    end
  end

  def infrastructureresponsible_resolved
    auth("ims_infrastructureresponsible")
    @incident = Incident.find(params[:id]) if params[:id]
    if params[:delegation] and params[:id]
      @incident.state = params[:delegation]
      @incident.save
      redirect_to ims_infrastructureresponsible_productincidentresolution_path, :notice => 'Incident was successfully delegated.'
    end
  end

  def suppliersmanager_resolved
    auth("ims_suppliersmanager")
    @incident = Incident.find(params[:id]) if params[:id]
    if params[:delegation] and params[:id]
      @incident.state = params[:delegation]
      @incident.save
      redirect_to ims_suppliersmanager_logisticsincidentresolution_path, :notice => 'Incident was successfully delegated.'
    end
  end

  def technicalstaff_resolved
    auth("ims_technicalstaff")
    @incident = Incident.find(params[:id]) if params[:id]
    if params[:delegation] and params[:id]
      @incident.state = params[:delegation]
      @incident.save
      redirect_to ims_technicalstaff_technicalincidentresolution_path, :notice => 'Incident was successfully delegated.'
    end
  end

end