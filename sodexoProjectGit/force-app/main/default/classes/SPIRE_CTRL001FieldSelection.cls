public with sharing class SPIRE_CTRL001FieldSelection {
    
    //
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
        'DOUBLE',
        'LONG'
    };

    public static List<String> numericTypes = new List<String>{
        'DATETIME' ,
        'CURRENCY',
        'DATE',
        'TIME',
        'INTEGER',
        'PERCENT',
        'DOUBLE',
        'LONG'
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
    
   	//GET ALL FIELDS OF SELECTED OBJECT TYPE
    @AuraEnabled(cacheable=false)
    public static Map<String,FieldWrapper> getFields(String selectedObject){
        system.debug(selectedObject);
        Map<String,FieldWrapper> fields = new Map<String,FieldWrapper>();
        Map <String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribe.get(selectedObject);
        Schema.DescribeSObjectResult result = sobjType.getDescribe();
        Map<String, Schema.SObjectField> mapOfField = result.fields.getMap();
        FieldWrapper fieldWrapper;
        for(String fieldName : mapOfField.keySet()) {
            Schema.SObjectField field = mapOfField.get(fieldName);
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            //if(fieldDescribe.isFilterable() && fieldDescribe.isAccessible()){
                if(fieldDescribe.getType() == schema.displaytype.REFERENCE){
                    fieldWrapper = setWrapper(fieldDescribe , selectedObject , true);
                    if(fieldWrapper != null){
                        fields.put(fieldWrapper.name , fieldWrapper);
                    }
                }
            	//We cannot query adress field 
                if(fieldDescribe.getType() != schema.displaytype.address){
                    fieldWrapper = setWrapper(fieldDescribe , selectedObject , false);
                    fields.put(fieldWrapper.name , fieldWrapper);
                } 
            //}
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

    //SET FIELD WRAPPER WITH FIELD ATTRIBUTES
    public static FieldWrapper setWrapper(Schema.DescribeFieldResult member , String objName , Boolean isParent){
        String label;
        String name;
        String fieldtype;
        String referencetoObj;

        //REFERENCE FIELD
        if(isParent){
            label = member.getLabel();
            name = member.getRelationshipName();
            system.debug(label+' : '+name);
            fieldtype = 'LOOKUP';
            referencetoObj = member.getReferenceTo()[0]+'';
            if( member.getReferenceTo().size()>1){
                referencetoObj = 'Name';
            }
            if(name == null) 
            {
                system.debug(label+' s name is null' + referencetoObj);
                return null;
            }
        }
        //NON REFERENCE FIELD
        else{
            label = member.getLabel();
            name = member.getName();
            fieldtype = getType(member.getType());
        }
        //SET OPTIONS FOR PICKLIST AND MULTIPICKLIT FIELDS
        List<PicklistOption> options = new List<PicklistOption>();
        if(fieldtype == 'PICKLIST' || fieldtype == 'MULTIPICKLIST'){
            options = getOptions(member.getSObjectField());
        }
        return new FieldWrapper(label , name , fieldtype , options , referencetoObj);
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
        @AuraEnabled
        public String referencetoObj;
        
        public fieldWrapper(String label , String name , String fieldtype , List<PicklistOption> options , String referencetoObj){
            this.name = name;
            this.label = label;
            this.fieldtype = fieldtype;
            this.options = options;
            this.operators = getOperators(fieldtype);
            this.referencetoObj = referencetoObj;
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