module ApplicationHelper
  
  def application_mode
    if SETTINGS['application_mode'] == 'FC'
      return 'Facility'
    else
      return 'DC'
    end
  end

end
