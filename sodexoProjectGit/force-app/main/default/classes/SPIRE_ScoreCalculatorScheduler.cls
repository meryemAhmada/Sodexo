public class SPIRE_ScoreCalculatorScheduler implements Schedulable{
    /**
     * Scheduler to get all rules and call Score Reset Batch to reset all scores to NULL
    */
    public void execute(SchedulableContext ctx) {
        try {
            System.debug('SPI_ScoreCalculatorScheduler start');
            Map <String,List<String>> objectsWithFields = new Map <String,List<String>>();
            List<SPIRE_Rule_Engine__c> rulesEngines = [SELECT Name, SPIRE_Action_Object__c, SPIRE_Field_Name__c FROM SPIRE_Rule_Engine__c WHERE SPIRE_Is_Active__c = true];
            for (SPIRE_Rule_Engine__c ruleEngine : rulesEngines) {
                List<String> fieldNameWithObject = new List<String>();
                fieldNameWithObject = ruleEngine.SPIRE_Field_Name__c.split('\\.');
                if(fieldNameWithObject.size() > 1){
                    ruleEngine.SPIRE_Field_Name__c = fieldNameWithObject[fieldNameWithObject.size() - 1];
                } 
                List<String> fieldsList = new List<String>();
                if(objectsWithFields.get(ruleEngine.SPIRE_Action_Object__c) != null){
                    fieldsList = objectsWithFields.get(ruleEngine.SPIRE_Action_Object__c);
                    if(!fieldsList.contains(ruleEngine.SPIRE_Field_Name__c)){
                        fieldsList.add(ruleEngine.SPIRE_Field_Name__c);
                    }
                } else{
                    fieldsList.add(ruleEngine.SPIRE_Field_Name__c);
                }
                objectsWithFields.put(ruleEngine.SPIRE_Action_Object__c, fieldsList);
            }            
            for (String key : objectsWithFields.keySet()) {
                String query = 'SELECT Id';
                for (String fieldInList : objectsWithFields.get(key)) {
                    system.debug('fieldInList '+fieldInList);
                    query = query + ', ' + fieldInList;
                }
                query = query + ' FROM ' + key + ' WHERE ';
                for (String fieldInList : objectsWithFields.get(key)) {
                    query = query + fieldInList + ' != null AND ';
                }                
                // Call Score Reset Batch for each Object
                SPIRE_ScoreResetBatch b = new SPIRE_ScoreResetBatch(query.removeEnd(' AND '), key, objectsWithFields.get(key));
                Database.executeBatch(b);
            }
        }
        catch (Exception e) {
            System.debug('SPI_ScoreCalculatorScheduler - An exception occurred: ' + e.getMessage());
        }
    }
}