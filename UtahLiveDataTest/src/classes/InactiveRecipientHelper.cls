global with sharing class InactiveRecipientHelper extends GNT.DynamicLayoutActionRedirect { 
global override PageReference whenClicked(){ 

         Savepoint sp = Database.setSavePoint();
          try{
             Id recordId = apexpages.currentpage().getparameters().get('id');
             Account acc = [Select Id,Name,status__c,ReasonsForDebarment__c,InitiateDebarmentProcess__c from account
             where id =:recordId Limit 1];
             if(acc.status__c == 'Debarred'){
             List<Award__c> awardList =  [Select Id,Name,status__c ,grant__r.InternalOrganization__r.name from Award__c where grant__r.InternalOrganization__c =:recordId];
             Set<Id> awardIds = new Set<Id>();
             for(Award__c award : awardList){
                awardIds.add(award.Id);      
              
             }             
             List<PaymentRequest__c> listPr = [Select Id,Name,status__c, Award__c,award__r.grant__r.InternalOrganization__r.status__c  from PaymentRequest__c where Award__c in : awardIds]; 
             Map<Id,List<PaymentRequest__c>> mapPr = new  Map<Id,List<PaymentRequest__c>>();
            
             for (PaymentRequest__c pr : listPr) {
                List<Paymentrequest__c> listPreq = mapPr.get(pr.Award__c);
                if (listPreq == null) {
                    listPreq = new List<Paymentrequest__c>();
                    mapPr.put(pr.Award__c, listPreq);
                }
                listPreq.add(pr);
            }
            integer isAllPaymentRequestsComplete = 0 ;

              //system.debug('--Inside ApplicationSubmissionHelper--'+app);
             for(award__c award :awardList){
             if (award.status__c == 'Activated' || award.status__c == 'Amended'){
                // acc.addError('Recipeint cannot be dicativated as it has one or more active awards');
                acc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-77406'));
             } 
             else if (award.status__c == 'Closed'){
                 List<PaymentRequest__c> listPayReq = mapPr.get(award.Id);
                 Set<String> s1 = new Set<String>();
                 for(PaymentRequest__c payreq :listPayReq){
                 s1.add(payreq.status__c);
                 }
              for (string s :s1){
                  if(s != 'Paid')
                  {
                  isAllPaymentRequestsComplete  = isAllPaymentRequestsComplete + 1;
                 }
              }
                /* for(PaymentRequest__c payreq :listPayReq){
                     if (payreq.Status__c != 'Paid'){
                        isAllPaymentRequestsComplete = true;                        
                     }else
                     {
                       acc.addError('Recipeint cannot be dicativated as it has pending PayReq');
                     }
                 } */
               
            }
           } 
                if (isAllPaymentRequestsComplete == 0) {
                    acc.status__c = 'Inactive';   
                    update acc;
                }  else {
                   // acc.addError('Recipeint cannot be diactivated as it has pending PayReq');
                   acc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-34102'));
                } 
                return null;    
         } else {
              // acc.addError('Recipeint cannot be diactivated as it is not debarred');
              acc.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-51831'));
              return null;
         }
            }
          catch(Exception ex){
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
            return null;
          }
        
}
}