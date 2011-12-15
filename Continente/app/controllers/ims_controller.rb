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
  end

  def servicedesk_delegation
    auth("ims_servicedesk")
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
