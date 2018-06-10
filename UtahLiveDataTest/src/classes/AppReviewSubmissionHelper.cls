global with sharing class AppReviewSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
    public AppReviewSubmissionHelper() {}
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    
    public AppReviewSubmissionHelper(GNT.DynamicLayoutHolder layoutHolder) {
        this.layoutHolder = layoutHolder;
    }
    global override PageReference  whenClicked(){
          Savepoint sp = Database.setSavepoint();
          List<String> errors = new List<String>();   

        try{
             Id recordId = apexpages.currentpage().getparameters().get('id');
             Boolean approvalFlag=true;
             Decimal totalPercentage=0.0;
             Decimal totalRecommendedAmount=0.0;
            if(appName == 'StateAsGrantor'){
                ReviewStep__c reviewStep= [SELECT Id,Name,ExecutiveApprover__c, ReviewApprovalStatus__c,GrantCode__c,ReviewGroup__c, ReviewGroup__r.Announcement__c, OrganizationName__c FROM ReviewStep__c WHERE Id =: recordId LIMIT 1];
                 system.debug('inside AppReviewSubmissionHelper--reviewStep-'+reviewStep);
                List<ReviewStepApplication__c> rsaList = [Select Id,Application__r.Name,Decision__c, AmountThisAction__c,AllocationPercentage__c,RecommendedAmount__c,ReviewStep__r.OrganizationName__c from ReviewStepApplication__c where ReviewStep__c =: recordId and Decision__c!='Rejected'];
                system.debug('inside AppReviewSubmissionHelper--rsaList -'+rsaList );
                for(ReviewStepApplication__c rsa : rsaList){
                    if(rsa.RecommendedAmount__c!=null)
                    totalRecommendedAmount=totalRecommendedAmount+rsa.RecommendedAmount__c;
                    if(rsa.AllocationPercentage__c!=null)
                    totalPercentage=totalPercentage+rsa.AllocationPercentage__c;
                    if((rsa.AmountThisAction__c==null) || (rsa.AmountThisAction__c!=null && rsa.AmountThisAction__c<0.0)) {
                        approvalFlag=false;
                        break;
                    }
                    if(rsa.AllocationPercentage__c == null && rsa.ReviewStep__r.OrganizationName__c == 'UOVC'){
                        approvalFlag=false;
                        break;
                    }
                }                
                if(approvalFlag==false){
                     //errors.add('Please calculate Recommended Amount for all applications before submitting for approval.');
                     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-87206'));
                 }                  
                if(reviewStep.ExecutiveApprover__c == null){
                     //errors.add('Please add Executive Reviewer in associated Announcement before submitting for approval');
                     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-85819'));   
                }
                 if(reviewStep.ReviewApprovalStatus__c != 'Created' && reviewStep.ReviewApprovalStatus__c != 'Rejected'){
                     //errors.add('Funding Decision Memo can not be submitted for approval');
                     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-90540'));
                }
                if(reviewStep.GrantCode__c == null && reviewStep.OrganizationName__c.equals('UOVC')){
                     //errors.add('Please provide Grant Abbreviation');
                     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-38680'));
                 }
                if(totalPercentage>100){
                     //errors.add('Sum Total of allocation for all applications can not exceed 100%');
                     errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-46321'));
                 }
              
               if(errors.size() > 0){
                    for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                }
                }else{
                    Announcement__c announcement = [Select Id, Name,GrantCode__c  from Announcement__c where Id =: reviewStep.ReviewGroup__r.Announcement__c];
                    announcement.GrantCode__c=reviewStep.GrantCode__c;
                    update announcement;
                    if (reviewStep.OrganizationName__c.equals('UOVC')) {
                        GNT.TaskCreationHandler.createApprovalProcessTasks(reviewStep.Id, 'Approve FDM', reviewStep.Name, null, System.TODAY() + 7, reviewStep.Name, true); 
                    }
                    else {
                        reviewStep.Status__c = 'Approved';
                        reviewStep.ReviewApprovalStatus__c = 'Approved';
                        update reviewStep;
                    }
                    PageReference p = Page.ReviewStepView;
                    p.getParameters().put('id', reviewStep.Id);
                    p.setRedirect(true);
                return p;
                }             
                }
               return null;
        } catch(Exception e){        
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }        
    }
}