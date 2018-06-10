public with sharing class RecipientChildAccountEditCtrl {
    public ID recordId{get;set;}
    public String recordTypeId {get;set;}
     public ID userID {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public RecipientChildAccountEditCtrl(ApexPages.StandardController stdController){
        //Contact con = (Contact) stdController.getRecord();
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        pageTemplateName = 'RecipientChildAccount';
     
               
            system.debug('yyyyyy>>>'+ userID);
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
            userID = UserInfo.getUserId();
            system.debug('userID>>>'+ userID);
              if(!String.isEmpty(userID)){
                List<User> user = new List<User>([SELECT id ,AccountId FROM User WHERE Id =: userID]);
                List<Account> acc = new List<Account>([SELECT Id,EINText__c,DUNS__c,DUNSExpirationDate__c,ApplicantType__c FROM Account WHERE id =: user[0].AccountId]);
                //List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE RecordTypeId =: recordTypeId]);
               GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('ParentId', acc[0].Id, true);
               listDefaultValues.add(dv);
               GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('ParentId', acc[0].Id, true);
               listDefaultValues.add(dv1);
               GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('EINText__c', acc[0].EINText__c, true);
               listDefaultValues.add(dv2);
               GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper('DUNS__c', acc[0].DUNS__c, true);
               listDefaultValues.add(dv3);
               GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper('DUNSExpirationDate__c', acc[0].DUNSExpirationDate__c, true);
               listDefaultValues.add(dv4);
                GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper('ApplicantType__c', acc[0].ApplicantType__c, true);
               listDefaultValues.add(dv5);
               GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper('Status__c', 'Created', true);
               listDefaultValues.add(dv6);
               GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId(), true);
               listDefaultValues.add(dv7);
               
               savePage = Page.RecipientChildAccountView;
               savePage.getParameters().put('id',recordId);
              
               
             
               
            } 
            
           /* if(!String.isEmpty(recordTypeId)){
                List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE RecordTypeId =: recordTypeId]);
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AccountId', acc[0].Id, true);
                listDefaultValues.add(dv);
            } */
            //savePage = Page.SMEReviewerView; 
           /* savePage = Page.FlexTableView;
            savePage.getParameters().put('flexTableName', 'Additional User');
            cancelPage = Page.FlexTableView;
            cancelPage.getParameters().put('flexTableName', 'Additional User'); */
           /*  savePage = Page.AdditionalUserView;
             savePage.getParameters().put('id',recordId);
             cancelpage = Page.organizationview; */
           
        
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
       // keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('Id'));
        return JSON.serialize(keyValueMap);
    }

}