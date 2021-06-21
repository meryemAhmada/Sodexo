public class SPIRE_ScoreCalculatorBatch implements Database.Batchable<sObject>, Database.Stateful{
    /**
    * Batch to to calculate and set Score
    */
    public Map<String, String> logMap {get; set;}
    public String globalErrorMsg {get; set;}
    public Integer iterator {get; set;}

    private String objectQuery;
    private String ruleEngineName;
    private String whereClause;
    private String sourceObjectName;
    private String actionObject;
    private String fieldName;
    private Decimal score;
    private String emailError;
    
    List<String> firstSplit = new List<String>();
    List<String> secondSplit = new List<String>();    
    Set<String> operatorsAndParentheses = SPIRE_QueryBuilder.getOperatorsAndParentheses();
    
    public SPIRE_ScoreCalculatorBatch(String objQ, String rleEngineNme, String whreClause, String srceObject, String actObject, String fldName, Decimal scre) {
        objectQuery = objQ;
        ruleEngineName = rleEngineNme;
        whereClause = whreClause;
        sourceObjectName = srceObject;
        actionObject = actObject;
        fieldName = fldName;
        score = scre;
        globalErrorMsg = '';
        logMap = new Map<String, String>();
        iterator = 0;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        // Get all records from the Source Object (for each records we have only the fields that we need)
        System.debug('SPI_ScoreCalculatorBatch Start');   
        System.debug('test objectQuery : ' + objectQuery);
        logMap.put('Rule Engine Name: ' , ruleEngineName);
        return Database.getQueryLocator(objectQuery);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        iterator ++;
        // Filtering records based on our criterias, and and getting a list of IDs of all the Action Object records that respect our filter, 
        //   so we can set the Score for this records
        firstSplit = new List<String>();
        secondSplit = new List<String>();
        try {
            System.debug('SPI_ScoreCalculatorBatch execute');
            Set<Id> actionObjectIds = new Set<Id>();
            Boolean finalClauseBool;
            system.debug('whereClause '+whereClause);
            whereClause = SPIRE_QueryBuilder.addSpacesIfParentheses(whereClause);
            firstSplit = whereClause.split(' ');
            system.debug('firstSplit '+firstSplit);
            for (Integer i = 0; i < firstSplit.size(); i++) {
                system.debug('firstSplit[i] '+firstSplit[i]);
                if(!operatorsAndParentheses.contains(firstSplit[i]) && firstSplit[i] != '' && firstSplit[i] != ' '){
                    secondSplit.add(firstSplit[i] + ' ' + firstSplit[i+1] + ' ' + firstSplit[i+2]);
                    system.debug('firstSplit[i] '+firstSplit[i] + ' ' + firstSplit[i+1] + ' ' + firstSplit[i+2]);
                    i = i+2;
                } else if(firstSplit[i] != ' ' && firstSplit[i] != ''){
                    secondSplit.add(firstSplit[i]);
                    system.debug('firstSplit[i] '+firstSplit[i]);
                }
            }
            system.debug('secondSplit '+secondSplit);
            system.debug('secondSplit '+secondSplit.size());
			String finalClause = '';
            for (sObject objectSource : scope) {
                finalClause = '';
                for (String secondSplitElm : secondSplit) {
                    system.debug('secondSplitElm '+secondSplitElm);
                    if(!operatorsAndParentheses.contains(secondSplitElm) && secondSplitElm != ''){
                        finalClause = finalClause + SPIRE_QueryBuilder.compare(secondSplitElm, objectSource) + ' ';
                    } else if(secondSplitElm != ''){
                        finalClause = finalClause + secondSplitElm + ' ';   
                    }
                }
                system.debug('finalClause '+finalClause);
                finalClause = SPIRE_QueryBuilder.removeSpacesIfParentheses(finalClause);
                finalClauseBool = SPIRE_BooleanExpression.eval(finalClause.trim());
                if(finalClauseBool){
                    system.debug('sourceObjectName '+sourceObjectName);
                    system.debug('actionObject '+actionObject);
                    if(sourceObjectName != actionObject){
                        List<String> fieldNameWithObject = new List<String>();
                        String targetFieldName = '';
                        fieldNameWithObject = fieldName.split('\\.');
                        if(fieldNameWithObject.size() > 1){
                            targetFieldName = fieldNameWithObject[fieldNameWithObject.size() - 2];
                        }
                        if(targetFieldName.endsWith('__c')){
                            actionObjectIds.add(String.valueOf(objectSource.get(targetFieldName))); 
                        } else if(targetFieldName.endsWith('__r')){
                            actionObjectIds.add(String.valueOf(objectSource.get(targetFieldName.replace('__r', '__c')))); 
                        } 
                        else{
                            actionObjectIds.add(String.valueOf(objectSource.get(targetFieldName + 'Id'))); 
                        }   
                    } else{
                        actionObjectIds.add(String.valueOf(objectSource.get('Id'))); 
                    }
                } 
            }
            
            List<String> fieldNameWithObject = new List<String>();
            String targetFieldName = '';
            fieldNameWithObject = fieldName.split('\\.');
            if(fieldNameWithObject.size() > 1){
                targetFieldName = fieldNameWithObject[fieldNameWithObject.size() - 1];
            }else if(fieldNameWithObject.size() == 1){
                targetFieldName = fieldNameWithObject[0];
            }
            system.debug('actionObjectIds : '+ actionObjectIds.size());
            List<String> idStrs = (List<String>)JSON.deserialize(JSON.serialize(actionObjectIds), List<String>.class);
            string allstring = string.join(idStrs,',');
            String recordsToSetQuery = 'SELECT Rules_Engine__c, ' + targetFieldName + ' FROM ' + actionObject + ' WHERE Id IN ' + SPIRE_QueryBuilder.formatSelectQuery(allstring);
            //emailError=SPIRE_QueryBuilder.formatSelectQuery(String.valueOf(allstring));
            System.debug('test recordsToSetQuery : ' + recordsToSetQuery);
            List<sObject> recordsToSet = database.query(recordsToSetQuery);
            for (sObject objectToSet : recordsToSet) {
                Decimal scoreValue = (Decimal)objectToSet.get(targetFieldName);
                String rules_engine = (String)objectToSet.get('Rules_Engine__c');            
                if(scoreValue != null){
                    scoreValue = scoreValue + score;
                    rules_engine += ' ; '+ruleEngineName; 
                } else{
                    scoreValue = score;
                    rules_engine = ruleEngineName;
                }
                objectToSet.put(targetFieldName, Integer.valueOf(scoreValue.round()));
                objectToSet.put('Rules_Engine__c', rules_engine);
            }
            
            Database.SaveResult [] updateResult = Database.update(recordsToSet, false);
            for(Database.SaveResult dsr : updateResult){
                if(!dsr.isSuccess()){
                    String errMsg = dsr.getErrors()[0].getMessage();
                    logMap.put(dsr.getId(), errMsg);
                }
            }
        } catch(Exception e) {
            System.debug('SPI_ScoreCalculatorBatch - An exception occurred: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getCause());
            globalErrorMsg += 'SPI_ScoreCalculatorBatch - An exception occurred: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getCause()+'\n';
        }
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('SPI_ScoreCalculatorBatch finish');
        
            AsyncApexJob a = [SELECT id, ApexClassId,
                       JobItemsProcessed, TotalJobItems,
                       NumberOfErrors, CreatedBy.Email
                       FROM AsyncApexJob
                       WHERE id = :bc.getJobId()];
            String body = 'Your batch job '
             + 'BatchApexAccountUpdate '
             + 'has finished. \n' 
             + 'There were '
             + ' errors. Please find the list attached to the Email.\n'
             +  globalErrorMsg;
            
            // Creating the CSV file
            String finalstr = 'Id, Error \n';
            String subject = 'SPI_ScoreCalculatorBatch - Apex Batch Error List';
            String attName = 'SPI_ScoreCalculatorBatch Errors.csv';
            for(String key  : logMap.keySet()){
                string err = logMap.get(key);
                string recordString = '"'+key+'","'+err+'"\n';
                finalstr = finalstr +recordString;
            } 
 
            // Define the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            
            // Create the email attachment    
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
            
            // Sets the paramaters of the email
            email.setSubject( subject );
            email.setToAddresses( new String[] {a.CreatedBy.Email} );
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
            // Sends the email
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            
        
    }  
}