global with sharing class ReviewApplicationResendEmailHandler extends GNT.FlexTableActionHandler {
    global override MAP<String,Object> clickHandler(){
        System.debug('++  selected ids ' + selectedRecordIds);    
        System.debug('++  selectedRecordId ' + selectedRecordIds);
        ReviewStepApplication__c rsa = [SELECT Id,Name,RecordType.Name,RecordType.DeveloperName,ReviewStep__r.ApprovalEmailTemplate__c,ReviewStep__r.RejectionEmailTemplate__c,Application__c,PreApplication__c,Decision__c,Application__r.OwnerId,PreApplication__r.OwnerId FROM ReviewStepApplication__c WHERE Id IN :selectedRecordIds];
        MAP<String,Object> resultMap = new MAP<String,Object>();
        String emailTemplate;
        Map<Id,Id> appToContactId = new Map<Id,Id>();        
        User u;
        Id ownerId;  
        Boolean application = false;         
        if(rsa.RecordType.Name == 'Application'){
            ownerId =  rsa.Application__r.OwnerId;
            application = true;                         
        }
        else if(rsa.RecordType.Name == 'Pre-Application'){                  
            ownerId =  rsa.PreApplication__r.OwnerId;
            application = false;
        }       
        
        u  = [SELECT ContactId,Contact.Email From User WHERE Id = :ownerId]; 
        if(application){            
            appToContactId.put(rsa.Application__c,u.ContactId);
        }else{
            appToContactId.put(rsa.PreApplication__c,u.ContactId);
        }  
            
        if(rsa.Decision__c == 'Promoted'){   
            emailTemplate = rsa.ReviewStep__r.ApprovalEmailTemplate__c;
        }else if(rsa.Decision__c == 'Rejected'){
            emailTemplate = rsa.ReviewStep__r.RejectionEmailTemplate__c;
        }
  
        if(!String.isEmpty(emailTemplate)){
            EmailTemplate approveOrReject = [SELECT Id From EmailTemplate WHERE DeveloperName = :emailTemplate];    
            GNT.AppUtils.sendEmailUsingTemplate(approveOrReject.id,appToContactId,true);                       
            String msg = 'Email to \''+u.Contact.Email+'\' sent successfully ';
            resultMap.put('Message',msg);
        }else{
            String msg = 'Problem Sending email, contact System Administrator.';
            resultMap.put('Message',msg);
        }
        
        return resultMap;
        return null;
    }
}