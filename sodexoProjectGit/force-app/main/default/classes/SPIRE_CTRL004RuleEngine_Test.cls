@IsTest
public class SPIRE_CTRL004RuleEngine_Test {
    
    @testSetup 
    public static void setup(){
        //Create Rule Engine
        SPIRE_Rule_Engine__c ruleEngine = new SPIRE_Rule_Engine__c();
        ruleEngine.Name = 'test 01';
        ruleEngine.SPIRE_Object_Name__c = 'Lead';
        ruleEngine.SPIRE_TECH_Source_Object_Label__c = 'Lead';
        ruleEngine.SPIRE_Is_Active__c = true;
        ruleEngine.SPIRE_Take__c = 'Meet Custom Condition Logic';
        ruleEngine.SPIRE_Custom_Logic__c = '1 AND 2';
        ruleEngine.SPIRE_Field_Name__c = 'NumberOfEmployees';
        ruleEngine.SPIRE_TECH_Target_Field_Label__c = 'No. of Employees';
        ruleEngine.SPIRE_Score__c = 99;
        ruleEngine.SPIRE_Action_Object__c = 'Lead';
        insert ruleEngine;
        
        SPIRE_Rule_Criteria__c ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'Name',
                                SPIRE_Tech_Field_Object__c = 'Lead',
                                SPIRE_Operator__c = '=',
                                SPIRE_Order__c = 1,
                                SPIRE_Tech_Field_Label__c = 'Name',
                                SPIRE_Type__c = 'Value',
                                SPIRE_Value__c = 'test',
                                SPIRE_Rule_Engine__c = ruleEngine.Id
            );
        insert ruleCriteriaRecord;
        ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'Name',
                                SPIRE_Tech_Field_Object__c = 'Lead',
                                SPIRE_Operator__c = '=',
                                SPIRE_Order__c = 2,
                                SPIRE_Tech_Field_Label__c = 'Name',
                                SPIRE_Type__c = 'Field Reference',
                                SPIRE_Value__c = 'Title',
                                SPIRE_Tech_Field_Reference_Label__c = 'Title',
                                SPIRE_Rule_Engine__c = ruleEngine.Id
            );
        insert ruleCriteriaRecord;
        ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'LastTransferDate',
                                SPIRE_Tech_Field_Object__c = 'Lead',
                                SPIRE_Operator__c = '=',
                                SPIRE_Order__c = 3,
                                SPIRE_Tech_Field_Label__c = 'Last Transfer Date',
                                SPIRE_Type__c = 'Formula',
                                SPIRE_TECH_Formula_Field_Label__c = 'Last Transfer Date',
                                SPIRE_Formula_Field_Reference__c = 'LastTransferDate',
                                SPIRE_Formula_Operator__c = '+',
                                SPIRE_Formula_Value__c = 6,
                                SPIRE_Rule_Engine__c = ruleEngine.Id
            );
        insert ruleCriteriaRecord;
    }
    
    @IsTest
    public static void saveCriterias_test(){
        SPIRE_Rule_Engine__c ruleEngine = [SELECT Id , SPIRE_Object_Name__c FROM SPIRE_Rule_Engine__c Limit 1];
        List<SPIRE_Rule_Criteria__c> ruleCriterias = [SELECT Id FROM SPIRE_Rule_Criteria__c Where SPIRE_Rule_Engine__c =: ruleEngine.Id order by SPIRE_order__c];
        String criterias = '[{"criteriaId" : "'+ruleCriterias[1].Id+'" , "operator" : "equals" , "type" : "Value" , "value" : "test" , "field" : {"pathNames" : "name" , "pathLabels" : "name"}}]';
        List<String> idsTodelete = new List<String> (); idsTodelete.add(ruleCriterias[0].Id);
        Integer res = SPIRE_CTRL004RuleEngine.saveCriterias(criterias , idsTodelete , ruleEngine.Id);
        ruleCriterias = [SELECT Id , SPIRE_Value__c FROM SPIRE_Rule_Criteria__c Where SPIRE_Rule_Engine__c =: ruleEngine.Id order by SPIRE_order__c];
        system.assertEquals(1 , res);
        system.assertEquals(2 , ruleCriterias.size());
        system.assertEquals('test' , ruleCriterias[0].SPIRE_Value__c);
    }

    @IsTest
    public static void getRuleEngine_test(){
        SPIRE_Rule_Engine__c ruleEngine = [SELECT Id , SPIRE_Object_Name__c FROM SPIRE_Rule_Engine__c Limit 1];
        List<SPIRE_Rule_Engine__c> rules = SPIRE_CTRL004RuleEngine.getRuleEngine(ruleEngine.Id);
        system.assertEquals(rules.size() , 1);
        system.assertEquals(rules[0].SPIRE_Object_Name__c , ruleEngine.SPIRE_Object_Name__c);
    }
    
    @IsTest
    public static void getCriterias_test(){
        SPIRE_Rule_Engine__c ruleEngine = [SELECT Id , SPIRE_Object_Name__c FROM SPIRE_Rule_Engine__c Limit 1];
        List<SPIRE_CTRL004RuleEngine.CriteriaWrapper> criterias = SPIRE_CTRL004RuleEngine.getCriterias(ruleEngine.Id);
        system.assertEquals(criterias.size() , 3);
    }
    
    @IsTest
    public static void isFilterLogicValid_test(){
        Boolean isValid = SPIRE_CTRL004RuleEngine.isFilterLogicValid('(1 AND 2) OR 3' , 3);
        system.assertEquals(true , isValid);
    }
    
}