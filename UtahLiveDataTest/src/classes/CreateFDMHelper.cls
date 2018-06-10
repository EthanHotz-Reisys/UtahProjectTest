global with sharing class CreateFDMHelper extends GNT.DynamicLayoutActionRedirect {

   global override PageReference whenClicked(){ 
        Map<String,Object> resultMap = new Map<String,Object> ();
         
        Id reviewStepId = apexpages.currentpage().getparameters().get('id');
        String ns = AppUtils.getNamespacePrefix();
        List<String> errors = new List<String>();  
        String message;
        SavePoint sp = Database.setSavepoint();
        //try{
        ReviewStep__c reviewStep = [select ReviewGroup__c,ReviewGroup__r.Announcement__r.OwnerId,ReviewGroup__r.Announcement__c,ReviewGroup__r.currentReviewStep__c, StepNumber__c,SDDNotified__c, ReviewGroup__r.Announcement__r.Name, RecordType.Name, ReviewGroup__r.Announcement__r.Executive__c, DepartmentName__c, ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c 
                                    From ReviewStep__c 
                                    Where id = :reviewStepId];
        Id reviewGroupId = reviewStep.ReviewGroup__c;
        Id executiveApprover = reviewStep.ReviewGroup__r.Announcement__r.Executive__c;
        Id announcementOwner = reviewStep.ReviewGroup__r.Announcement__r.OwnerId;
        if(reviewStep.SDDNotified__c == false){
              Integer currentStep = Integer.valueOf(reviewStep.StepNumber__c);
              Integer nextStep = currentStep + 1;
              List<ReviewStep__c> nextReviewSteps = [SELECT Id,Name FROM ReviewStep__c WHERE StepNumber__c >=: nextStep 
                              AND ReviewGroup__c =: reviewStep.ReviewGroup__c Order by StepNumber__c LIMIT 1];
         if(nextReviewSteps.size() > 0){
              List<ReviewStepApplication__c> rsaList = [select id, Application__c, Decision__c,ReviewStatus__c,NumberOfReviews__c,MinimumAwardAmount__c,MaximumAwardAmount__c,RecommendedAmount__c,Application__r.MgmtRecAmount__c, ApplicationRank__c,TotalScore__c,ReviewStep__c, comments__c, OneStepReviewCompletionStatus__c  
                                                            From ReviewStepApplication__c 
                                                             where ReviewStep__c = :reviewStep.Id AND Decision__c != 'Rejected'];
              Set<Id> appIdSet = new Set<Id>();
              Set<Id> appIdInReview = new Set<Id>();
              for(ReviewStepApplication__c rsa : rsaList){
                  appIdSet.add(rsa.Application__c);
              }
              
          List<Review__c> lstReview = [Select Id, Application__c, OneStepReviewCompletionStatus__c From Review__c Where ReviewPanel__r.ReviewStep__c = : reviewStepId 
                                                AND Application__c IN :appIdSet ];                
          if (reviewStep.ReviewGroup__r.Announcement__r.Program__r.ReviewProcess__c == 'One step review') {
              updateOneStepReviewApplicationStatus(lstReview);
          }
          
          for(Review__c rev : lstReview){
                  appIdInReview.add(rev.Application__c);
                }
                system.debug('**appIdInReview**'+appIdInReview);
                system.debug('**appIdSet**'+appIdSet);
               /* if(appIdInReview.size() == 0 || appIdInReview.size() != appIdSet.size()){
                    //resultMap.put('Message','You can not create Funding Decision Memo, atleast one review should be completed for each Application.');
                    resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-30729'));
                   // return 'You can not Initiate Decision Document, atlease one review should be completed for each Application.';
                    return null;
                }*/
              /*  for(Id aId : appIdSet){
                    if(!appIdInReview.contains(aId)){
                        resultMap.put('Message','You can not create Funding Decision Memo, atleast one review should be completed for each Application.');
                          return null; 
                    }
                }*/
                // get the App id already added to next step
                boolean isPMdecisionPending = false;
                for(ReviewStepApplication__c rsa : rsaList){
                    if(rsa.ReviewStep__c == reviewStep.Id && rsa.Decision__c == 'Pending'){
                        isPMdecisionPending = true;
                        break;
                    }
                }
                system.debug('**isPMdecisionPending**'+isPMdecisionPending);
                if(!isPMdecisionPending){
                  List<GNT__PageTemplate__c> pgTemplateList = [Select Id, Name from GNT__PageTemplate__c where GNT__DisplayName__c='FundingDecisionMemoTemplate' limit 1];
                  ReviewStep__c nextRevStep = nextReviewSteps[0];
                  nextRevStep.Name = 'Funding Decision Memo';
                  nextRevStep.ExecutiveApprover__c=executiveApprover;
                  nextRevStep.announcementOwner__c = announcementOwner;
                  nextRevStep.ReviewStepLayout__c = pgTemplateList[0].Id;
                  system.debug('appIdSet: '+appIdSet);
                  update nextRevStep;
                  system.debug('FDM Review Step Completed: '+nextRevStep);
                  reviewStep.Status__c='Completed';
                  reviewStep.FDMCreated__c = 'Yes';
                  update reviewStep;
                  calculateRecommendedAmount(reviewStepId);
                  ReviewGroup__c reviewGroup = [Select Id from ReviewGroup__c where id =:reviewGroupId ];
                  reviewGroup.CurrentReviewStep__c=nextRevStep.name;
                  reviewGroup.CurrentReviewStepId__c=nextRevStep.Id;
                  update reviewGroup;
                    
                  List<ReviewStepApplication__c> newRsaList = new List<ReviewStepApplication__c>();
                  for(ReviewStepApplication__c rsa : rsaList){
                    ReviewStepApplication__c newRsa = new ReviewStepApplication__c();
                    newRsa.Application__c = rsa.Application__c;
                    newRsa.ReviewStep__c = nextRevStep.Id;
                    newRsa.ReviewStepName__c = 'Funding Decision Memo';
                    newRsa.Decision__c = rsa.Decision__c;
                    newRsa.TotalScore__c = rsa.TotalScore__c;
                    newRsa.NumberOfReviews__c = rsa.NumberOfReviews__c;
                    newRsa.ApplicationRank__c = rsa.ApplicationRank__c;
                    newRsa.DecidedBy__c = UserInfo.getUserId();
                    newRsa.DecidedOn__c = System.today();
                    newRsa.MinimumAwardAmount__c=rsa.MinimumAwardAmount__c;
                    newRsa.MaximumAwardAmount__c=rsa.MaximumAwardAmount__c;
                    //because recommended budget in management form is RecommendedBudget__c which is assigned to RecommendedAmount in RevAssSubHelper not MgmtRecAmount__c.
                    //newRsa.RecommendedAmount__c=rsa.Application__r.MgmtRecAmount__c;
                    newRsa.RecommendedAmount__c=rsa.RecommendedAmount__c;
                    newRsa.OneStepReviewCompletionStatus__c = rsa.OneStepReviewCompletionStatus__c;
                    newRsa.RecordTypeId=Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                    newRsa.comments__c = rsa.comments__c; 
                    newRsaList.add(newRsa);
                    }
                    system.debug('newrsaList0: '+newRsaList);
                    if(newRsaList.size() > 0){
                    insert newRsaList;
                    system.debug('newrsaList: '+newRsaList);
                    system.debug('FDM Review Step Application inserted: '+newRsaList);
                    PageReference page = new PageReference('/apex/'+ns+'ReviewStepView?id=' + nextRevStep.id);   
                    page.setRedirect(true); 
                    return page;                   
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-11163')));
                    return null;
                }
            }
            }else{
                //resultMap.put('Message','FDM has been created.');
                resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-58560'));
                message='FDM has been created.';                
            }
       
        message='FDM has been created.';
          return null;
    }

    public void calculateRecommendedAmount(Id revStepId){
         List<Review__c> revList = [Select Id, Name,Application__c,RecommendedBudget__c from Review__c where ReviewPanel__r.ReviewStep__c =:revStepId and 
                            Status__c='Review Completed' and Recommendation__c='Recommended'];

        Set<Id> appIds = new Set<Id>();
        for (Review__c rev : revList){
            appIds.add(rev.Application__c);
        }
        
        List<Application__c> appList = [Select Id, name, MgmtRecAmount__c from Application__c where Id IN : appIds];
        for(Application__c app : appList){
            Decimal totalAmount =0.0;
            Integer count =0;
            for (Review__c rev : revList){            
                if(rev.Application__c==app.Id){
                    totalAmount = totalAmount+rev.RecommendedBudget__c;
                    count = count +1;
                }
            }
            app.MgmtRecAmount__c=totalAmount/count;       
        }
        update appList;
    }

    
    public void updateOneStepReviewApplicationStatus(List<Review__c> lstReview) {
        List<Id> appIdList = new List<Id>();
        for (Review__c reviewIterator : lstReview) {
            appIdList.add(reviewIterator.Application__c);
        }
        List<Application__c> appList = new List<Application__c>([SELECT Id FROM Application__c WHERE Id IN: appIdList]);
        for (Review__c reviewIterator : lstReview) {
            for (Application__c appIterator : appList) {
                if (appIterator.Id == reviewIterator.Application__c && (reviewIterator.OneStepReviewCompletionStatus__c == 'Complete' || reviewIterator.OneStepReviewCompletionStatus__c == 'Incomplete')) {
                    appIterator.Status__c = 'Reviewed';
                }
                else if (appIterator.Id == reviewIterator.Application__c && reviewIterator.OneStepReviewCompletionStatus__c == 'Rejected') {
                    appIterator.Status__c = 'Rejected';
                }
            }
        }
        update appList;
    }

}