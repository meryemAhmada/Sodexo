public class SPIRE_QueryBuilder {
      
    public static Set<String> getOperatorsAndParentheses(){
        Set<String> operatorsAndParentheses = new Set<String>{'=', '(', ')', 'AND', 'OR'};
            return operatorsAndParentheses;
    }
    
    public static SPIRE_Rule_Engine__c getRuleEngineById(String ruleEngineId){
        List<SPIRE_Rule_Engine__c> ruleEngines = [SELECT Name, SPIRE_Object_Name__c, SPIRE_Field_Name__c, SPIRE_Action_Object__c, SPIRE_Score__c FROM SPIRE_Rule_Engine__c WHERE SPIRE_Is_Active__c = true AND Id = :ruleEngineId];
        return ruleEngines[0];
    }
    
    public static RuleEngineWithWhereClause formatRuleEngineWithWhereClause(String ruleEngineId, String whereClause){
        SPIRE_Rule_Engine__c ruleEngine = new SPIRE_Rule_Engine__c();
        ruleEngine = getRuleEngineById(ruleEngineId);
        RuleEngineWithWhereClause ruleEngineWithWhereClause = new RuleEngineWithWhereClause(ruleEngine, whereClause);
        return RuleEngineWithWhereClause;
    }
    
    public static String addDelimiters(String str){
        str = 'FieldToRetrieve' + str + 'FieldToRetrieve';
        return str;
    }
    
    public static String addFormulaDelimiters(String str){

        str = 'FieldFormulaToRetrieve' + str + 'FieldFormulaToRetrieve';
        return str;
    }
    
    public static String addSpacesIfParentheses(String str){
        str = str.replaceAll('[(]', '( ');
        str = str.replaceAll('[)]', ' )');
        return str;
    }
    
    public static String removeSpacesIfParentheses(String str){
        str = str.replace('( ', '(');
        str = str.replace(' )', ')');
        return str;
    }
    
    public static Object getFieldValueFromObject(SObject record, String field)
    {
        if (record == null) return null;
        if (!field.contains('.')) return record.get(field);
        return getFieldValueFromObject(
            record.getSObject(field.substringBefore('.')),
            field.substringAfter('.')
        );
    }
    
    public static String compare(String clause, sObject objectSource){
        List<String> objectAndField = new List<String>();        
        List<String> clauseSplit = new List<String>();
        system.debug('clause '+clause);
        clauseSplit = clause.split(' ');
        //System.debug('clauseSplit[0] '+clauseSplit[0]);
        //System.debug('clauseSplit[1] '+clauseSplit[1]);
        //System.debug('clauseSplit[2] '+clauseSplit[2]);
        if(clauseSplit.size() > 2){
            clauseSplit[2] = clauseSplit[2].replace('######',' ');
            if(clauseSplit[0].contains('FieldToRetrieve')){
                clauseSplit[0] = clauseSplit[0].substringBetween('FieldToRetrieve');
                if(clauseSplit[0] != null)objectAndField = clauseSplit[0].split('\\.');
                if(objectAndField.size() > 1){
                    clauseSplit[0] = String.valueOf(getFieldValueFromObject(objectSource,clauseSplit[0]));
                } else{
                    clauseSplit[0] = String.valueOf(objectSource.get(clauseSplit[0]));
                }
                System.debug('clauseSplit[0] '+clauseSplit[0]);
            }
            system.debug('clauseSplit[2] '+clauseSplit[2]);
            if(clauseSplit[2] != null && clauseSplit[2].contains('FieldToRetrieve')){
                System.debug('clauseSplit[2] '+clauseSplit[2]);
                clauseSplit[2] = clauseSplit[2].substringBetween('FieldToRetrieve');
                if(clauseSplit[2] != null)objectAndField = clauseSplit[2].split('\\.');
                if(objectAndField.size() > 1){
                    clauseSplit[2] = String.valueOf(getFieldValueFromObject(objectSource,clauseSplit[2]));
                } else{
                    clauseSplit[2] = String.valueOf(objectSource.get(clauseSplit[2]));
                }
            }  
            if(clauseSplit[2] != null && clauseSplit[2].contains('FieldFormulaToRetrieve')){
                List<String> formulaclauseSplit = new List<String>();
                List<String> formulaObjectAndField = new List<String>();
                formulaclauseSplit = clauseSplit[2].split(',');
                String formulaclauseFieldValue = formulaclauseSplit[0].substringBetween('FieldFormulaToRetrieve');
                formulaObjectAndField = formulaclauseFieldValue.split('\\.');
                if(formulaObjectAndField.size() > 1){
                    formulaclauseFieldValue = String.valueOf(getFieldValueFromObject(objectSource,formulaclauseFieldValue));
                } else{
                    if(formulaObjectAndField[0] != 'TODAY')formulaclauseFieldValue = String.valueOf(objectSource.get(formulaObjectAndField[0]));
                    else formulaclauseFieldValue = String.valueOf(Date.today());
                }
                Decimal result = 0;
                switch on formulaclauseSplit[1] {
                    when '+' {
                        if(formulaclauseFieldValue != null && formulaclauseFieldValue != ''){
                            try {
                                Date resultDate;
                                Date d = Date.valueOf(formulaclauseFieldValue);
                                resultDate = d.addDays(integer.valueOf(formulaclauseSplit[2].substringBetween('FieldFormulaToRetrieve'))); 
                                clauseSplit[2] = String.valueOf(resultDate);
                            }
                            catch(TypeException e) {
                                result = decimal.valueOf(formulaclauseFieldValue) + decimal.valueOf(formulaclauseSplit[2].substringBetween('FieldFormulaToRetrieve'));  
                                clauseSplit[2] = String.valueOf(result);
                            }
                        }
                    }
                    when '-' {
                        if(formulaclauseFieldValue != null && formulaclauseFieldValue != ''){
                            try {
                                Date resultDate;
                                Date d = Date.valueOf(formulaclauseFieldValue);
                                resultDate = d.addDays(-integer.valueOf(formulaclauseSplit[2].substringBetween('FieldFormulaToRetrieve')));
                                clauseSplit[2] = String.valueOf(resultDate);
                            }
                            catch(TypeException e) {
                                result = decimal.valueOf(formulaclauseFieldValue) - decimal.valueOf(formulaclauseSplit[2].substringBetween('FieldFormulaToRetrieve'));  
                                clauseSplit[2] = String.valueOf(result);
                            }
                        }
                    }
                    when '*' {
                        if(formulaclauseFieldValue != null && formulaclauseFieldValue != ''){
                            try {
                                Date resultDate;
                                Date d = Date.valueOf(formulaclauseFieldValue);
                                return 'FALSE';
                            }
                            catch(TypeException e) {
                                result = decimal.valueOf(formulaclauseFieldValue) * decimal.valueOf(formulaclauseSplit[2].substringBetween('FieldFormulaToRetrieve'));
                                clauseSplit[2] = String.valueOf(result);
                            }
                        }
                    }
                    when '/' {
                        if(formulaclauseFieldValue != null && formulaclauseFieldValue != ''){
                            try {
                                Date resultDate;
                                Date d = Date.valueOf(formulaclauseFieldValue);
                                return 'FALSE';
                            }
                            catch(TypeException e) {
                                result = decimal.valueOf(formulaclauseFieldValue) / decimal.valueOf(formulaclauseSplit[2].substringBetween('FieldFormulaToRetrieve'));
                                clauseSplit[2] = String.valueOf(result);
                            }
                        }
                    }
                }
            }            
            if(clauseSplit[1] != null && clauseSplit[1] != '' && clauseSplit[2] != null && clauseSplit[2] != ''){
                
                System.debug('clauseSplit[0] '+clauseSplit[0]);
                System.debug('clauseSplit[1] '+clauseSplit[1]);
                System.debug('clauseSplit[2] '+clauseSplit[2]);
                switch on clauseSplit[1] {
                    when '=' {
                        if(isDecimalValue(clauseSplit[0]) && isDecimalValue(clauseSplit[2])){
                            if(decimal.valueOf(clauseSplit[0]) == decimal.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else if(isDateValue(clauseSplit[0]) && isDateValue(clauseSplit[2])){
                            if(date.valueOf(clauseSplit[0]) == date.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else{
                            if(clauseSplit[0] == clauseSplit[2]){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }
                        
                    }
                    when '!=' {
                        if(isDecimalValue(clauseSplit[0]) && isDecimalValue(clauseSplit[2])){
                            if(decimal.valueOf(clauseSplit[0]) != decimal.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else if(isDateValue(clauseSplit[0]) && isDateValue(clauseSplit[2])){
                            if(date.valueOf(clauseSplit[0]) != date.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else{
                            if(clauseSplit[0] != clauseSplit[2]){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }
                    }
                    when '<' {
                        if(isDecimalValue(clauseSplit[0]) && isDecimalValue(clauseSplit[2])){
                            if(decimal.valueOf(clauseSplit[0]) < decimal.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else if(isDateValue(clauseSplit[0]) && isDateValue(clauseSplit[2])){
                            if(date.valueOf(clauseSplit[0]) < date.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else{
                            if(clauseSplit[0] < clauseSplit[2]){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }
                    }
                    when '>' {
                        if(isDecimalValue(clauseSplit[0]) && isDecimalValue(clauseSplit[2])){
                            if(decimal.valueOf(clauseSplit[0]) > decimal.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else if(isDateValue(clauseSplit[0]) && isDateValue(clauseSplit[2])){
                            if(date.valueOf(clauseSplit[0]) > date.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else{
                            if(clauseSplit[0] > clauseSplit[2]){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }
                    }
                    when '<=' {
                        if(isDecimalValue(clauseSplit[0]) && isDecimalValue(clauseSplit[2])){
                            if(decimal.valueOf(clauseSplit[0]) <= decimal.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else if(isDateValue(clauseSplit[0]) && isDateValue(clauseSplit[2])){
                            if(date.valueOf(clauseSplit[0]) <= date.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else{
                            if(clauseSplit[0] <= clauseSplit[2]){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }
                    }
                    when '>=' {
                        if(isDecimalValue(clauseSplit[0]) && isDecimalValue(clauseSplit[2])){
                            if(decimal.valueOf(clauseSplit[0]) >= decimal.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else if(isDateValue(clauseSplit[0]) && isDateValue(clauseSplit[2])){
                            if(date.valueOf(clauseSplit[0]) >= date.valueOf(clauseSplit[2])){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }else{
                            if(clauseSplit[0] >= clauseSplit[2]){
                                return 'TRUE';
                            } else{
                                return 'FALSE';
                            }
                        }
                    }
                    when 'Contains' {
                        if(clauseSplit[0].contains(clauseSplit[2])){
                            return 'TRUE';
                        } else{
                            return 'FALSE';
                        }
                    }
                    when 'Does_not_contain' {
                        if(!clauseSplit[0].contains(clauseSplit[2])){
                            return 'TRUE';
                        } else{
                            return 'FALSE';
                        }
                    }
                    when 'Starts_with' {
                        if(clauseSplit[0].startsWith(clauseSplit[2])){
                            return 'TRUE';
                        } else{
                            return 'FALSE';
                        }
                    }
                    when 'Is_null' {
                        if(clauseSplit[0] == null && clauseSplit[2] == 'FALSE'){
                            return 'FALSE';
                        }
                        else if(clauseSplit[0] == null && clauseSplit[2] == 'TRUE'){
                            return 'TRUE';
                        }
                        else if(clauseSplit[0] != null && clauseSplit[2] == 'FALSE'){
                            return 'TRUE';
                        }else{
                            return 'FALSE';
                        }
                    }
                }                
            }
            if(clauseSplit[0] == null && clauseSplit[2] == null){
                if(clauseSplit[1] == '='){
                    return 'TRUE';
                }
            } 
        }
        return 'FALSE';
    }
    
    public static String formatSelectQuery(String str){
        system.debug('str before: '+str);
        str = '(\'' + str + '\')';
        str = str.replace(' ', '');
        str = str.replace(',', '\', \'');
        str = str.replace('{', '');
        str = str.replace('}', '');
        system.debug('str after: '+str);
        return str;
    }
    
    //Wrapper Class    
    public class RuleEngineWithWhereClause {
        public SPIRE_Rule_Engine__c ruleEngine;
        public String whereClause;
        
        public RuleEngineWithWhereClause(SPIRE_Rule_Engine__c ruleEngine, String whereClause){
            this.ruleEngine = ruleEngine;
            this.whereClause = whereClause;
        }
    }


    public static Boolean isDecimalValue(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    public static Boolean isDateValue(String s){
        Boolean ReturnValue;
        try{
            Date.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    
}