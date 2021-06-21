public class SPIRE_ScoreResetBatch implements Database.Batchable<sObject>{
    /**
    * Batch to reset all scores to NULL for the Action Object (The Object that we get from the rule engine)
    * The Batch get a Query to execute and a List of fields (Score fields) from the Scheduler
    * In the 'finish' part of this Batch we construct queries based on Rules Criterias and for each Rule Engine we call the Score Calculator Batch
    */  
    private String query;
    private String actionObject;
    private List<String> fieldsList = new List<String>();
    
    public SPIRE_ScoreResetBatch(String qry, String actObject, List<String> fldsList) {
        query = qry;
        actionObject = actObject;
        fieldsList = fldsList;
    } 
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('SPI_ScoreResetBatch start');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scope){
        try {
            if(scope.size() > 0){
                System.debug('SPI_ScoreResetBatch execute');
                for (sObject objectToSet : scope) {
                    for (String fieldInList : fieldsList) {
                        objectToSet.put(fieldInList, null);
                        objectToSet.put('Rules_Engine__c','');
                    }
                }
                update scope;
            }
        } catch(Exception e) {
            System.debug('SPI_ScoreResetBatch - An exception occurred: ' + e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug('SPI_ScoreResetBatch finish');
        try {
            String criteria = '';
            String resultCriteria = '';
            Map<String, String> objectCriterias = new Map<String, String>();
            List<String> fieldsToRetrieve = new List<String>();
            map<String,List<String>> mapOfFieldsToRetrieveByRule = new map<String,List<String>>();
            List<SPIRE_QueryBuilder.RuleEngineWithWhereClause> rulesEngineWithWhereClause = new List<SPIRE_QueryBuilder.RuleEngineWithWhereClause>();
            List<SPIRE_Rule_Criteria__c> ruleCriterias = [SELECT Name, SPIRE_Field_Name__c, SPIRE_Operator__c, SPIRE_Type__c, SPIRE_Value__c, SPIRE_Order__c, SPIRE_Tech_Field_Object__c, SPIRE_Formula_Field_Reference__c, SPIRE_Formula_Operator__c, SPIRE_Formula_Value__c, SPIRE_Rule_Engine__r.SPIRE_Object_Name__c, SPIRE_Rule_Engine__r.SPIRE_Take__c, SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c FROM SPIRE_Rule_Criteria__c WHERE SPIRE_Rule_Engine__r.SPIRE_Is_Active__c = true AND SPIRE_Rule_Engine__r.SPIRE_Action_Object__c = :actionObject];
            for (SPIRE_Rule_Criteria__c ruleCriteria : ruleCriterias) { 
                System.debug('test fieldsToRetrieve start : ' + fieldsToRetrieve);
                if(ruleCriteria.SPIRE_Value__c != null || ruleCriteria.SPIRE_Formula_Value__c != null){
                    if(ruleCriteria.SPIRE_Value__c != null)ruleCriteria.SPIRE_Value__c = ruleCriteria.SPIRE_Value__c.replace(' ','######');
                    if(ruleCriteria.SPIRE_Type__c == 'Field Reference'){
                        criteria = SPIRE_QueryBuilder.addDelimiters(ruleCriteria.SPIRE_Field_Name__c) + ' ' + ruleCriteria.SPIRE_Operator__c + ' ' + String.escapeSingleQuotes(SPIRE_QueryBuilder.addDelimiters(ruleCriteria.SPIRE_Value__c));
                        fieldsToRetrieve.add(ruleCriteria.SPIRE_Field_Name__c);
                        fieldsToRetrieve.add(ruleCriteria.SPIRE_Value__c);
                        if(!mapOfFieldsToRetrieveByRule.containsKey(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c)){
                            mapOfFieldsToRetrieveByRule.put(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c,new List<String>{ruleCriteria.SPIRE_Field_Name__c,ruleCriteria.SPIRE_Value__c});
                        }else{
                            mapOfFieldsToRetrieveByRule.get(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c).addAll(new List<String>{ruleCriteria.SPIRE_Field_Name__c,ruleCriteria.SPIRE_Value__c});
                        }
                    } else if(ruleCriteria.SPIRE_Type__c == 'Formula'){
                        String formulaClause = '';
                        formulaClause = SPIRE_QueryBuilder.addFormulaDelimiters(ruleCriteria.SPIRE_Formula_Field_Reference__c) + ',' + ruleCriteria.SPIRE_Formula_Operator__c + ',' + SPIRE_QueryBuilder.addFormulaDelimiters(String.valueOf(ruleCriteria.SPIRE_Formula_Value__c));
                        fieldsToRetrieve.add( ruleCriteria.SPIRE_Formula_Field_Reference__c);
                        criteria = SPIRE_QueryBuilder.addDelimiters(ruleCriteria.SPIRE_Field_Name__c) + ' ' + ruleCriteria.SPIRE_Operator__c + ' ' + String.escapeSingleQuotes(formulaClause);
                        fieldsToRetrieve.add(ruleCriteria.SPIRE_Field_Name__c);
                        if(!mapOfFieldsToRetrieveByRule.containsKey(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c)){
                            mapOfFieldsToRetrieveByRule.put(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c,new List<String>{ruleCriteria.SPIRE_Field_Name__c,ruleCriteria.SPIRE_Formula_Field_Reference__c});
                        }else{
                            mapOfFieldsToRetrieveByRule.get(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c).addAll(new List<String>{ruleCriteria.SPIRE_Field_Name__c,ruleCriteria.SPIRE_Formula_Field_Reference__c});
                        }
                    } else{
                        criteria = SPIRE_QueryBuilder.addDelimiters(ruleCriteria.SPIRE_Field_Name__c) + ' ' + ruleCriteria.SPIRE_Operator__c + ' ' + String.escapeSingleQuotes(ruleCriteria.SPIRE_Value__c); 
                        fieldsToRetrieve.add(ruleCriteria.SPIRE_Field_Name__c);
                        if(!mapOfFieldsToRetrieveByRule.containsKey(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c)){
                            mapOfFieldsToRetrieveByRule.put(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c,new List<String>{ruleCriteria.SPIRE_Field_Name__c});
                        }else{
                            mapOfFieldsToRetrieveByRule.get(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Object_Name__c).addAll(new List<String>{ruleCriteria.SPIRE_Field_Name__c});
                        }
                        system.debug('ruleCriteria.SPIRE_Field_Name__c '+ruleCriteria.SPIRE_Field_Name__c);
                    }
                } else{
                    criteria = ruleCriteria.SPIRE_Field_Name__c + ' ' + ruleCriteria.SPIRE_Operator__c + ' null';
                }
                if(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Take__c == 'Meet All Conditions'){
                    if(objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id) != null){
                        resultCriteria = objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id) + ' AND ' + criteria;
                    }else{
                        resultCriteria = criteria;
                    }
                } else if(ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Take__c == 'Meet Any Condition'){
                    if(objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id) != null){
                        resultCriteria = objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id) + ' OR ' + criteria;
                    }else{
                        resultCriteria = criteria;
                    }
                } else{

                    // if Meet Custom Condition Logic - exp : 1 AND (2 OR 3)                    
                    if(objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id) != null){
                        system.debug('IN CustomLogic'+objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id));
                        
                        resultCriteria = objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id).replace('( '+String.valueOf(ruleCriteria.SPIRE_Order__c), '( '+criteria);
                        if(resultCriteria == objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id))
                            resultCriteria = objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id).replace('('+String.valueOf(ruleCriteria.SPIRE_Order__c), '('+criteria);
                        if(resultCriteria == objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id))
                            resultCriteria = objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id).replace('OR '+String.valueOf(ruleCriteria.SPIRE_Order__c), 'OR '+criteria);
                        if(resultCriteria == objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id))
                            resultCriteria = objectCriterias.get(ruleCriteria.SPIRE_Rule_Engine__r.Id).replace('AND '+String.valueOf(ruleCriteria.SPIRE_Order__c), 'AND '+criteria);
                        
                    }else{
                        
                        resultCriteria = ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c.replace('( '+String.valueOf(ruleCriteria.SPIRE_Order__c), '( '+criteria);
                        if(resultCriteria == ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c)
                            resultCriteria = ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c.replace('('+String.valueOf(ruleCriteria.SPIRE_Order__c), '('+criteria);
                        if(resultCriteria == ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c)
                            resultCriteria = ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c.replace('AND '+String.valueOf(ruleCriteria.SPIRE_Order__c), 'AND '+criteria);
                        if(resultCriteria == ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c)
                            resultCriteria = ruleCriteria.SPIRE_Rule_Engine__r.SPIRE_Custom_Logic__c.replace('OR '+String.valueOf(ruleCriteria.SPIRE_Order__c), 'OR '+criteria);
                        
                    }
                }
                System.debug('test fieldsToRetrieve start : ' + fieldsToRetrieve);
                system.debug('resultCriteria: '+resultCriteria);
                objectCriterias.put(ruleCriteria.SPIRE_Rule_Engine__r.Id, resultCriteria);
            }
            System.debug('test objectCriterias : ' + objectCriterias);
            for (String key : objectCriterias.keySet()) {
                SPIRE_QueryBuilder.RuleEngineWithWhereClause ruleEngineWithWhereClause = new SPIRE_QueryBuilder.RuleEngineWithWhereClause(null, '');
                ruleEngineWithWhereClause = SPIRE_QueryBuilder.formatRuleEngineWithWhereClause(key, objectCriterias.get(key));
                rulesEngineWithWhereClause.add(ruleEngineWithWhereClause);
            }
            System.debug('test rulesEngineWithWhereClause : ' + rulesEngineWithWhereClause);
            for(SPIRE_QueryBuilder.RuleEngineWithWhereClause ruleEngineWithWhereClause : rulesEngineWithWhereClause){
                system.debug('ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c '+ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c);
                List<String> fieldNameWithObject = new List<String>();
                String targetFieldName = '';
                fieldNameWithObject = ruleEngineWithWhereClause.ruleEngine.SPIRE_Field_Name__c.split('\\.');
                if(fieldNameWithObject.size() > 1){
                    targetFieldName = fieldNameWithObject[fieldNameWithObject.size() - 2];
                }
                String FieldId = '';
                if(ruleEngineWithWhereClause.ruleEngine.SPIRE_Action_Object__c == ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c){
                    FieldId = 'Id';
                } else if(ruleEngineWithWhereClause.ruleEngine.SPIRE_Action_Object__c.endsWith('__c')){
                    FieldId = ruleEngineWithWhereClause.ruleEngine.SPIRE_Action_Object__c.replace('__c', '__r') + '.Id';
                } else if(targetFieldName.endsWith('__r')){
                    FieldId = targetFieldName + '.Id';
                } 
                else{
                    FieldId = ruleEngineWithWhereClause.ruleEngine.SPIRE_Action_Object__c + '.Id';
                }
                set<String>objectQueryFields = new set<String>();
                String objectQuery = 'SELECT ' + FieldId;
                
                SObjectType objectType = Schema.getGlobalDescribe().get(ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c);
                Set<String> objectFields = objectType.getDescribe().fields.getMap().keySet();
                for(String ruleEng :mapOfFieldsToRetrieveByRule.keySet()){
                    system.debug('ruleEng '+ruleEng);
                    System.debug('mapOfFieldsToRetrieveByRule.get(ruleEng) '+mapOfFieldsToRetrieveByRule.get(ruleEng));
                    system.debug('ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c '+ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c);
                    if(ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c != ruleEng){
                        system.debug('Break ');
                        continue;
                    }
                    for (String fieldToRetrieve : mapOfFieldsToRetrieveByRule.get(ruleEng)) {
                        system.debug('fieldToRetrieve '+ fieldToRetrieve);
                        if(!objectQueryFields.contains(fieldToRetrieve) ){
                            system.debug('fieldToRetrieve '+ fieldToRetrieve);
                            if(fieldToRetrieve != 'TODAY')objectQuery = objectQuery + ', ' + fieldToRetrieve;
                            objectQueryFields.add(fieldToRetrieve);
                        }
                        
                    }
                }
                objectQuery = objectQuery + ' FROM ' + ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c;
                system.debug('objectQuery '+objectQuery);
                system.debug('ruleEngineWithWhereClause.whereClause '+ruleEngineWithWhereClause.whereClause);
                // Call Score Calculator Batch
                // objectQuery : query to get all records (for each records we have only the fields that we need) from the Source object
                // whereClause : logic to filter records
                SPIRE_ScoreCalculatorBatch b = new SPIRE_ScoreCalculatorBatch(objectQuery, ruleEngineWithWhereClause.ruleEngine.Name,
                                                                        ruleEngineWithWhereClause.whereClause,
                                                                        ruleEngineWithWhereClause.ruleEngine.SPIRE_Object_Name__c,
                                                                        ruleEngineWithWhereClause.ruleEngine.SPIRE_Action_Object__c, 
                                                                        ruleEngineWithWhereClause.ruleEngine.SPIRE_Field_Name__c, 
                                                                        ruleEngineWithWhereClause.ruleEngine.SPIRE_Score__c);
                Integer batchSize = 10;
                If(Integer.valueOf(system.Label.SPIRE_BatchSize) <= 200)batchSize=Integer.valueOf(system.Label.SPIRE_BatchSize);
                Database.executeBatch(b,batchSize);
            }
        } catch (Exception e) {
            System.debug('SPI_ScoreResetBatch - An exception occurred: ' + e.getMessage());
        }
    }
}