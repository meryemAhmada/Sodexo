({
    // FIELD SELECTED CHANGE -> Set operation and reset values
    handleFieldChange : function(component, event, helper) {
        helper.setOperators(component , event);
        helper.reset(component);
    },
    //RESET EDIT MODE WHEN SELECTED OBJECT CHANGES
    handleObjChange : function(component, event, helper) {
        component.set("v.isEditMode" , false);
    },
    //WHEN [TODAY] IS CLICKED -> SET SELECTED FORMULA FIELD VALUE = TODAY
    setFormulaFieldToday : function(component, event, helper) {
        component.set("v.selectedFormulaField" , {"pathLabels" : "TODAY" , "pathNames" : "TODAY"});
    },
    //FILL FIELDS WITH SELECTED RULE CRITERIA VALUES
    setFieldToModify : function(component, event, helper) {
        //Get index
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        
        //Reset existing values
        helper.reset(component);
        
        //Set edit mode
        component.set("v.editingIndex" , index);
        component.set("v.isEditMode" , true);
        var filters = component.get("v.filters");
        component.set("v.selectedType" , filters[index].type);
        //Set selected Values 
        if(component.get("v.selectedType") == $A.get("$Label.c.SPIRE_Criteria_Editor_Type_Value_Option")){
        	helper.fillValueFileds(component , index);
        }
        else if(component.get("v.selectedType") == $A.get("$Label.c.SPIRE_Criteria_Editor_Field_Reference_Type_Option")){
            helper.fillFieldReferenceFields(component , index);
        }
        else if(component.get("v.selectedType") == $A.get("$Label.c.SPIRE_Criteria_Editor_Formula_Type_Option")){
            helper.fillFormulaFields(component , index);       
        }
    },
    // ADD NEW RULE CRITERIA (MODIFY / ADD)
    addRow : function(component, event, helper) {
        var selectedField = component.get("v.selectedField");
        if(selectedField != null){
            var selectedType = component.get("v.selectedType");
            var selectedOperator = component.get("v.selectedOperator");
            if(selectedOperator ==  $A.get("$Label.c.SPIRE_Criteria_Editor_Is_Null_Value")){
                helper.addValueRow(component , event);
            }
            else if (selectedType == $A.get("$Label.c.SPIRE_Criteria_Editor_Type_Value_Option")){
                var simpleInput = component.find("simpleInput");
                if(simpleInput.doValidityCheck()){
                    helper.addValueRow(component , event);
                }
                else{
                    helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Value_Error"));
                }
            }
            else if(selectedType == $A.get("$Label.c.SPIRE_Criteria_Editor_Field_Reference_Type_Option")){
                helper.addFieldReferenceRow(component , event);
            }
            else if(selectedType == $A.get("$Label.c.SPIRE_Criteria_Editor_Formula_Type_Option")){
                helper.addFormulaRow(component , event);
            }
        }
        else{
            helper.showToast('error' , 'ERROR! ' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Field_Name"));
        }
    },
    // REMOVE RULE CRITERIA ROW
    removeRow : function(component, event, helper) {
        var ctarget = event.currentTarget;
        var index = ctarget.dataset.value;
        var filters = component.get("v.filters");
        if(filters[index].criteriaId != undefined){
            var idsToDelete = component.get('v.idsToDelete');
            idsToDelete.push(filters[index].criteriaId);
            component.set("v.idsToDelete",idsToDelete);
        }
        filters.splice(index, 1);
        component.set("v.filters" , filters);
        component.set("v.isEditMode" , false);
    },
    //CLEAR TYPE & VALUE 
    clearValue : function(component, event, helper) {
        component.set("v.selectedValue" , '');
        component.set("v.selectedType" , 'Value');
    }
})