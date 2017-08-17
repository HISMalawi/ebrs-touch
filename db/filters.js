{
  "filters" :
    {
        "my_location" : "function(doc, req){ var k = ''; if(doc['person_a']){k = doc['person_relationship_id'].toString()}; if(doc['person_name_id']){k = doc['person_name_id'].toString()}; if(doc['person_id']){k = doc['person_id'].toString()}; if(doc['user_id']){k = doc['user_id'].toString()}; k = k.substr(0, 6); if(k == req.query.location_id){ return true }else{ return false }}"
    }
}
