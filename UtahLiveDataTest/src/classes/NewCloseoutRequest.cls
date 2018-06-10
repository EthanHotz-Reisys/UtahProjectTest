global with sharing class NewCloseoutRequest extends GNT.FlexTableActionHandler{
    
        global override Map<String,Object> clickHandler(){
            Map<String,Object> resultMap = new Map<String,Object> ();
            String grantId = urlParams.get('id');
            String ns = AppUtils.getNamespacePrefix(); 
            SavePoint sp = Database.setSavepoint();
            RecordType recordType;
            Closeout__c newRequest;
            String PageReferenceURL;
            
            Award__c award;
            try{
                 recordType = [Select Id,DeveloperName from RecordType where DeveloperName ='Grantee' and sObjectType =: AppUtils.getNamespacePrefix()+'CloseoutRequest__c'];
                 award = [Select Id, Name, Comptroller__c, GrantAdministrator__c from Award__c where Grant__c=:grantId and Status__c='Activated'];
                 newRequest = new Closeout__c();
               //  newRequest.recordType=recordType.Id;                                 
                 newRequest.Grant__c=grantId;
                 newRequest.Award__c=award.Id;
                 newRequest.Status__c='Created';
                 //newRequest.Title__c='';
                 newRequest.POApprover__c=award.Comptroller__c;
                 newRequest.FOApprover__c=award.GrantAdministrator__c;
                 insert newRequest;
            }catch(Exception e){
                resultMap.put('Message',e.getMessage());    
                Database.rollBack(sp);
            }
            PageReferenceURL = '/apex/'+ns+'CloseoutRequestEdit?id='+newRequest.Id;
            resultMap.put('PageReference',PageReferenceURL);     
            return resultMap;
        }

}