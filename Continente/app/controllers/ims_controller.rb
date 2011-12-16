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
  end

  def suppliersmanager_logisticsincidentresolution
    auth("ims_suppliersmanager")
  end

  def technicalstaff_technicalincidentresolution
    auth("ims_technicalstaff")
  end

  def boardofdirectors_criticalincidentresolution
    auth("ims_boardofdirectors")
  end

  def servicedesk_resolved
    auth("ims_servicedesk")
    if params[:resolution]
      incident = session[:current_incident]
      incident.resolution = params[:resolution]
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
  end

  def suppliersmanager_resolved
    auth("ims_suppliersmanager")
  end

  def technicalstaff_resolved
    auth("ims_technicalstaff")
  end

end
