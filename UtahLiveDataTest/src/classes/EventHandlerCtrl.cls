public with sharing class EventHandlerCtrl {
    public ID recordId{get;set;}
    public String flexTableName{get;set;}
    public Id eventId {get;set;}
    public ID parentId{get;set;}
    public Boolean IsUpdated{get;set;}
    public Boolean SendNotification{get;set;}
    public String templateName{get;set;}
    public PageReference savePage {get;set;}
    public String layoutId {get;set;}
    public List<EventRelation__c> userList {get;set;} 
    public Event eventRecord {get;set;} 
    public Boolean updateNotification {get;set;} 
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public EventHandlerCtrl(){
    }
    public EventHandlerCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');        
        flexTableName = ApexPages.CurrentPage().getParameters().get('flexTableName');        
        parentId = ApexPages.CurrentPage().getParameters().get('parentId');
        if(recordId != NULL){
                eventRecord = [Select StartDateTime,EndDateTime,IsUpdated__c,SendNotification__c from Event where Id =: recordId];
                userList = [Select Id,RelationId__c,RelationId__r.Email,EventId__c from EventRelation__c where EventId__c =: recordId];
                updateNotification = userList.size() > 0 ? true : false;
                IsUpdated = eventRecord.IsUpdated__c;
                //IsUpdated = false;
                SendNotification = eventRecord.SendNotification__c;
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('whatId',parentId,true);
        listDefaultValues.add(dv);
        templateName = 'Event Creation Window';
        savePage = Page.EventHandlerView;
        savePage.getParameters().put('id', recordId); 
    }
  
     public string getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        List<String> idString = new List<String>();
        for(EventRelation__c s:userList) {
           idString.add((String)s.get('RelationId__c'));
        }
        keyValueMap.put('RelId',idString);
        keyValueMap.put('UserId',UserInfo.getUserId());
        //keyValueMap.put('Id', ApexPages.CurrentPage().getParameters().get('id'));
        keyValueMap.put('Id', recordId);
        return JSON.serialize(keyValueMap);
    }
    
    public void sendNotification(){
        //EmailTemplate et = [SELECT id,developerName FROM EmailTemplate WHERE developerName = 'EventHandlerEmailTemplate'];
        if(eventRecord.IsUpdated__c == false)
            eventRecord.IsUpdated__c = true;
        else if(eventRecord.IsUpdated__c == true)
            eventRecord.IsUpdated__c = false;
        update eventRecord;
        
        List<Messaging.SingleEmailMessage> singleEmailMessagesList=new List<Messaging.SingleEmailMessage>();
        for(EventRelation__c eve : userList){
            //Pankaj: Need to bulkify it
            /*Messaging.SingleEmailMessage singleEmail=new Messaging.SingleEmailMessage();
            singleEmail.setTargetObjectId(eve.RelationId__c); // Specify who the email should be sent to.
            singleEmail.setWhatId(userList[0].EventId__c); 
            singleEmail.setTemplateId(et.id);
            singleEmail.setSaveAsActivity(false);
            singleEmailMessagesList.add(singleEmail);*/
         	 new GNT.EmailFeeder().TargetObjectId(eve.RelationId__c).template('Event_Handler_Email_Template').contextRecordId(userList[0].eventId__c).send();
        }
        Messaging.sendEmail(singleEmailMessagesList);  
     }
     
     public void setValue(){
         IsUpdated = false;
         eventRecord.IsUpdated__c = false;
         update eventRecord;
     }
     
      public void updateStatus(){
            recordId = ApexPages.CurrentPage().getParameters().get('id');   
            System.debug('===>recordId '+recordId);
            System.debug('===>UserInfo.getUserId() '+UserInfo.getUserId());
            List<Event> eventRecord = new List<Event>();
            eventRecord = [Select StartDateTime,EndDateTime,IsUpdated__c,SendNotification__c,Ischild from Event where Ischild = false and OwnerId =: UserInfo.getUserId() and whatId =: recordId];
            System.debug('===>eventRecord'+eventRecord);
            for(Event eve : eventRecord ){
                if((eve.StartDateTime > Datetime.now()) && (eve.EndDateTime > Datetime.now()))  
                    eve.EventStatus__c = 'Active';
                if((eve.StartDateTime <= Datetime.now()) && (eve.EndDateTime >= Datetime.now()))  
                    eve.EventStatus__c = 'Open';    
                if((eve.StartDateTime < Datetime.now()) && (eve.EndDateTime < Datetime.now()))  
                    eve.EventStatus__c = 'Completed';    
            }
            update eventRecord;
      }
}