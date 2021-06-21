({
    //CHECK INPUT VALIDITY
    doCheck : function(component, event){
        var fieldtype = component.get("v.requestField.fieldtype");
        var field; 
        // SET AURA IDS BASED OF TYPE AS REFRENCED COMPONENTS
        if(fieldtype == 'PICKLIST' || fieldtype == 'MULTIPICKLIST' || fieldtype == 'COMBOBOX' )
        {
            field = 'valueInputPICKLIST';
        }
        else if(fieldtype == 'INTEGER' || fieldtype == 'DOUBLE' || fieldtype == 'LONG' )
        {
            field = 'valueInputNumber';
        }else{
            field = 'valueInput'+fieldtype;
        }
        var validity = component.find(field).get("v.validity");
        return validity.valid;
  }

})