({
    //SET OPERATORS DEPENDING ON SELECTEDFIELD TYPE
    setOperators : function(component , field) {
        var selectedField = component.get("v.selectedField");
        if(selectedField != null){
            var operators = selectedField.field.operators;
            component.set("v.operators" , operators);
            component.set("v.selectedOperator" , operators[0].value);
            component.set("v.currentField" , selectedField.field);
        }
        else{
            component.set("v.operators" , []); 	
        }
        component.set('v.selectedValue' , '');
        component.set('v.selectedType' ,  $A.get("$Label.c.SPIRE_Criteria_Editor_Type_Value_Option"));
        component.set('v.selectedFieldValue' , {});
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
    },
    //ADD CRITERIA RULE OF VALUE TYPE
    addValueRow : function(component , event) {
        var selectedField = component.get("v.selectedField");
        var selectedType = component.get("v.selectedType");
        var selectedOperator = component.get("v.selectedOperator");
        var selectedValue = component.get("v.selectedValue");
        //VALIDATE THAT SELECTED VALUE IS NOT EMPTY
        if(selectedValue == '' || selectedValue == null){
            this.showToast('error' , 'ERROR!' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Value_Error"));
        }
        else{
            if(component.get("v.isEditMode")){
                var index = component.get("v.editingIndex");
                this.modifyRowValues(component , index , selectedField , selectedOperator , selectedValue , selectedType , '' , '' , '' , '' , '' );
            }
            else{
                this.pushRow(component , selectedField , selectedOperator , selectedValue , selectedType , '' , '' , '' , '' , '' );
            }
            this.reset(component);
        }
    },
    //ADD CRITERIA RULE OF REFERENCE TYPE
    addFieldReferenceRow : function(component , event) {
        var selectedField = component.get("v.selectedField");
        var selectedType = component.get("v.selectedType");
        var selectedOperator = component.get("v.selectedOperator");
        var selectedValue = '';
        var fieldValueLabel = '';
        //VALIDATE THAT SELECTED VALUE FIELD IS NOT EMPTY
        if(component.get("v.selectedFieldValue") != null){
            selectedValue = component.get("v.selectedFieldValue").pathNames;
        	fieldValueLabel = component.get("v.selectedFieldValue").pathLabels;
        }
        if(selectedValue == '' || selectedValue == null){
            this.showToast('error' , 'ERROR!' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Value_Error"));
        }
        else{
            if(component.get("v.isEditMode")){
                var index = component.get("v.editingIndex");
                this.modifyRowValues(component , index , selectedField , selectedOperator , selectedValue , selectedType , fieldValueLabel , '' , '' , '' , '' );
            }
            else{
                this.pushRow(component , selectedField , selectedOperator , selectedValue , selectedType , fieldValueLabel , '' , '' , '' , '' );
            }
            this.reset(component);   
        }
    },
    //ADD CRITERIA RULE OF FROMULA TYPE
    addFormulaRow : function(component , event) {
        var selectedField = component.get("v.selectedField");
        var selectedType = component.get("v.selectedType");
        var selectedOperator = component.get("v.selectedOperator");
        var formulaOperator = component.get("v.selectedFormulaOperator");
        var formulaValue = component.get("v.selectedFormulaValue");
        var isValid = true;
        //VALIDATE THAT SELECTED FORMULA FIELD VALUE IS NOT EMPTY
        if(component.get("v.selectedFormulaField") == null){
            isValid = false;
            //this.showToast('error' , 'ERROR!' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Formula"));
        }
        //VALIDATE THAT SELECTED FORMULA FIELD & OPERATOR & VALUE ARE NOT EMPTY: BY PASS IF VALIDATION IF SELECTED FORMULA FIELD IS TODAY
        else if(component.get("v.selectedFormulaField").pathLabels != 'TODAY'){
            if(component.get("v.selectedFormulaField") == null || formulaOperator == '' || formulaOperator == null || formulaValue == null || formulaValue == ''){
                isValid = false;
                //this.showToast('error' , 'ERROR!' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Formula"));
            }
        }  
        if(isValid){
            var formulaField = component.get("v.selectedFormulaField").pathNames;
            var formulaLabel = component.get("v.selectedFormulaField").pathLabels;
            if(component.get("v.isEditMode")){
                var index = component.get("v.editingIndex");
                this.modifyRowValues(component , index , selectedField , selectedOperator , '' , selectedType , '' , formulaField , formulaLabel , formulaOperator , formulaValue);
            }
            else{
                this.pushRow(component , selectedField , selectedOperator , '' , selectedType , '' , formulaField , formulaLabel , formulaOperator , formulaValue);
            }
            this.reset(component);    
        } 
        else{
            this.showToast('error' , 'ERROR!' , $A.get("$Label.c.SPIRE_Criteria_Editor_Invalid_Formula"));
        }  
    },
    // MODIFY SELECTED RULE CRITERIA VALUES
    modifyRowValues : function(component , index , field , operator , value , type , fieldValueLabel , 
                               formulaField , formulaLabel , formulaOperator , formulaValue ) {
    	var filters = component.get("v.filters");
        filters[index].field = field;
        filters[index].operator = operator;
        filters[index].value = value;
        filters[index].type = type; 
        filters[index].fieldValueLabel = fieldValueLabel;
        filters[index].formulaField = formulaField;
        filters[index].formulaLabel = formulaLabel;
        filters[index].formulaOperator = formulaOperator;
        filters[index].formulaValue = formulaValue;
        component.set("v.filters" , filters);
    },
    //ADD RULE CRITRIA RULE TO LIST OF FILTERS
    pushRow : function(component , field , operator , value , type , fieldValueLabel , 
                       formulaField , formulaLabel , formulaOperator , formulaValue ) {
    	var filters = component.get("v.filters");
		filters.push({field: field , 
                      operator: operator , 
                      type : type , 
                      value: value , 
                      fieldValueLabel : fieldValueLabel ,
                      formulaField : formulaField , 
                      formulaLabel : formulaLabel ,
                      formulaOperator : formulaOperator , 
                      formulaValue : formulaValue});
        component.set("v.filters" , filters);
    },
    //FILL FIELDS FOR VALUE RULE CRITERIA
    fillValueFileds : function(component , index ) {
    	var filters = component.get("v.filters");  
        component.set("v.selectedField" , filters[index].field);
        component.set("v.selectedOperator" , filters[index].operator);
        component.set("v.selectedValue" , filters[index].value);   
        component.set("v.selectedType" , filters[index].type);
    },
    //FILL FIELDS FOR REFERENCE RULE CRITERIA
    fillFieldReferenceFields : function(component , index ) {
        var filters = component.get("v.filters");  
        component.set("v.selectedField" , filters[index].field);
        component.set("v.selectedOperator" , filters[index].operator);
        component.set('v.selectedFieldValue' , {"pathLabels" : filters[index].fieldValueLabel , "pathNames" : filters[index].value});
        component.set("v.selectedType" , filters[index].type);
    },
    //FILL FIELDS FOR REFERENCE RULE CRITERIA
    fillFormulaFields : function(component , index ) {
        var filters = component.get("v.filters");  
        component.set("v.selectedField" , filters[index].field);
        component.set("v.selectedOperator" , filters[index].operator);
		component.set("v.selectedFormulaField" , {"pathLabels" : filters[index].formulaLabel , "pathNames" : filters[index].formulaField});
        component.set("v.selectedFormulaOperator" , filters[index].formulaOperator);
        component.set("v.selectedFormulaValue" , filters[index].formulaValue);  
        component.set("v.selectedType" , filters[index].type);
    },
    //RESET COMPONENT
    reset : function(component) {
    	component.set("v.selectedValue" , '');
        component.set('v.selectedFieldValue' , null); 
        component.set("v.selectedFormulaField" , null);
        component.set("v.selectedFormulaOperator" , '');
        component.set("v.selectedFormulaValue" , null);
        component.set("v.isEditMode" , false);
        component.set("v.selectedType" , 'Value');
        component.set("v.selectedOperator" , "Equals");
    }
    

})