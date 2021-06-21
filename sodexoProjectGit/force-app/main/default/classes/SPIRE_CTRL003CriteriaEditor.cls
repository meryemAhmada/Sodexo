public with sharing class SPIRE_CTRL003CriteriaEditor {
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
        'REFERENCE',
        'DOUBLE'
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
        new PicklistOption('equals' , 'equals'),
        new PicklistOption('not equal to' , 'not equal to'),
        new PicklistOption('Is null' , 'Is null')   
    };

    public static List<PicklistOption> numericOptions = new List<PicklistOption>{
        new PicklistOption('less than' , 'less than'),
        new PicklistOption('greater than' , 'greater than'),
        new PicklistOption('less or equal' , 'less or equal'),
        new PicklistOption('greater or equal' , 'greater or equal')
    };

    public static List<PicklistOption> stringOptions = new List<PicklistOption>{
        new PicklistOption('contains' , 'contains'),
        new PicklistOption('does not contain' , 'does not contain'),
        new PicklistOption('starts with' , 'starts with')
    };

    //GET ALL FIELDS OF SELECTED OBJECT TYPE
    @AuraEnabled(cacheable=false)
    public static Map<String,FieldWrapper> getFields(String selectedObject , Boolean isParent , String parentName , String parentLabel){
        Map<String,FieldWrapper> fields = new Map<String,FieldWrapper>();
        Map <String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribe.get(selectedObject);
        Schema.DescribeSObjectResult result = sobjType.getDescribe();
        Map<String, Schema.SObjectField> mapOfField = result.fields.getMap();
        FieldWrapper fieldWrapper;
        for(String fieldName : mapOfField.keySet()) {
            Schema.SObjectField field = mapOfField.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            if(isParent && fieldDescribe.isFilterable() && fieldDescribe.isAccessible()){
                if(fieldDescribe.getType() != schema.displaytype.address){
                    fieldWrapper = setWrapper(fieldDescribe , selectedObject , isParent , parentName , parentLabel);
                    fields.put(fieldWrapper.name , fieldWrapper);
                }
            }
            else if(fieldDescribe.isFilterable() && fieldDescribe.isAccessible()){
                if(fieldDescribe.getType() == schema.displaytype.REFERENCE  && fieldDescribe.getRelationshipName()!='MasterRecord'){
                    fields.putAll(getFields(fieldDescribe.getReferenceTo()[0]+'' , true , fieldDescribe.getRelationshipName() , fieldDescribe.getLabel().split(' ID')[0] ));     
                }
                else if(fieldDescribe.getType() != schema.displaytype.address){
                    fieldWrapper = setWrapper(fieldDescribe , selectedObject , isParent , parentName , parentLabel);
                    fields.put(fieldWrapper.name , fieldWrapper);
                }
            }
        }
        return fields;
    } 

    //RETURNS DEFAUT TYPE FOR NON EXCEPTION FIELD TYPES
    public static String getType(Schema.DisplayType fieldType){
        String typefieldS = fieldType + '';
        if(exceptionTypes.contains(typefieldS)){
            return typefieldS;
        }
        return defaultType;
    }
	
    //RETURNS OPTIONS OF PICKLIST FIELD
    public static List<PicklistOption> getOptions(Schema.sObjectField field){
        List<PicklistOption> options = new List<PicklistOption>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            options.add(new PicklistOption(pickListVal.getLabel() , pickListVal.getValue()));
        }     
        return options;
    }

    //RETURS LIST OF OPERATORS FOR A FIELD TYPE
    public static List<PicklistOption> getOperators(String fieldtype){
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

    // GET RELATIONSHIP NAME EG: customfield__r
    public static String getRelationship(String selectedObject , String selectedField){
        // Get the describe for the object
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(selectedObject).getDescribe();
        // Get the field dynamically
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        return fieldResult.getRelationshipName();
    }

    //SET FIELD WRAPPER WITH FIELD ATTRIBUTES
    public static FieldWrapper setWrapper(Schema.DescribeFieldResult member , String objName , Boolean isParent , String parentName , String parentLabel){
        String label;
        String name;
        if(isParent){
            label =  parentLabel + ': ' + member.getLabel();
            name = parentName + '.' + member.getName();
        }
        else{
            label = member.getLabel();
            name = member.getName();
        }
        String fieldtype = getType(member.getType());
        List<PicklistOption> options = new List<PicklistOption>();
        if(fieldtype == 'PICKLIST' || fieldtype == 'MULTIPICKLIST'){
            options = getOptions(member.getSObjectField());
        }
        return new FieldWrapper(label , name , fieldtype , options);
    }

    public class FieldWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldtype;
        @AuraEnabled
        public List<PicklistOption> options;
        @AuraEnabled
        public List<PicklistOption> operators;
        
        public fieldWrapper(String label , String name , String fieldtype , List<PicklistOption> options){
            this.name = name;
            this.label = label;
            this.fieldtype = fieldtype;
            this.options = options;
            this.operators = getOperators(fieldtype);
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