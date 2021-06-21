public class SPIRE_RunRuleEngineCalculatorController {
    
    public boolean ok {get;set;}
    public boolean noOk{get;set;}
    
    
    public PageReference doInit(){
        SPIRE_ScoreCalculatorScheduler s = new SPIRE_ScoreCalculatorScheduler();
        s.execute(null);
        ok = true;
        noOk = false;
        
        PageReference ruleEngineList = new PageReference('/lightning/o/SPIRE_Rule_Engine__c/list');
        ruleEngineList.setRedirect(true);
        
        return ruleEngineList;
        
    }
    
    
    
    
}