public with sharing class SPIRE_CTRL004RuleEngine {
    
    public static Map<String,String> operators = new Map<String,String>{
        'Equals' => '=', 
        'Not equal to' => '!=',
        'Less than' => '<', 
        'Greater than' => '>',
        'Less or equal' => '<=',
        'Greater or equal' => '>=',
        'Contains' => 'contains', 
        'Does not contain' => 'does_not_contain',
        'Starts with' => 'starts_with',
        'Is null' => 'Is_null'
    };
 
    public static List<String> exceptionTypes = new List<String>{
        'DATETIME' ,
        'CURRENCY',
        'DATE',
        'PICKLIST',
        'MULTIPICKLIST',
        'TIME',
        'INTEGER',
        'BOOLEAN',
        'PERCENT',
        'REFERENCE' 
    };

    public static List<String> numericTypes = new List<String>{
        'DATETIME' ,
        'CURRENCY',
        'DATE',
        'TIME',
        'INTEGER',
        'PERCENT',
        'DOUBLE'
    };

    public static String defaultType = 'STRING';

    public static List<PicklistOption> basicOperators = new List<PicklistOption>{
        new PicklistOption('Equals' , 'Equals'),
        new PicklistOption('Not equal to' , 'Not equal to'),
        new PicklistOption('Is null' , 'Is null')
    };

    public static List<PicklistOption> numericOptions = new List<PicklistOption>{
        new PicklistOption('Less than' , 'Less than'),
        new PicklistOption('Greater than' , 'Greater than'),
        new PicklistOption('Less or equal' , 'Less or equal'),
        new PicklistOption('Greater or equal' , 'Greater or equal')
    };

    public static List<PicklistOption> stringOptions = new List<PicklistOption>{
        new PicklistOption('Contains' , 'Contains'),
        new PicklistOption('Does not contain' , 'Does not contain'),
        new PicklistOption('Starts with' , 'Starts with')
    };

    // UPSERT RULE CRITERIAS AND RETURN NUMBER OF UPSERTED RECORDS
    @AuraEnabled
    public static Integer saveCriterias(String criterias , List<String> idsTodelete , String ruleEngineId){
            Database.DeleteResult[] deleteResults = Database.delete(idsTodelete, true);
        	//DESEIALIZE LIST OF CRTIERIAS
            List<Object> ruleCriterias = (List<Object>) JSON.deserializeUntyped(criterias);
            Map<String, Object> ruleCriteriaMap;
            Map<String, Object> fieldMap;
            Map<String, Object> finalFieldMap;
            SPIRE_Rule_Criteria__c ruleCriteriaRecord; 
            List<SPIRE_Rule_Criteria__c> ruleCriteriaToInsert = new List<SPIRE_Rule_Criteria__c>();
            Integer index = 1;
            for(Object ruleCriteria : ruleCriterias){
                //GET NESTED OBJECTS EACH ruleCriteria AS MAP 
                ruleCriteriaMap = (Map<String, Object>) ruleCriteria;
                fieldMap = (Map<String, Object>) ruleCriteriaMap.get('field');
                finalFieldMap = (Map<String, Object>) fieldMap.get('field');
                Decimal formulaValue = null;
                if(ruleCriteriaMap.get('formulaValue')!= null && ruleCriteriaMap.get('formulaValue')!= ''){
                    //CONVERT FORMULA VALUE FROM STRING TO DECIMAL
                    formulaValue = Decimal.valueOf(ruleCriteriaMap.get('formulaValue')+'');
                }
                ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                    Id = (string) ruleCriteriaMap.get('criteriaId'),
                                    SPIRE_Field_Name__c = (string) fieldMap.get('pathNames'),
                                    SPIRE_Tech_Field_Object__c = (string) fieldMap.get('refObjName'),
                                    SPIRE_Operator__c = operators.get((string) ruleCriteriaMap.get('operator')),
                                    SPIRE_Order__c = index,
                                    SPIRE_Tech_Field_Label__c = (string) fieldMap.get('pathLabels'),
                                    SPIRE_Type__c = (string) ruleCriteriaMap.get('type'),
                                    SPIRE_Value__c = (string) ruleCriteriaMap.get('value'),
                                    SPIRE_Tech_Field_Reference_Label__c = (string) ruleCriteriaMap.get('fieldValueLabel'),
                                    SPIRE_TECH_Formula_Field_Label__c = (string) ruleCriteriaMap.get('formulaLabel'),
                                    SPIRE_Formula_Field_Reference__c = (string) ruleCriteriaMap.get('formulaField'),
                                    SPIRE_Formula_Operator__c = (string) ruleCriteriaMap.get('formulaOperator'),
                                    SPIRE_Formula_Value__c = formulaValue,
                                    SPIRE_Rule_Engine__c = ruleEngineId
                );
    
                ruleCriteriaToInsert.add(ruleCriteriaRecord);
                index++;
            }
            upsert ruleCriteriaToInsert;
            return ruleCriteriaToInsert.size();
    }

    //GET RULE ENGINE BY ID
    @AuraEnabled
    public static List<SPIRE_Rule_Engine__c> getRuleEngine(String ruleEngineId){
        return [SELECT Id , Name, SPIRE_Action_Object__c , SPIRE_Is_Active__c , SPIRE_Object_Name__c , SPIRE_Take__c , SPIRE_Field_Name__c , SPIRE_TECH_Target_Field_Label__c , SPIRE_TECH_Source_Object_Label__c FROM SPIRE_Rule_Engine__c WHERE Id =: String.escapeSingleQuotes(ruleEngineId)];
    }

    //GET RULE CRITERIAS BY RULE ENGINE ID
    @AuraEnabled
    public static List<CriteriaWrapper> getCriterias(String ruleEngineId){
        List<CriteriaWrapper> criterias = new List<CriteriaWrapper>();
        for(SPIRE_Rule_Criteria__c criteria : [SELECT Id , SPIRE_Field_Name__c , tolabel(SPIRE_Operator__c) , 
                                        SPIRE_Order__c , SPIRE_Tech_Field_Label__c , SPIRE_Tech_Field_Object__c, 
                                        SPIRE_Type__c , SPIRE_Value__c , SPIRE_Tech_Field_Reference_Label__c , SPIRE_TECH_Formula_Field_Label__c,
                                        SPIRE_Formula_Field_Reference__c , SPIRE_Formula_Operator__c , SPIRE_Formula_Value__c
                                        FROM SPIRE_Rule_Criteria__c WHERE 
                                        SPIRE_Rule_Engine__c =: String.escapeSingleQuotes(ruleEngineId) ORDER By SPIRE_Order__c]){
            criterias.add(getCriteriaWrapper(criteria));
        }
        return criterias;
    }
    
    //RETURN TRUE IF FILTER LOGIC IS VALID
    @AuraEnabled
    public static Boolean isFilterLogicValid(String filterLogic , Integer filterListSize){
            List<String> trueFilters = new List<String>();
            for(Integer i = 1; i < filterListSize+1 ; i++ ){
                //REPLACE ALL RULE CRITERIAS NUMBER BY TRUE 
                if(filterLogic.countMatches(i+'')>0){
                    filterLogic = filterLogic.replace(i+'', 'TRUE');
                }
                else{
                    return false;
                }
            }
            //ALL CONDITIONS ARE TRUE -> EVALUATION OF CUSTOM LOGIC IS TRUE OTHERWISE FILTER LOGIC IS INVALID
           return SPIRE_BooleanExpression.eval(filterLogic);
    }

    //GET RULE CRITERIA WRAPPER SO THAT IT CAN BE USED PROPERLY IN COMPONENT
    private static CriteriaWrapper getCriteriaWrapper(SPIRE_Rule_Criteria__c criteria){
        return new CriteriaWrapper(criteria.Id , criteria.SPIRE_Order__c , criteria.SPIRE_Operator__c , criteria.SPIRE_Value__c , criteria.SPIRE_Type__c , 
                                   criteria.SPIRE_Tech_Field_Reference_Label__c , criteria.SPIRE_TECH_Formula_Field_Label__c,
                                   criteria.SPIRE_Formula_Field_Reference__c , criteria.SPIRE_Formula_Operator__c , criteria.SPIRE_Formula_Value__c ,
                                   getFieldValueWrapper(criteria));
    }

    //GET RULE FIELD VALUE WRAPPER SO THAT IT CAN BE USED PROPERLY IN COMPONENT
    private static FieldValueWrapper getFieldValueWrapper(SPIRE_Rule_Criteria__c criteria){
        return new FieldValueWrapper(criteria.SPIRE_Tech_Field_Label__c , criteria.SPIRE_Field_Name__c , criteria.SPIRE_Tech_Field_Object__c , getFieldWrapper(criteria.SPIRE_Tech_Field_Object__c , criteria.SPIRE_Field_Name__c));
    }

    // RULE CRITERIA FIELD SO THAT IT CAN BE USED PROPERLY IN COMPONENT
    private static FieldWrapper getFieldWrapper(String objectName , String pathNames){
        List<String> names = pathNames.split('\\.');
        if(names.size() > 0){
            String fieldName = names[names.size()-1];
            Schema.SObjectField field = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
            String fieldtype = getType(field.getDescribe().getType());
            List<PicklistOption> options = getOptions(field);
            List<PicklistOption> operators = getOperators(fieldtype);
            system.debug(new FieldWrapper(fieldtype , options , operators));
            return new FieldWrapper(fieldtype , options , operators);
        }
        return null;
    }

    //GET TYPE THAT IT CAN BE USED PROPERLY IN COMPONENT
    public static String getType(Schema.DisplayType fieldType){
        String typefieldS = fieldType + '';
        if(exceptionTypes.contains(typefieldS)){
            return typefieldS;
        }
        return defaultType;
    }

    //GET OPTIONS OF PICKLST FIELDS 
    private static List<PicklistOption> getOptions(Schema.sObjectField field){
        List<PicklistOption> options = new List<PicklistOption>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new PicklistOption(pickListVal.getLabel() , pickListVal.getValue()));
        }     
        return options;
    }

    //RETURNS OPERATORS BY FIELDTYPE
    private static List<PicklistOption> getOperators(String fieldtype){
        List<PicklistOption> options = new List<PicklistOption>();
        options.addAll(basicOperators);
        if(numericTypes.contains(fieldtype)){
            options.addAll(numericOptions);
        }
        else if(fieldtype != 'BOOLEAN'){
            options.addAll(numericOptions);
            options.addAll(stringOptions);
        }
        return options;
    }

    public class CriteriaWrapper {
        @AuraEnabled
        public String criteriaId;
        @AuraEnabled
        public Decimal order;
        @AuraEnabled
        public String operator;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String fieldValueLabel;
        @AuraEnabled
        public String  formulaLabel;
        @AuraEnabled
        public String formulaField;
        @AuraEnabled
        public String formulaOperator;
        @AuraEnabled
        public Decimal formulaValue;
        @AuraEnabled
        public FieldValueWrapper field;
 
        public CriteriaWrapper(String criteriaId , Decimal order , String operator , String value , String type , String fieldValueLabel ,
                               String  formulaLabel , String formulaField , String formulaOperator , Decimal formulaValue , FieldValueWrapper field){
            this.criteriaId = criteriaId;
            this.order = order;
            this.operator = operator;
            this.value = value;
            this.type = type;
            this.fieldValueLabel = fieldValueLabel;
            this.formulaLabel = formulaLabel;
            this.formulaField = formulaField;
            this.formulaOperator = formulaOperator;
            this.formulaValue = formulaValue;          
            this.field = field;
        }
    }

    public class FieldValueWrapper {
        @AuraEnabled
        public String pathLabels;
        @AuraEnabled
        public String pathNames;
        @AuraEnabled
        public String refObjName;
        @AuraEnabled
        public FieldWrapper field;
 
        public FieldValueWrapper(String pathLabels , String pathNames , String refObjName , FieldWrapper field){
            this.pathLabels = pathLabels;
            this.pathNames = pathNames;
            this.refObjName = refObjName;
            this.field = field;
        }
    }

    public class FieldWrapper {
        @AuraEnabled
        public String fieldtype;
        @AuraEnabled
        public List<PicklistOption> options;
        @AuraEnabled
        public List<PicklistOption> operators;
 
        public FieldWrapper(String fieldtype , List<PicklistOption> options , List<PicklistOption> operators){
            this.fieldtype = fieldtype;
            this.options = options;
            this.operators = operators;
        }
    }

    public class PicklistOption {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        public PicklistOption(String label , String value){
            this.label = label;
            this.value = value;
        }
    }
}