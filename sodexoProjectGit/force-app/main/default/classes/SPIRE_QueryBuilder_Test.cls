@IsTest
public class SPIRE_QueryBuilder_Test {
     
    @testSetup 
    static void setup() {
        Set<String> operatorsAndParentheses = SPIRE_QueryBuilder.getOperatorsAndParentheses();
        List<SPIRE_Rule_Engine__c> testRule_Engines = new List<SPIRE_Rule_Engine__c>();        
        testRule_Engines.add(new SPIRE_Rule_Engine__c(Name = 'TestRule_Engine', SPIRE_Is_Active__c = true, SPIRE_Score__c = 10, SPIRE_Object_Name__c = 'Account', SPIRE_Field_Name__c = 'NumberOfEmployees', SPIRE_Action_Object__c = 'Account', SPIRE_TECH_Target_Field_Label__c = 'Rule Engine Score', SPIRE_TECH_Source_Object_Label__c = 'Account'));
        testRule_Engines.add(new SPIRE_Rule_Engine__c(Name = 'TestRule_Engine', SPIRE_Is_Active__c = true, SPIRE_Score__c = 10, SPIRE_Object_Name__c = 'Account', SPIRE_Field_Name__c = 'CreatedDate',SPIRE_Action_Object__c = 'Account', SPIRE_TECH_Target_Field_Label__c = 'Rule Engine Score', SPIRE_TECH_Source_Object_Label__c = 'Account'));
        insert testRule_Engines;    
        Account acc0 = new Account(name='Test Account parent', Type='Partner', NumberOfEmployees = 10);
        insert acc0;
        Account acc = new Account(name='Test Account', Type='Partner', NumberOfEmployees = 10, parentId = acc0.Id);
        insert acc;
        
    }

    @IsTest
    public static void getRuleEngineById_test(){
        List<SPIRE_Rule_Engine__c> ruleEngines = [SELECT Id FROM SPIRE_Rule_Engine__c WHERE SPIRE_Is_Active__c = true];
        system.assertNotEquals(null, SPIRE_QueryBuilder.getRuleEngineById(ruleEngines[0].Id));
    }
    
    @IsTest
    public static void formatRuleEngineWithWhereClause_test(){
        List<SPIRE_Rule_Engine__c> ruleEngines = [SELECT Id FROM SPIRE_Rule_Engine__c WHERE SPIRE_Is_Active__c = true];
        system.assertNotEquals(null, SPIRE_QueryBuilder.formatRuleEngineWithWhereClause(ruleEngines[0].Id, 'Type = Partner'));
    }
    
    @IsTest
    public static void String_test(){
        system.assertNotEquals(null, SPIRE_QueryBuilder.addDelimiters('test'));
        system.assertNotEquals(null, SPIRE_QueryBuilder.addFormulaDelimiters('test'));
        system.assertNotEquals(null, SPIRE_QueryBuilder.addSpacesIfParentheses('(test)'));
        system.assertNotEquals(null, SPIRE_QueryBuilder.removeSpacesIfParentheses('( test )'));
        system.assertNotEquals(null, SPIRE_QueryBuilder.formatSelectQuery('{} test, test }'));
    }
    
    @IsTest
    public static void compare_test(){
        List<Account> acc = [SELECT Name, Type, NumberOfEmployees,createdDate,parentId,parent.name,parent.NumberOfEmployees FROM Account where name='Test Account'];
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveParent.NameFieldToRetrieve = Test Account parent', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveParent.NameFieldToRetrieve = FieldToRetrieveParent.NameFieldToRetrieve', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveparent.NumberOfEmployeesFieldToRetrieve = FieldFormulaToRetrieveparent.NumberOfEmployeesFieldFormulaToRetrieve,+,FieldFormulaToRetrieve10FieldFormulaToRetrieve', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve = Partner', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve != Partner', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve != TypeTest', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve Contains Partner', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve Does_not_contain Partner', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve Starts_with Partner', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve < 10', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve < 20', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve > 10', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve > 5', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve <= 10', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve <= 5', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve >= 10', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve >= 5', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveTypeFieldToRetrieve = FieldToRetrieveTypeFieldToRetrieve', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve = FieldFormulaToRetrieveNumberOfEmployeesFieldFormulaToRetrieve,+,FieldFormulaToRetrieve10FieldFormulaToRetrieve', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve = FieldFormulaToRetrieveNumberOfEmployeesFieldFormulaToRetrieve,-,FieldFormulaToRetrieve10FieldFormulaToRetrieve', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve = FieldFormulaToRetrieveNumberOfEmployeesFieldFormulaToRetrieve,*,FieldFormulaToRetrieve10FieldFormulaToRetrieve', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveNumberOfEmployeesFieldToRetrieve = FieldFormulaToRetrieveNumberOfEmployeesFieldFormulaToRetrieve,/,FieldFormulaToRetrieve10FieldFormulaToRetrieve', acc[0]));

        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve < 2021-01-30', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve < 2021-01-12', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve > 2021-01-12', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve > 2021-01-30', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve <= 2021-01-30', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve <= 2021-01-12', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve >= 2021-01-12', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve >= 2021-01-30', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve != 2021-01-12', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve == 2021-01-12', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve Is_null FALSE', acc[0]));
        system.assertNotEquals(null, SPIRE_QueryBuilder.compare('FieldToRetrieveCreatedDateFieldToRetrieve Is_null True', acc[0]));
    }
}