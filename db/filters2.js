{
  "filters" :
    {
        "my_location" : "function(doc, req){ if(req.query.location_id == doc.district_id){ return true }else{ return false }}"
    }
}
