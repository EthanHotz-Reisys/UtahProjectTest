global with sharing class NegotiationCompletionHelper extends GNT.FlexTableActionHandler{
  global NegotiationCompletionHelper() {}
  Map<String,Object> resultMap = new Map<String,Object>(); 
    public override Map<String,Object> clickHandler(){
        Id applicationId = urlParams.get('id');
        system.debug('--applicationId --'+applicationId );
        Set<Id> appIds = new Set<Id>();         
        String ns = AppUtils.getNamespacePrefix();              
        List<Application__c> newAppList = new List<Application__c>();                   
        Savepoint sp = Database.setSavePoint();  
        try {       
            List<ChangeRequest__c> crList = [Select Id,Name,Status__c from ChangeRequest__c where Application__c=:applicationId];   
            if(crList!=null && crList.size()==0){
              //resultMap.put('Message','Negotiation can not be completed');
              resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-77646'));
              return resultMap;   
            }
            Integer count =0;
            for(ChangeRequest__c cr : crList){
              if(cr.Status__c!='Submitted' && cr.Status__c!='Deleted')
                count=count+1;
            }

            if(count>0){
              //resultMap.put('Message','Negotiation can not be marked completed with open negotiation requests');
              resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-49499'));
              return resultMap;               
            }
            List<Application__c> appList = [SELECT Id, Announcement__c, Status__c, Title__c 
                                            FROM Application__c WHERE Id =: applicationId ];                                            
            if(appList!=null && appList.size()>0){
            appList[0].Status__c='Revision Completed';
            appList[0].AwardDecisionStatus__c='Revision Completed ';
            newAppList.add(appList[0]);            
            }
            else
            {
              //resultMap.put('Message','Request can not be processed.');
              resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72128'));
              return resultMap;            
            }            
            if(newAppList.size()>0)
            { update newappList;     

            // Update Announcement, decrement negotiation in process, increment negotiation completed, increment awarded count
            Announcement__c ann = [Select Id, Name, ApplicationswithNegotiationCompleted__c,ApplicationsAwarded__c,ApplicationswithNegotiationInProcess__c from Announcement__c  where id =:appList[0].Announcement__c];
            if(ann.ApplicationswithNegotiationCompleted__c==null){
                ann.ApplicationswithNegotiationCompleted__c=1;
              }
              else{
                ann.ApplicationswithNegotiationCompleted__c=ann.ApplicationswithNegotiationCompleted__c+1;
              }
              ann.ApplicationswithNegotiationInProcess__c=ann.ApplicationswithNegotiationInProcess__c-1;
              update ann;
            }
        } catch(Exception e) {
            //resultMap.put('Message','Request can not be processed.');
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72128'));
            Database.rollBack(sp);               
        }
         PageReference p = Page.ApplicationView;
         p.getParameters().put('id', applicationId);
         p.setRedirect(true);
         resultMap.put('PageReference',p);         
         return resultMap;
    }
}