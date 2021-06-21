public with sharing class SPIRE_CTRL002CustomLookup {
    // FETCH ALL RECORDS THAT CONTAINS searchString
    @AuraEnabled 
    public static List<RecordsData> fetchRecords(String searchString) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            
            List<SelectOption> objectdName = new List<SelectOption> { };//to get list of all salesforce object
            for(SObjectType sType: Schema.getGlobalDescribe().values()) {
                DescribeSObjectResult res = sType.getDescribe();
                objectdName.add(new SelectOption(res.getName(), res.getLabel())); 
            }
            objectdName.sort();
            for(SelectOption so :objectdName){ 
                if(so.getLabel().contains(nameFormat(searchString)))
                {
                    recordsDataList.add(new RecordsData(so.getLabel(),so.getValue()));
                }
            }
            return recordsDataList;
        } catch (Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
    }

    //RETURNS LABEL AND NAME OF objName AS INSTANCE OF RecordsData
    @AuraEnabled
    public static RecordsData getSelectedObj(String objName) {
        try {
            DescribeSObjectResult res = Schema.getGlobalDescribe().get(objName).getDescribe();
            return new RecordsData(res.getLabel() , res.getName()); 

        } catch (Exception err) {
            throw new AuraHandledException(err.getMessage());
        }
    }

    //Method that change the first letter to upper case
    public static String nameFormat (String objname) {
        String result = '';
    
        if (objname != null && objname != '') {
            for (String iter : objname.split('[ ]+')) {
                if (iter != null && iter != '') {
                    if (iter.length() > 1) {  
                          result += iter.substring(0,1).toUpperCase() + iter.substring(1,iter.length()) + ' ';
                        }
                    else {
                          result += iter.substring(0,1).toUpperCase() + ' ';
                    }
                }
            }
            result = result.substring(0, result.length() - 1);
          }
          return result;
    } 

    //Wrapper Class
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;

        }
    }
}