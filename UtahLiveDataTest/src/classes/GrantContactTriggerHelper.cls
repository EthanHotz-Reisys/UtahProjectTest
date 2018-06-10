public with sharing class GrantContactTriggerHelper extends GNT.TriggerHelper {
    public static boolean skipTrigger = false;
    public override void processBeforeInsert() {
     if(skipTrigger == false){
        checkforDuplicateRoles();         
      } 
    } 
    
     /* Check for duplicate Roles ie; Same person */
    private void checkforDuplicateRoles(){
        List<String> awardID = new List<String>();
     
        for(GrantContact__c contact : (List<GrantContact__c>)Trigger.new){
            if(contact.Role__c!= null){
                awardID.add(contact.Award__c); 
            }                     
        }      
        
        if(awardID!= null && !awardID.isEmpty()){
          if(awardID.size() > 0){
          Map<Id,List<GrantContact__c>> parentRoles = new Map<Id,List<GrantContact__c>>();    
          String query =  'Select Id,Role__c,Award__c from GrantContact__c where Award__c in '+GNT.AppUtils.soqlList(awardId);
          List<GrantContact__c> lstRoles = Database.query(query); 
            for(GrantContact__c roleandresp : (List<GrantContact__c>)lstRoles){
                for(GrantContact__c role : (List<GrantContact__c>)Trigger.new){
                    if(roleandresp.Award__c == role.Award__c)
                        if(roleandresp.Role__c!=null && role.Role__c == roleandresp.Role__c){
                            // role.addError('Person with Same Role cannot be added again');
                            //role.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-19298'));
                         }
                    }
                }
            }  
        }     
    }
 }