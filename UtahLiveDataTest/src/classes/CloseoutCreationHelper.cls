global with sharing class CloseoutCreationHelper extends GNT.FlexTableActionHandler{ 
     global CloseoutCreationHelper() {}
     Map<String,Object> resultMap = new Map<String,Object>();
     
     public override Map<String,Object> clickHandler(){
         Id recordId = urlParams.get('id');         
         List<Award__c> awardList = [Select Id, Name, Comptroller__c, GrantAdministrator__c from Award__c where Grant__c=:recordId and Status__c='Activated'];
         Grant__c grant = [Select TotalGrantAmount__c, CumulativeAwardedAmount__c from Grant__c where Id = :recordId];
         system.debug('**awardList '+awardList);
         if(awardList==null || awardList.size()==0){
               //resultMap.put('Message','No Active Award found');
               resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21745'));
               
               return resultMap;
         }
         if(grant.TotalGrantAmount__c != grant.CumulativeAwardedAmount__c){
                
            resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('P14-GRNTR-54124'));
               
               return resultMap;
         }
         else{              
                String PageReferenceURL = '/apex/'+'CloseoutRequestEdit?grantId=' + recordId;
                resultMap.put('PageReference',PageReferenceURL);
                return resultMap;
             }       
    }  
}