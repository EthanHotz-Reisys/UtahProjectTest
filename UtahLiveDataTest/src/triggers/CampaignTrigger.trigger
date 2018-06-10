trigger CampaignTrigger on Campaign__c (before insert,after insert,before update) {  //need to chk triigers
if (Trigger.isBefore){
    for (Campaign__c a : Trigger.new) {
         if(Trigger.isInsert){
            if(a.StartDate__c < System.today()){
                    a.addError('Start Date cannot be less then Today’s Date');
            }
            if(a.EndDate__c < a.StartDate__C){
                    a.addError('Campaign End Date cannot be less then Start Date');
                }
            if(a.EndDate__c == a.StartDate__C){
                    a.addError('Campaign End Date should be greater than Start Date');
                }
            }
            if((a.StartDate__c < Datetime.now()) && (a.EndDate__c < Datetime.now())){  
                a.Status__c = 'Closed';    
            }
            if(Trigger.isUpdate){
                Campaign__c oldEve = Trigger.oldMap.get(a.Id);
                if((oldEve.StartDate__c < Datetime.now()) && (oldEve.EndDate__c < Datetime.now())){
                a.Status__c = 'Closed';
                }
                if( (a.Name == oldEve.Name) && (a.StartDate__c == oldEve.StartDate__c ) && (a.EndDate__c == oldEve.EndDate__c) && (a.Subject__c == oldEve.Subject__c) && (a.Body__c == oldEve.Body__c)){
                } else {
                a.Status__c = 'Updated';
                }
            }
        }
    }
    
 }