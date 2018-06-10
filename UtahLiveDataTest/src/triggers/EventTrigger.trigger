trigger EventTrigger on Event (before insert,before update) {
if (Trigger.isBefore){
    System.debug('===>Trigger.new[0].WhatId '+Trigger.new[0].WhatId);
    //String programName = [SELECT ProgramName__c from Program__c where Id =:Trigger.new[0].WhatId].ProgramName__c;
    //programName = [SELECT AnnouncementName__c from Announcement__c where Id =:Trigger.new[0].WhatId].AnnouncementName__c;
    //programName = [SELECT ProjectTitle__c from Grant__c where Id =:Trigger.new[0].WhatId].ProjectTitle__c;
     for (Event a : Trigger.new) {
         if(Trigger.isInsert){
                if(a.StartDateTime < System.now()){
                    a.addError('Start Date and Time should be greater than Today’s Date and Time');
                }
                if(a.EndDateTime < a.StartDateTime){
                    a.addError('Event duration cannot be negative');
                }
                  if(a.EndDateTime == a.StartDateTime){
                    a.addError('Event Start Date and Time should not be equal to End Date and Time');
                }
            }
             if(a.WhatId.getSObjectType().getDescribe().getName() == 'Program__c')
                a.RelatedToTitle__c = [SELECT ProgramName__c from Program__c where Id =:a.WhatId].ProgramName__c;
            else if(a.WhatId.getSObjectType().getDescribe().getName() == 'Announcement__c') 
                a.RelatedToTitle__c = [SELECT AnnouncementName__c from Announcement__c where Id =:a.WhatId].AnnouncementName__c;
            else if(a.WhatId.getSObjectType().getDescribe().getName() == 'Grant__c') 
                a.RelatedToTitle__c = [SELECT ProjectTitle__c from Grant__c where Id =:a.WhatId].ProjectTitle__c;
            if((a.StartDateTime > Datetime.now()) && (a.EndDateTime > Datetime.now()))  
                a.EventStatus__c = 'Active';
            if((a.StartDateTime <= Datetime.now()) && (a.EndDateTime >= Datetime.now()))  
                a.EventStatus__c = 'Open';    
            if((a.StartDateTime < Datetime.now()) && (a.EndDateTime < Datetime.now()))  
                a.EventStatus__c = 'Completed';    
            if(Trigger.isUpdate){
                Event oldEve = Trigger.oldMap.get(a.Id);
                if( (a.Subject == oldEve.Subject) && (a.Location == oldEve.Location) && (a.StartDateTime == oldEve.StartDateTime) && (a.EndDateTime== oldEve.EndDateTime) && (a.Type== oldEve.Type) && (a.Description == oldEve.Description)){
                    a.IsUpdated__c = false;
                } else {
                    a.IsUpdated__c = true;
                }
            }
            
            
      
        }
    }
}