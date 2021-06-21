({
    //SET CUSTOM LOOKUP FIELDS VALUES IF EDIT MODE
    setLookupFields : function(component , event) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getRuleEngine");
        action.setParams({ ruleEngineId : recordId});
        action.setCallback(this, function(response) {
            component.set("v.spinner" , false);
            var state = response.getState(); 
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                if(records.length > 0){
                    var record = records[0];
                    var fieldNameObj = {"pathNames" : record['SPIRE_Field_Name__c'] , "refObjName" : record['SPIRE_Action_Object__c'] , "pathLabels" : record['SPIRE_TECH_Target_Field_Label__c']};
                    component.set('v.selectedObj' , {"value" : record['SPIRE_Object_Name__c'] , "label" : record['SPIRE_TECH_Source_Object_Label__c'] });
                    component.set('v.fieldName' , fieldNameObj);
                    component.set('v.isActif' , record['SPIRE_Is_Active__c']);
                    component.set('v.takeActionWhen' , record['SPIRE_Take__c']);
                    component.set('v.ruleName' , record['Name']);
                }
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                        this.showToast('ERROR' , 'ERROR! ' , errors[0].message);
                    }
                } else {
                    this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Unknown_error"));
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    // VALIDATE FILTER LOGIC
    validateFilterLogic : function(component , event) {
        var filterLogic = component.find("filterLogic").get("v.value");
        var filterListSize = component.get("v.filters").length;
        var action = component.get("c.isFilterLogicValid");
        action.setParams({filterLogic : filterLogic , filterListSize : filterListSize});
        action.setCallback(this, function(response) {
            component.set("v.spinner" , false);
            var state = response.getState(); 
            if (state === "SUCCESS") {
                if(response.getReturnValue()){
                    component.find('myForm').submit();
                }
                else{
                    this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Custom_Logic_Error") );
                }
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                       // if(errors[0].message == 'Maximum stack depth reached: 1001'){
                            this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Custom_Logic_Error") );
                        /*}
                        else{
                            this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Custom_Logic_Error"));
                        }*/
                        console.log("Error message: " + 
                        errors[0].message);
                    }
                } else {
					this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Unknown_error"));
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    // SAVE RULE CRITERIAS
    saveCriteriaRules : function(component , event) {
        var idsTodelete = component.get("v.idsToDelete");
        var payload = event.getParams().response;
        var filters = component.get("v.filters");
        var action = component.get("c.saveCriterias");
        action.setParams({ criterias : JSON.stringify(filters) , idsTodelete : idsTodelete , ruleEngineId : payload.id});
        action.setCallback(this, function(response) {
            component.set("v.spinner" , false);
            var state = response.getState(); 
            if (state === "SUCCESS") { 
                this.showToast('success','SUCCESS! ', $A.get("$Label.c.SPIRE_Rule_Engine_Success_Message_Part1")+' '+response.getReturnValue()+ ' ' +$A.get("$Label.c.SPIRE_Rule_Engine_Success_Message_Part2"));
                var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": payload.id
                        });
                        navEvt.fire();
                 component.destroy();

            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                        this.showToast('ERROR' , 'ERROR! ' , errors[0].message);
                    }
                } else {
                    this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Unknown_error"));
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    // SET RELATED RULE CRITERIAS IF EDIT MODE
    setFilters : function(component , event) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getCriterias");
        action.setParams({ruleEngineId : recordId});
        action.setCallback(this, function(response) {
            component.set("v.spinner" , false);
            var state = response.getState(); 
            if (state === "SUCCESS") {
                component.set("v.filters" , response.getReturnValue());
            }
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                        errors[0].message);
                        this.showToast('ERROR' , 'ERROR! ' , errors[0].message);
                    }
                } else {
                    this.showToast('ERROR' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Rule_Engine_Unknown_error"));
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    //SHOW ERROR/SUCCESS MESSAGE
	showToast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type":  type,
            "message": message
        });
        toastEvent.fire();
    }
})