global with sharing class EventSendActionHelper extends GNT.FlexTableActionHandler {
        public Id eventId {get;set;}
        
        global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        eventId = urlParams.get('id');     
        System.debug('===> selectedRecordIds  '+selectedRecordIds);
        
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            List<EventRelation__c> userList = [Select Id,RelationId__c,RelationId__r.Email,EventId__c from EventRelation__c where Id IN : selectedRecordIds];
            EmailTemplate et = [SELECT id,Name FROM EmailTemplate WHERE developerName = 'Event_Handler_Email_Template'];
            System.debug('===> UserList '+userList);
            System.debug('===> eventId '+eventId);
         
            /*code to send notification to selected users*/
            Event eventRecord = [Select Subject,Description from Event where Id =:eventId];
            System.debug('====> eventRecord  '+eventRecord);
            
            //List<Messaging.SingleEmailMessage> singleEmailMessagesList=new List<Messaging.SingleEmailMessage>();
            for(EventRelation__c eve : userList){
            //Pankaj: Need to bulkify send email method
            /*Messaging.SingleEmailMessage singleEmail=new Messaging.SingleEmailMessage();
            singleEmail.setTargetObjectId(eve.RelationId__c); // Specify who the email should be sent to.
            singleEmail.setWhatId(eve.EventId__c); 
            singleEmail.setTemplateId(et.id);
            singleEmail.setSaveAsActivity(false);
            System.debug('===> singleEmail '+singleEmail);
            System.debug('====> singleEmail '+singleEmail);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {singleEmail});*/
            new GNT.EmailFeeder().TargetObjectId(eve.RelationId__c).template(et.Name).contextRecordId(eve.EventId__c).send();
            }
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-24961'));
            ApexPages.addMessage(myMsg);       
            //resultMap.put('Message','Notification has been send successfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-24961'));
         }else{
            System.debug('No records found');
            //resultMap.put('Error','Please select atleast one record.');
            resultMap.put('Error',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72161'));
         }
        
        return resultMap;   
    }
}