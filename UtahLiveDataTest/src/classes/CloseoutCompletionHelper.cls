global with sharing class CloseoutCompletionHelper extends GNT.DynamicLayoutActionRedirect{ 
    public CloseoutCompletionHelper() {}
    List<String> errors = new List<String>(); 
    
    //global override PageReference whenClicked(){
    global override PageReference whenClicked(){
        List<BudgetPeriod__c> budgetPeriodList;
        List<BudgetPeriod__c> allBudgetPeriodList = new List<BudgetPeriod__c>();
        List<Award__c> allAwardList = new List<Award__c>();
        List<Grant__c> allGrantList = new List<Grant__c>();
        List<AmendmentRequest__c> amendmentList = new List<AmendmentRequest__c>();
        List<PaymentRequest__c> paymentList = new List<PaymentRequest__c>();
        List<FundingSource__c> fundingSrcList = new List<FundingSource__c>();
        List<ProgressReports__c> reportList = new List<ProgressReports__c>();
        String msg;
        Set<Id> awardIds = new Set<Id>();
        Set<Id> grantIds = new Set<Id>(); 
        Map<Id,Closeout__c> grantCloseOut = new Map<Id,Closeout__c>();
        Map<Id,Closeout__c> awardCloseOut = new Map<Id,Closeout__c>();
        Closeout__c tempCloseout;
        try{
                String recordId = apexpages.currentpage().getparameters().get('id');
                Closeout__c req = [Select Id, Name, Title__c, Award__c,Type__c, Grant__c,FOApprover__c,DueDate__c,DaysLeft__c, POApprover__c from Closeout__c where Id=:recordId limit 1];
                
                if(req.DaysLeft__c>0){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Closeout Request can be processed before the Due Date'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-54159')));
                return null;   
                }                

                awardIds.add(req.Award__c);
                grantIds.add(req.Grant__c);
                grantCloseOut.put(req.Grant__c, req);
                awardCloseOut.put(req.Award__c, req);
                budgetPeriodList = [Select id, Status__c, Grant__c, Grant__r.Name, Name from BudgetPeriod__c where Grant__c in :grantIds and Status__c <> 'Closed'];
                allAwardList = [Select id, Status__c, Grant__r.Name, Name from Award__c where id in :awardIds];
                allGrantList = [Select id, Status__c, Name from Grant__c where id in :grantIds];
                amendmentList = [Select id,Name, Grant__c, Grant__r.Name from AmendmentRequest__c where Grant__c in :grantIds and Status__c <> 'Accepted'];
                paymentList = [Select id,Name, Grant__c, Grant__r.Name from PaymentRequest__c where Grant__c in :grantIds and Status__c <> 'Approved by Program Manager'];
                fundingSrcList = [Select id, Status__c, Grant__c, Grant__r.Name, Name from FundingSource__c where Grant__c in :grantIds and Status__c <> 'Closed'];
                reportList = [Select id, Status__c, Grant__r.Name, Name from ProgressReports__c where Award__c in :awardIds];
                
                system.debug(LoggingLevel.ERROR,'**reportList--'+reportList);
                system.debug(LoggingLevel.ERROR,'**fundingSrcList--'+fundingSrcList);
                system.debug(LoggingLevel.ERROR,'**paymentList--'+paymentList);
                system.debug(LoggingLevel.ERROR,'**amendmentList--'+amendmentList);
                system.debug(LoggingLevel.ERROR,'**allAwardList--'+allAwardList);
                system.debug(LoggingLevel.ERROR,'**allGrantList--'+allGrantList);
/*
                for(ProgressReports__c temp:reportList){
                    tempCloseout=grantCloseOut.get(temp.Grant__c);
                    //tempCloseout.addError('There is a pending Amendment Request '+temp.Name+' for the Closeout Request '+tempCloseout.Name);
                      errors.add('There is a pending Progress Report '+temp.Name+' for the Closeout Request '+tempCloseout.Name+' and for the Grant '+temp.Grant__r.Name);
                }
                
                for(AmendmentRequest__c temp:amendmentList){
                    tempCloseout=grantCloseOut.get(temp.Grant__c);
                    //tempCloseout.addError('There is a pending Amendment Request '+temp.Name+' for the Closeout Request '+tempCloseout.Name);
                         errors.add('There is a pending Amendment Request '+temp.Name+' for the Closeout Request '+tempCloseout.Name+' and for the Grant '+temp.Grant__r.Name);
                 }
                for(PaymentRequest__c temp:paymentList){
                    tempCloseout=grantCloseOut.get(temp.Grant__c);
                   
                        errors.add('There is a pending Payment Request '+temp.Name+' for the Closeout Request '+tempCloseout.Name+' and for the Grant '+temp.Grant__r.Name);
                    }
                for(BudgetPeriod__c temp:budgetPeriodList){
                     tempCloseout=grantCloseOut.get(temp.Grant__c);
                        errors.add('Please Close the Budget Period '+temp.Name+' for the Closeout Request '+tempCloseout.Name+' and for the Grant '+temp.Grant__r.Name);
                     }
                
                 for(FundingSource__c temp:fundingSrcList){
                   tempCloseout=grantCloseOut.get(temp.Grant__c);
                         errors.add('Please Close the Funding Source '+temp.Name+' for the Closeout Request '+tempCloseout.Name+' and for the Grant '+temp.Grant__r.Name);
                   }*/
                
                  if(req.POApprover__c == null){
                      // errors.add(' Assign the Program Approver in the Roles and Responsibilities Section');
                      errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-90696'));
                  }
                    
             //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Closeout Request can be moved to next stage'));
             //   return null; 

              List<Grant__c> gtList = new List<Grant__c>();
              List<award__c> awList = new List<Award__c>();

              for(Award__c temp:allAwardList){
                tempCloseout=awardCloseOut.get(temp.Id);
                if(tempCloseout.Type__c=='Annual Closeout'){
                      temp.Status__c='Closed';             
                  }else if(tempCloseout.Type__c=='Grant Closeout'){
                      temp.Status__c='Closed';              
                   }else{
                      temp.Status__c='Terminated';              
                   }      
                awList.add(temp);      
                }
              
              for(Grant__c temp:allGrantList){
              tempCloseout=grantCloseOut.get(temp.Id);
              if(tempCloseout.Type__c=='Annual Closeout'){                         
                }
              else if(tempCloseout.Type__c=='Grant Closeout'){
                      temp.Status__c='Closed/Completed';          
              }else{
                      temp.Status__c='Terminated';              
              }
              gtList.add(temp);          
              }
               /* if(allBudgetPeriodList.size()>0){
                  update allBudgetPeriodList;
                }*/
              if(gtList.size() > 0){
                  update gtList;
                }
              if(awList.size()>0){
                  update awList;
                }
                   
              if(errors.size() > 0){
                    for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                    }
                 return null;
                }else{
                    req.Status__c='Completed';
                    update req;
                   // GNT.TaskCreationHandler.createApprovalProcessTasks(req.Id, 'Review the Closeout', req.Name, null, System.TODAY() + 7, req.Title__c, true);
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Closeout Request is Completed and Related Award/Grants are updated'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-04337')));
                    PageReference pf = Page.CloseoutRequestView;
                    pf.getParameters().put('id', req.Id);
                    pf.setRedirect(true);
                    return pf;
                }                    
             
        } catch(Exception e){
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in submitting closeout for approval'));  
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-20509'))); 
           system.debug(LoggingLevel.ERROR,e);      
            return null;
        }
    }
}