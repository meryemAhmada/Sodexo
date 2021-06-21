public class SPIRE_RuleEngineController {
    public string url {get; set;}
    public void doInit(){
        Id recordId= ApexPages.CurrentPage().getParameters().get('id');
        if(!String.isEmpty(recordId)){
            url = '/lightning/n/SPIRE_Rule_Engine?c__id=' + recordId;
        }
        else{
            url = '/lightning/n/SPIRE_Rule_Engine';
        }
   }
}