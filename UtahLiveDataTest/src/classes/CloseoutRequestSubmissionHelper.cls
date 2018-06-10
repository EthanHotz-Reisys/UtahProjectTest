global with sharing class CloseoutRequestSubmissionHelper extends GNT.DynamicLayoutActionRedirect{ 
    public CloseoutRequestSubmissionHelper() {}
    List<String> errors = new List<String>(); 
    public CloseoutRequestSubmissionHelper(GNT.DynamicLayoutHolder layoutHolder) {
        this.layoutHolder = layoutHolder;
    }
    //global override PageReference whenClicked(){
    global override PageReference whenClicked(){

    	    system.debug('Inside CloseoutRequestSubmissionHelper '); 

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
                String recordId = layoutHolder.recordId;
                Closeout__c req = [Select Id, Name, Title__c, Award__c, Grant__c,FOApprover__c, POApprover__c from Closeout__c where Id=:recordId limit 1];
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
                
              /*  for(ProgressReports__c temp:reportList){
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
                           // errors.add(' Please assign the Program Approver in the Roles and Responsibilities Section');
                           errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-90696'));
                        }
                      if(req.FOApprover__c == null){
                           // errors.add(' Please assign the Fiscal Approver in the Roles and Responsibilities Section');
                           errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-55723'));
                        }
                   
                if(errors.size() > 0){
                    for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                    }
                 return null;
                 }else{
                    GNT.TaskCreationHandler.createApprovalProcessTasks(req.Id, 'Approve Closeout Request', req.Name, null, System.TODAY() + 7, req.Title__c, true);
                    // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Closeout has been successfully submitted for Approval'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83597')));
                    PageReference pf = Page.CloseoutRequestView;
                    pf.getParameters().put('id', req.Id);
                    pf.setRedirect(true);
                    return pf;
                }
                    
             
        } catch(Exception e){
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error in submitting closeout for approval'));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-20509')));  
           system.debug('error seen '+e);      
            return null;
        }
    }
}