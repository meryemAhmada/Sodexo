@IsTest

public class SPIRE_RuleEngineController_Test {
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
    }

    @IsTest
    public static void saveCriterias_test1(){
        SPIRE_Rule_Engine__c ruleEngine = [SELECT Id FROM SPIRE_Rule_Engine__c Limit 1];
        PageReference page = Page.SPIRE_RuleEngineVf;
        page.getParameters().put('id', ruleEngine.id);
        Test.setCurrentPage(page);
        Test.StartTest();
        SPIRE_RuleEngineController ctrl = new SPIRE_RuleEngineController();
        ctrl.doInit();
        Test.StopTest();
        system.assertEquals('/lightning/n/SPIRE_Rule_Engine?c__id=' + ruleEngine.id, ctrl.url);
    }
    
    @IsTest
    public static void saveCriterias_test2(){
        Test.StartTest();
        SPIRE_RuleEngineController ctrl = new SPIRE_RuleEngineController();
        ctrl.doInit();
        Test.StopTest();
        system.assertEquals('/lightning/n/SPIRE_Rule_Engine', ctrl.url);
    }
}