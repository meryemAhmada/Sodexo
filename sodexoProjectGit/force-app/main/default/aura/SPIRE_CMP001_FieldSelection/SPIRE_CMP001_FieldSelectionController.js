({
    //SET FIRST PICKLIST FIELDS (RELATED TO SELECTED OBJECT)
    doInit  : function(component, event, helper) {
        if(component.get('v.selectedObj') != null){
            helper.setFirstLevelFields(component , event);
        }
    },
    //IF OBJECT CHANGE -> BACK TO FIRST LEVEL FIELDS PICKIST
    handleObjChange : function(component, event, helper) {
        if(component.get('v.selectedObj') != null){
            helper.setFirstLevelFields(component , event);
        }
        component.set('v.selectedField' , null);
    },
    //HANDLE FIELD CHANGE (NON LOOKUP)
    handleChangeField : function(component, event, helper) {
        helper.handleChange(component , event , helper);
    },
    //HANDLE FIELD SELECTION (LOOKUP FIELD)
    handleClick : function(component, event, helper) {
        component.set("v.isFinalFieldSelected",false);
        var level = event.target.id;
        var selectedFields = component.get('v.selectedFields');
        selectedFields = selectedFields.slice(0,level);
        component.set("v.selectedFields" , selectedFields);
        if(selectedFields.length > 0){
            var field = selectedFields[selectedFields.length-1];
            helper.setFields(component,event,field.referencetoObj);
        }
        else{
            helper.setFirstLevelFields(component,event);
        }
    },
    //OPEN MODAL
    openModal : function(component, event, helper) {
        if(component.get('v.selectedObj') != null){
            component.set("v.isModalOpen",true);
        }
    },
    //CANCEL
    cancelClick : function(component, event, helper) {
        component.set("v.isModalOpen",false);
    },
    //CHOOSE
    chooseClick : function(component, event, helper) {
        component.set("v.selectedField" , component.get("v.chosenField"));
        helper.reset(component , event);
        component.set("v.isModalOpen",false);
    },
    //SHOW TOOLTIP
    showToolTip : function(component, event, helper) {
        component.set("v.tooltip" , true);   
    },
    //HIDE TOOLTIP
    HideToolTip : function(component, event, helper) {
        component.set("v.tooltip" , false);
    }
    
})