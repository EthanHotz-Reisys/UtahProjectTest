global with sharing class AddInviteesActionHelper extends GNT.FlexTableActionHandler {
       global Id eventId {get;set;}
       global String flexTableName {get;set;}
       global override Map<String,Object> clickHandler(){ 
        Map<String,Object> resultMap = new Map<String,Object>();
        eventId = urlParams.get('id');     
        flexTableName = urlParams.get('flexTableName');     
        System.debug('===> selectedRecordIds  '+selectedRecordIds);
        
         if(selectedRecordIds != null && !selectedRecordIds.isEmpty()){
            List<User> usrList = [Select Id,Email from User where Id IN :selectedRecordIds];
            //List<EventRelation> iErelation = new List<EventRelation>();
            List<EventRelation__c> custErelation = new List<EventRelation__c>();
            System.debug('===> UserList '+usrList);
            System.debug('===> parentId '+eventId);
            Event eve = [Select Id,EventRelationId__c from Event where Id =: eventId];
            
            /*code to send notification to selected user*/
            for(User user : usrList){
                //EventRelation er = new EventRelation();
                //er.EventId = eventId;
                //er.RelationId = user.Id;
                //iErelation.add(er);
                EventRelation__c eveRel = new EventRelation__c();
                eveRel.EventId__c = eventId;
                eveRel.RelationId__c = user.Id;
                eveRel.Status__c = 'Tentative';
                //eveRel.EventRelationId__c = er.Id;
                custErelation.add(eveRel);
            }
            /*Database.DMLOptions dmo = new Database.DMLOptions(); 
            dmo.EmailHeader.triggerUserEmail = true; 
            dmo.EmailHeader.triggerAutoResponseEmail = true;
            dmo.EmailHeader.triggerOtherEmail= true;*/
            //insert iErelation;
            insert custErelation;
            //System.debug('====> iErelation  '+iErelation);
            System.debug('====> custErelation '+custErelation);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-24961'));
            ApexPages.addMessage(myMsg);       
            // resultMap.put('Message','Funding Accounts added succesfully.');
            //resultMap.put('Warning','Funding Accounts added succesfully.');
            //resultMap.put('Message',myMsg);
            //resultMap.put('Success','Notification send successfully.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-24961'));
            resultMap.put('PageReference','/apex/AddInviteesView?id='+ eventId +'&flexTableName='+flexTableName);
            
         }else{
            System.debug('No records found');
            //resultMap.put('Error','Please select atleast one record.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72161'));
         }
        
        return resultMap;   
    }
    
}