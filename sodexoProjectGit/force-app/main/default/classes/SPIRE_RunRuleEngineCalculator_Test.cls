@isTest
private class SPIRE_RunRuleEngineCalculator_Test {
    
    @isTest
    static void doInitTest(){
        SPIRE_RunRuleEngineCalculatorController e = new SPIRE_RunRuleEngineCalculatorController();
        Test.startTest();
        PageReference pageReferenceRule = e.doInit();
        Test.stopTest();
        
        System.assertEquals(true, e.ok, 'Ok message');
        System.assertEquals(false, e.noOk, 'no Ok message');
        
    }
}