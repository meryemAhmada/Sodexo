({
    //INI METHOD
    doInit : function(component, event, helper) {
        //Check url if an id is present -> edit mode -> set recordId + lookupFields + set Filters List
        var myPageRef = component.get("v.pageReference");
        var ruleId = myPageRef.state.c__id;
        if(ruleId != 'undefined' && ruleId != null){
            component.set("v.recordId" , ruleId);
            helper.setLookupFields(component , event);
            helper.setFilters(component , event);
        }
    },
    //HIDE/DISPLAY SECTION
    toggleSection : function(component, event, helper) {
        event.preventDefault();
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId).getElement();
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        } 
    },
    //HANDLE SUBMIT (RECORD EDIT FORM)
    submitRecord : function(component, event, helper) {
        //We validate before submit
        //Required fields verfied in server side except rule name (verified in client side)
        try{
            component.set("v.spinner" , true);
            // At least one filter criteria must be created
            if(component.get("v.filters").length > 0)
            {
                // Name field must be non empty
                if(component.find("ruleName").get("v.value") != "" && component.find("ruleName").get("v.value") != null && component.find("ruleName").get("v.value").length < 50){
                    if(component.get("v.takeActionWhen") == $A.get("$Label.c.SPIRE_Rule_Engine_Meet_Custom_Logic")){
                        //Validate filter logic if set
                        if(component.find("filterLogic").get("v.value")!=''){
                            helper.validateFilterLogic(component , event);
                        }
                        else{
                            helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Custom_Logic_Error"));  
                            component.set("v.spinner" , false);
                        }  
                    }
                    else{
                        component.find('myForm').submit();
                    }
                }
                else{
                    component.set("v.spinner" , false);
                    if(component.find("ruleName").get("v.value") == ""){
                        helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Required_Fields_Error")+': Name '+ $A.get("$Label.c.SPIRE_Rule_Engine_Missing_error"));
                    }
                    else if(component.find("ruleName").get("v.value").length >= 50){
                        helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Max_Length_Error"));
                    }
            	}
            }
            else{
                component.set("v.spinner" , false);
                helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Rule_Criteria_Missing_Error"));
            }
        }
        catch(err) {
            component.set("v.spinner" , false);
            console.log(err);
            //If name value is null -> an exception is catched here 
            helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Required_Fields_Error")+': Name '+ $A.get("$Label.c.SPIRE_Rule_Engine_Missing_error"));
        }
    },
    //HANDLE ERROR (RECORD EDIT FORM)
    onRecordError : function(component, event, helper , error) {
        //ERROR -> One of required fields empty
		component.set("v.spinner" , false);
        var errorMessage = $A.get("$Label.c.SPIRE_Rule_Engine_Required_Fields_Error") + ' : ';
        var errors = 0;
        //event.getParams().output.fieldErrors;
        for (var field in event.getParams().output.fieldErrors){
            // TECH OBJECT AND ACTION_OBJECT ARE TECHNICAL FIELDS WE DON'T DISPLAY THEM IN ERROR MESSAGE
            if(!field.toUpperCase().includes('TECH') && !field.toUpperCase().includes('ACTION_OBJECT')){
                console.log(JSON.stringify(event.getParams().output.fieldErrors[field]));
                errorMessage += event.getParams().output.fieldErrors[field][0].fieldLabel+', ';
                errors++;
            }
        }
        //DELETE LAST ', '
        errorMessage = errorMessage.slice(0, -2);
        if(errors > 1) errorMessage += ' ' + $A.get("$Label.c.SPIRE_Rule_Engine_Missing_error_are");
        else errorMessage += ' ' + $A.get("$Label.c.SPIRE_Rule_Engine_Missing_error");
        helper.showToast('error' , 'ERROR! ' , errorMessage);
    },
    //HANDLE SUCCESS (RECORD EDIT FORM)
    onRecordSuccess : function(component, event, helper) {
        //When Rule Engine Created -> Save Criterias
        helper.saveCriteriaRules(component , event);
    },
    //HANDLE OBJECT NAME CHANGE
    handleObjChange : function(component, event, helper) {
        //When object name changes 
        var filters = component.get('v.filters');
        var idsToDelete = component.get('v.idsToDelete');
        for(var i in filters){
            if(!idsToDelete.includes(filters[i].criteriaId) && filters[i].criteriaId!=null){
                idsToDelete.push(filters[i].criteriaId);
            }
        }
        component.set('v.idsToDelete' , idsToDelete);
        component.set('v.filters' , []);
    },
    //HANDLE CANCEL
    cancel : function (component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": $A.get("$Label.c.SPIRE_Rule_Engine_API_Name")
        });
        homeEvent.fire();
    }
})