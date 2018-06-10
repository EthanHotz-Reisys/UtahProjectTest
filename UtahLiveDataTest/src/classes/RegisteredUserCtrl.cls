public with sharing class RegisteredUserCtrl {

    public ID recordId {get;set;}
    
    public RegisteredUserCtrl() {
         
          User loggedInUser = [Select AccountId From User Where id = :UserInfo.getUserId()];
          recordId = loggedInUser.AccountId;
          }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        System.debug(' >>>the Debug Log is <<<< '+recordId);
        keyValueMap.put('orgId', recordId);
        return JSON.serialize(keyValueMap);
    }
}