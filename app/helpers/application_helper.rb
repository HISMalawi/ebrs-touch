module ApplicationHelper
  
  def application_mode
    if SETTINGS['application_mode'] == 'FC'
      return 'Facility'
    else
      return 'DC'
    end
  end

  def preferred_keyboard
    return User.current.preferred_keyboard
  end

  def facility_name
    return Location.find(SETTINGS['facility_id']).name rescue nil
  end

  def district_name
    return Location.find(SETTINGS['district_id']).name rescue nil    
  end

  def admin?
    ((User.current.user_role.role.role.strip.downcase.match(/Administrator/i) rescue false) ? true : false)
  end

end
