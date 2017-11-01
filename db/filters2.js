{
  "filters" :
    {
        "my_location" : "function(doc, req){ if((req.query.location_id == doc.district_id) || doc.change_agent.match('user')){ return true }else{ return false }}"
    }
}
