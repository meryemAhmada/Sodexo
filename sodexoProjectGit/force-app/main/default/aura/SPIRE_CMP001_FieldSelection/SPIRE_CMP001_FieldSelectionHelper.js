({
    //SET FIELDS OF FIRST LEVEL (FIRST PICKLIST)
    setFirstLevelFields : function(component , event) {
        component.set("v.spinner" , true);
        var action = component.get("c.getFields");
        var selectedObject = component.get("v.selectedObj").value;
        action.setParams({ selectedObject : selectedObject});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            component.set("v.spinner" , false);
            if (state === "SUCCESS") {
                var values = Object.values(response.getReturnValue());
                //Add none to options
                values.splice(0,0,{label: $A.get("$Label.c.SPIRE_Select_Field_Placeholder")});
                //Set Picklist options
                var fields = new Array();
                fields.push(values);
                component.set("v.fields" , values);
                //Set fields definition map
                var fieldsMapList = new Array();
                fieldsMapList.push(response.getReturnValue());
                component.set("v.fieldsMap" , response.getReturnValue());
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    //SET CHILD FIELDS RELATED TO referencetoObj 
    setFields : function(component , event , referencetoObj) {
        component.set("v.spinner" , true);
        var action = component.get("c.getFields");
        action.setParams({ selectedObject : referencetoObj});
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var values = Object.values(response.getReturnValue());
                //Add none to options
                values.splice(0,0,{label: $A.get("$Label.c.SPIRE_Select_Field_Placeholder")});
                //Set Picklist options
                var fields = new Array();
                fields.push(values);
                component.set("v.fields" , values);
                //Set fields definition map
                var fieldsMapList = new Array();
                fieldsMapList.push(response.getReturnValue());
                component.set("v.fieldsMap" , response.getReturnValue());
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            component.set("v.spinner" , false);
        });
        $A.enqueueAction(action);
    },
    //HANDLE FIELD CHANGE 
    handleChange : function(component , event , helper) {
        //We use map fiels to get seleted field info by its fieldname(selectedValue)
        var selectedValue = component.get("v.selectedValue");
        var fieldMap = component.get("v.fieldsMap");
        var field = fieldMap[selectedValue];
        var selectedFields = component.get('v.selectedFields');
        //Add selected field to selected fields list
        selectedFields.push(field);
        component.set("v.selectedFields" , selectedFields);
        //field.fieldtype == 'LOOKUP' -> Set picklist options
        if(field.fieldtype == 'LOOKUP'){
            helper.setFields(component,event,field.referencetoObj);
            component.set("v.selectedValue","");
        }
        //Final field -> set attributes for selected field section (preview)
        else{
            var fieldChosenPathLabels="";
            var fieldChosenPathNames="";
            var fieldChosenRefObjName="";

            //Construct field label / name path
            var selectedFields = component.get('v.selectedFields');
            for(var field in selectedFields){
                fieldChosenPathLabels += selectedFields[field].label+' > ';
                fieldChosenPathNames += selectedFields[field].name+'.';
            }
            //To eliminate last '> '
            fieldChosenPathLabels = fieldChosenPathLabels.slice(0, -2);
            //To eliminate last '.'
            fieldChosenPathNames = fieldChosenPathNames .slice(0 , -1);

            //Determine parent object name
            if(selectedFields.length > 1){
                fieldChosenRefObjName = selectedFields[selectedFields.length-2].referencetoObj;
            }
            else{
                fieldChosenRefObjName = component.get("v.selectedObj").value;
            }

            //Set chosenfield object
            var chosenField = {"pathLabels" : fieldChosenPathLabels , "pathNames" : fieldChosenPathNames , "refObjName" : fieldChosenRefObjName , "field" : selectedFields[selectedFields.length-1] };
            component.get("v.selectedFieldsSize" , selectedFields.length);
            component.set("v.chosenField" , chosenField);
            component.set("v.isFinalFieldSelected",true);
        }
    },
    //RESET COMPONENT ATTRIBUTES
    reset : function(component, event) {
        component.set("v.selectedFields" , []);
        component.set("v.selectedFieldsSize" , 0);
        component.set("v.selectedValue" , "");
        component.set("v.chosenField" , {});
        component.set("v.isFinalFieldSelected" , false);
    }

})