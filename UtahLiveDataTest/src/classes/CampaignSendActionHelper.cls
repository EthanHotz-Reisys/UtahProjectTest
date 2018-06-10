global with sharing class CampaignSendActionHelper extends GNT.DynamicLayoutActionRedirect {
    public Id campaignId {get;set;}
    global override PageReference whenClicked(){    
        campaignId = layoutHolder.getPrimarySObject().Id; 
        Set<String> sentIdSet,addedIdSet;  
        String addedIds,sentIds;
        Boolean val;
        Boolean isError = false;
        try{
            Campaign__c campaignRecord = [Select Name,Body__c,AddedEmailIds__c,SentEmailIds__c from Campaign__c where Id =:campaignId];            
            addedIds = campaignRecord.AddedEmailIds__c;
            sentIds = campaignRecord.SentEmailIds__c;
            if(sentIds != NULL)
                sentIdSet = (Set<String>)JSON.deserializeStrict(sentIds,Set<String>.class);
                if(addedIds != NULL){
                addedIdSet = (Set<String>)JSON.deserializeStrict(addedIds,Set<String>.class);
                for(string s : addedIdSet){
                    if(sentIdSet == NULL){
                        sentIdSet =  new Set<String>();
                        sentIdSet.add(s);
                    }else{
                        val = sentIdSet.contains(s) ? addedIdSet.remove(s) : sentIdSet.add(s);
                    }
                }
               sendEmail(campaignRecord , addedIdSet);
               campaignRecord.SentEmailIds__c = JSON.serialize(sentIdSet);
               campaignRecord.AddedEmailIds__c = JSON.serialize(addedIdSet);
               update campaignRecord; 
               String succesMsg = 'Campaign sent successfully.';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,succesMsg));
               return null;
           }else{
               
               String errmsg = 'You dont have any members added in list.Please add members to send this Campaign.';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errmsg));
               return null;
           }
          
          }catch(System.LimitException e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Something went wrong. Please contact your administrator.'));
            return null;
        }
    } 
    
    public void sendEmail(Campaign__c campaignRecord, Set<String> targetObjectIds){
        List<Messaging.SingleEmailMessage> singleEmailMessagesList=new List<Messaging.SingleEmailMessage>();                    
        EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'GG_Campaign_Create_1'];
        System.debug('===> et '+et);
        System.debug('===> targetObjectIds '+targetObjectIds);
        for(ID id: targetObjectIds){    
            /*Messaging.SingleEmailMessage singleEmail=new Messaging.SingleEmailMessage();
            singleEmail.setTargetObjectId(id); 
            singleEmail.setWhatId(campaignRecord.Id); 
            singleEmail.setTemplateId(et.id);
            singleEmail.setSaveAsActivity(false);
            singleEmailMessagesList.add(singleEmail);*/
            //Make it bulkify
            //new GNT.EmailFeeder().TargetObjectId(id).template('GG_Campaign_Create').contextRecordId(campaignRecord.Id).send();
            new GNT.EmailFeeder().template('GG_Campaign_Create_1').TargetObjectId(id).contextRecordId(campaignRecord.Id).send();
           System.debug('===> id'+id); 
            /*if(!campaignRecord.Body__c.contains('Ref :')){
                campaignRecord.Body__c += '\nRef :' + campaignRecord.CampaignNo__c ;
            }*/
             if(!campaignRecord.Body__c.contains('Ref :')){
                campaignRecord.Body__c += ' ';
            }
            campaignRecord.SentEmailIds__c = (campaignRecord.SentEmailIds__c == NULL) ? (id + ',') : (campaignRecord.SentEmailIds__c + id + ',');                   
        }
        if(singleEmailMessagesList.size() > 0){
            EmailServicesAddress sysEmailAddress= [SELECT id,LocalPart,EmailDomainName FROM EmailServicesAddress where LocalPart = 'campaignemailservice'];
            List<String> ccAddress = new List<String>();
            String email = sysEmailAddress.LocalPart + '@' + sysEmailAddress.EmailDomainName;
            ccAddress.add(email);
           
          //  Messaging.SingleEmailMessage singleEmail=new Messaging.SingleEmailMessage();
           // singleEmail.setToAddresses(ccAddress);
           // singleEmail.setSubject(campaignRecord.Subject__c); 
           // singleEmail.setPlainTextBody(campaignRecord.Body__c + '\nRef :' + campaignRecord.CampaignNo__c);
           // singleEmailMessagesList.add(singleEmail);
            new GNT.EmailFeeder().toEmail(String.join(ccAddress,',')).subject(campaignRecord.Subject__c).htmlBody(campaignRecord.Body__c + '\nRef :' + campaignRecord.CampaignNo__c).send();
          // Messaging.sendEmail(singleEmailMessagesList);   
            update campaignRecord;
            
            
        }                   
    }   
}