global with sharing class PromoteApplicationHelper extends GNT.DynamicLayoutActionRedirect {
    
    global override PageReference whenClicked(){
        SavePoint sp = Database.setSavepoint();
        Map<String,Object> resultMap = new Map<String,Object> ();      
        Id reviewStepId = apexpages.currentpage().getparameters().get('id');
        Boolean preventNotification = false;
        Boolean appsRejected = false;
        Id nextReviewStepId;
        List<ReviewStepApplication__c> rsaList = [select Id,IsOGMPromoted__c,ReviewStatus__c,PreApplication__c,Application__c,IsAppPromoted__c,Decision__c,MinimumAwardAmount__c,MaximumAwardAmount__c FROM ReviewStepApplication__c where ReviewStep__c =: reviewStepId];
        ReviewStep__c revStp = [Select id,OGMNotifiedOfRejections__c,NoofApplicationsPending__c,Status__c from ReviewStep__c where id =: reviewStepId limit 1];
        Boolean ogmMessage = false;
        system.debug('RSA LIST ' +rsaList.size());      
        for(ReviewStepApplication__c rsa: rsaList) {
        system.debug('rsa is ' +rsa.id);
            /*if(rsa.Decision__c == 'Pending') {
                preventNotification = true;
                break;    
            }*/
            if(rsa.IsAppPromoted__c == True){
            preventNotification = true;
            }
            if(rsa.Decision__c == 'Rejected') {
                appsRejected = true;
            }
        }
        if(preventNotification == true ) {
           //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Decisions(Approved/Rejected) should be made on all the applications listed!!'));
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-31006')));
       
        }
        else if(revStp.Status__c =='Not Started') {
          //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Applications can not be promoted now!'));
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-67990')));
           
        }
        else if(revStp.Status__c =='Completed') {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Applications have already been promoted to Next Step!'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-07920')));
        }
        
        else if(preventNotification == false) {
           try{
                ReviewStep__c revStep = [select RecordType.Name, RecordType.DeveloperName,NoofApplicationsPending__c,ReviewGroup__c,StepNumber__c,OGMNotifiedOfRejections__c,ReviewGroup__r.Announcement__r.Name, Name From ReviewStep__c Where id = :reviewStepId ];
                Integer currentStep = Integer.valueOf(revStep.StepNumber__c);
                Integer nextStep = currentStep + 1;
                system.debug('nexTStep is*****' + nextStep);
                ReviewStep__c nextRevStep;
                
                Set<Id> userIdSet = new Set<Id>();
                List<ReviewStep__c> nextReviewSteps = [SELECT Id,Name,ReviewGroup__c FROM ReviewStep__c 
                                                        WHERE StepNumber__c >=: nextStep 
                                                        AND ReviewGroup__c =: revStep.ReviewGroup__c 
                                                        Order by StepNumber__c LIMIT 1 ];
                system.debug('-- debugging 16 -nextReviewSteps--'+nextReviewSteps);                                                        
                    
                List<ReviewStepApplication__c> promotedApplications = new List<ReviewStepApplication__c>();
                if(nextReviewSteps.size() > 0){
                        nextReviewStepId = nextReviewSteps.get(0).Id;
                        nextRevStep=nextReviewSteps.get(0);
                        ReviewGroup__c reviewGroup = [Select Id, Announcement__c from ReviewGroup__c where id =:nextRevStep.ReviewGroup__c ];
                        reviewGroup.CurrentReviewStep__c=nextRevStep.name;
                        reviewGroup.CurrentReviewStepId__c=nextRevStep.Id;
                        update reviewGroup;                        
                        Announcement__c announcement = [Select Id from Announcement__c where id =:reviewGroup.Announcement__c ];
                        announcement.CurrentReviewStep__c=nextRevStep.name;
                        update announcement;
                        for(ReviewStepApplication__c rsApp : rsaList) {
                             if(rsApp.Decision__c == 'Approved' && rsApp.IsOGMPromoted__c == false) {
                                ReviewStepApplication__c promotedApp = new ReviewStepApplication__c();
                                if(revStep.RecordType.Name == 'Application'){
                                    promotedApp.Application__c = rsApp.Application__c;   
                                    promotedApp.RecordTypeId=Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                                    promotedApp.MinimumAwardAmount__c=rsApp.MinimumAwardAmount__c;
                                    promotedApp.MaximumAwardAmount__c=rsApp.MaximumAwardAmount__c;
                                }
                                rsApp.IsAppPromoted__c = True;
                                promotedApp.ReviewStep__c = nextReviewStepId;
                                promotedApplications.add(promotedApp);    
                            }                        
                        }   
                    if(promotedApplications!=null && promotedApplications.size()>0)
                    insert promotedApplications;
                    update rsaList;   
                    revStep.OGMNotifiedOfRejections__c = true;
                    if(revStep.NoofApplicationsPending__c == 0){
                    revStep.Status__c='Completed';
                    }
                    update revStep;
                 }
             }catch(Exception e){
                resultMap.put('Message',e.getMessage()); Database.rollBack(sp);
            }
        }
          if(preventNotification == false && appsRejected == false) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-53478')));
      
        }   
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-78792')));
            PageReference  pageref = Page.ReviewStepView;
            pageref.getParameters().put('id',nextReviewStepId);
            pageref.setRedirect(true);
            return pageref; 
      

    }
}