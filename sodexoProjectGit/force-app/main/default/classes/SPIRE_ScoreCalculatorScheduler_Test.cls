@IsTest
public class SPIRE_ScoreCalculatorScheduler_Test {
     
    @testSetup 
    public static void setup(){
        //Create Rule Engines
		SPIRE_Rule_Engine__c ruleEngine3 = new SPIRE_Rule_Engine__c();
        ruleEngine3.Name = 'TestRuleEngine33';
        ruleEngine3.SPIRE_Object_Name__c = 'Contact';
        ruleEngine3.SPIRE_TECH_Source_Object_Label__c = 'Contact';
        ruleEngine3.SPIRE_Is_Active__c = true;
        ruleEngine3.SPIRE_Take__c = 'Meet All Conditions';
        ruleEngine3.SPIRE_Field_Name__c = 'Account.NumberOfEmployees';
        ruleEngine3.SPIRE_TECH_Target_Field_Label__c = 'Account ID > Employees';
        ruleEngine3.SPIRE_Score__c = 20;
        ruleEngine3.SPIRE_Action_Object__c = 'Account';
        insert ruleEngine3;
        SPIRE_Rule_Criteria__c ruleCriteriaRecord3 = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'Phone',
                                SPIRE_Tech_Field_Object__c = 'contact',
                                SPIRE_Operator__c = '!=',
                                SPIRE_Order__c = 1,
                                SPIRE_Tech_Field_Label__c = 'phone',
                                SPIRE_Type__c = 'value',
            					SPIRE_Value__c = '9876',
                                SPIRE_Rule_Engine__c = ruleEngine3.Id
            );
        insert ruleCriteriaRecord3;
        
        
        //Create Data
        Lead lead = new Lead(LastName = 'test', Salutation = 'Mr.',
                                   FirstName = '',
                                   Company = 'Account',
                                   Email = 'lastname1@test.com',
                                   //Phone = '+2125000000',
                                   NumberOfEmployees = 77
                            );
        insert lead;
        lead = new Lead(LastName = 'lastname', Salutation = 'Mr.',
                                   FirstName = 'firstname', 
                                   Company = 'Account2',
                                   Email = 'lastname1@test.com',
                                   //Phone = '+2125000000',
                                   NumberOfEmployees = 77
                            );
        insert lead;
        
        Account acc = new Account(name='Test Account', Type='Partner', NumberOfEmployees = 20);
        insert acc;
        Account acc2 = new Account(name='Test Account', ParentId=acc.Id, Type='Partner', NumberOfEmployees = 10);
        insert acc2;
        contact c = new Contact(Lastname='Test Contact', accountId = acc.Id, email = 'Test@test.com');
        insert c;

    }
    
    @IsTest
    public static void test1(){
        Test.startTest();
            SPIRE_ScoreCalculatorScheduler s = new SPIRE_ScoreCalculatorScheduler();
            s.execute(null);
        Test.stopTest();        
    }
    @IsTest
    public static void test2(){
        SPIRE_Rule_Engine__c ruleEngine1 = new SPIRE_Rule_Engine__c();
        ruleEngine1.Name = 'TestRuleEngine1';
        ruleEngine1.SPIRE_Object_Name__c = 'Lead';
        ruleEngine1.SPIRE_TECH_Source_Object_Label__c = 'Lead';
        ruleEngine1.SPIRE_Is_Active__c = true;
        ruleEngine1.SPIRE_Take__c = 'Meet Custom Condition Logic';
        ruleEngine1.SPIRE_Custom_Logic__c = '1 OR (2 AND 3)';
        ruleEngine1.SPIRE_Field_Name__c = 'NumberOfEmployees';
        ruleEngine1.SPIRE_TECH_Target_Field_Label__c = 'No. of Employees';
        ruleEngine1.SPIRE_Score__c = 99;
        ruleEngine1.SPIRE_Action_Object__c = 'Lead';
        insert ruleEngine1;
        
        
        //Create Rule Criterias
        SPIRE_Rule_Criteria__c ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'Name',
                                SPIRE_Tech_Field_Object__c = 'Lead',
                                SPIRE_Operator__c = '=',
                                SPIRE_Order__c = 1,
                                SPIRE_Tech_Field_Label__c = 'Name',
                                SPIRE_Type__c = 'Value',
                                SPIRE_Value__c = 'test',
                                SPIRE_Rule_Engine__c = ruleEngine1.Id
            );
        insert ruleCriteriaRecord;
        ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'Title',
                                SPIRE_Tech_Field_Object__c = 'Lead',
                                SPIRE_Operator__c = '=',
                                SPIRE_Order__c = 2,
                                SPIRE_Tech_Field_Label__c = 'Title',
                                SPIRE_Type__c = 'Field Reference',
                                SPIRE_Value__c = 'Status',
                                SPIRE_Tech_Field_Reference_Label__c = 'Status',
                                SPIRE_Rule_Engine__c = ruleEngine1.Id
            );
        insert ruleCriteriaRecord;
        ruleCriteriaRecord = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'LastTransferDate',
                                SPIRE_Tech_Field_Object__c = 'Lead',
                                SPIRE_Operator__c = '=',
                                SPIRE_Order__c = 3,
                                SPIRE_Tech_Field_Label__c = 'Last Transfer Date',
                                SPIRE_Type__c = 'Formula',
                                SPIRE_TECH_Formula_Field_Label__c = 'Last Modified Date',
                                SPIRE_Formula_Field_Reference__c = 'LastModifiedDate',
                                SPIRE_Formula_Operator__c = '+',
                                SPIRE_Formula_Value__c = 6,
                                SPIRE_Rule_Engine__c = ruleEngine1.Id
            );
        insert ruleCriteriaRecord; 
        
        SPIRE_Rule_Engine__c ruleEngine2 = new SPIRE_Rule_Engine__c();
        ruleEngine2.Name = 'TestRuleEngine2';
        ruleEngine2.SPIRE_Object_Name__c = 'Account';
        ruleEngine2.SPIRE_TECH_Source_Object_Label__c = 'Account';
        ruleEngine2.SPIRE_Is_Active__c = true;
        ruleEngine2.SPIRE_Take__c = 'Meet All Conditions';
        ruleEngine2.SPIRE_Field_Name__c = 'Parent.NumberOfEmployees';
        ruleEngine2.SPIRE_TECH_Target_Field_Label__c = 'Account NumberOfEmployees > Parent.NumberOfEmployees';
        ruleEngine2.SPIRE_Score__c = 20;
        ruleEngine2.SPIRE_Action_Object__c = 'Account';
        insert ruleEngine2;
        
          SPIRE_Rule_Criteria__c ruleCriteriaRecord2 = new SPIRE_Rule_Criteria__c(
                                SPIRE_Field_Name__c = 'createdDate',
                                SPIRE_Tech_Field_Object__c = 'Account',
                                SPIRE_Operator__c = '>=',
                                SPIRE_Order__c = 1,
                                SPIRE_Tech_Field_Label__c = 'Created Date',
                                SPIRE_Type__c = 'Formula',
                                SPIRE_TECH_Formula_Field_Label__c = 'LastModifiedDate',
                                SPIRE_Formula_Field_Reference__c = 'LastModifiedDate',
                                SPIRE_Formula_Operator__c = '+',
                                SPIRE_Formula_Value__c = 2,
                                SPIRE_Rule_Engine__c = ruleEngine2.Id
            );
        insert ruleCriteriaRecord2;
        Test.startTest();
            SPIRE_ScoreCalculatorScheduler s = new SPIRE_ScoreCalculatorScheduler();
            s.execute(null);
        Test.stopTest();        
    }

}