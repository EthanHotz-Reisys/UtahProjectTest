/**
* Tool tetsting comment
*/
global abstract with sharing class AbstractProcessIntegrationRecord {

    global IntegrationConfig__c config;
    global IntegrationDetailConfig__c configDetail;
    global IntegrationDetailConfig__c configDetail1;
    
    /*Map<String, List<String>> errors = new Map<String, List<String>>();
    Map<String, List<String>> messages = new Map<String, List<String>>();
                    
    protected void addError(String fieldName, String errorMsg){
        List<String> fieldErrors = errors.get(fieldName);
        if(fieldErrors != null){
            fieldErrors.add(errorMsg);
        }else{
            fieldErrors = new List<String>{errorMsg};
            errors.put(fieldName, fieldErrors);
        }
    }
//Test
    protected void addMessage(String fieldName, String infoMsg){
        List<String> fieldMessages = messages.get(fieldName);
        if(fieldMessages != null){
            fieldMessages.add(infoMsg);
        }else{
            fieldMessages = new List<String>{infoMsg};
            messages.put(fieldName, fieldMessages);
        }
    }
    
    global boolean hasErrors(){
        return errors.isEmpty();
    }
    
    global Map<String, List<String>> getErrors(){
        return errors;
    }t*/

    global abstract void preTransform(Map<String, String> context, Map<String, String> recordValues);
    global abstract void postTransform(Map<String, String> context, sObject sObj);
    
}