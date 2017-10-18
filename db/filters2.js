{
  "filters" :
    {
        "my_location" : "function(doc, req){ if(req.query.location_id == doc.district_id || ['users', 'user_role'].indexOf(doc.change_agent) >= 0 || doc.district_id == '356' || doc.district_id == 356){ return true }else{ return false }}"
    }
}
