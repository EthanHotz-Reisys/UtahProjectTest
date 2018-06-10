global with sharing class PromoteApplicationHelper1 extends GNT.FlexTableActionHandler{
    private Map<String,Object> resultMap;
    private Map<String,Object> errResultMap = new Map<String,Object>();
    global override Map<String,Object> clickHandler(){
        SavePoint sp = Database.setSavepoint();
        Boolean isError = false;
        Map<String,Object> resultMap = new Map<String,Object> ();
        Id reviewStepId = urlParams.get('id');
        //Id reviewStepId = apexpages.currentpage().getparameters().get('id');
        Boolean preventNotification = false;
        Boolean appsRejected = false;
        Boolean isPromoted = false;
        ID nextReviewStepId;
        List<ReviewStepApplication__c> rsaList = [select Id,IsOGMPromoted__c,ReviewStepAppFinalDecision__c,ReviewStatus__c,PreApplication__c,Application__c,IsAppPromoted__c,Decision__c,NumberOfReviews__c,MinimumAwardAmount__c,MaximumAwardAmount__c, TotalScore__c, NumberOfSMEReviews__c FROM ReviewStepApplication__c where ReviewStep__c =:reviewStepId and Id IN :selectedRecordIds];
        ReviewStep__c revStp = [Select id,OGMNotifiedOfRejections__c,NoofApplicationsPending__c,Status__c from ReviewStep__c where id=:reviewStepId limit 1];
        Boolean ogmMessage = false;
        if(rsaList.size() == 0){
            errResultMap.put('Message', 'Please select applications to promote to next step.');
            isError = true;
        }
        for(ReviewStepApplication__c rsa: rsaList){
            if(rsa.Decision__c == 'Pending'){
                preventNotification = true;
                break;
            }
            if(rsa.Decision__c == 'Rejected'){
                appsRejected = true;
                break;
            }
            if(rsa.IsAppPromoted__c == True){
                isPromoted = true;
            }
        }
        if(preventNotification == true){
            //errResultMap.put('Message','Decisions(Approved/Rejected) should be made on all the applications listed. Only Approved applications can be promoted.')
            errResultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-31006'));
            isError = true;
        }
        else if(isPromoted){
            errResultMap.put('Message', 'The selected application is already promoted to next step.');
            isError = true;
        }
        else if(revStp.Status__c=='Not Started'){
            errResultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-67990'));
            isError = true;
        }
        else if(revStp.Status__c=='Completed'){
            errResultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-07920'));
            isError = true;
        }
        else if(appsRejected){
            errResultMap.put('Message', 'Cannot promote the rejected applications.');
            isError = true;
        }
        if(isError){
            return errResultMap;
        }

        
        else if(preventNotification == false){
            try{
                Integer c = 0;
                Integer nextStep,prevStep;
                ReviewStep__c revStep = [Select RecordType.Name, RecordType.DeveloperName,NoofApplicationsPending__c,ReviewGroup__c,NoRemainingApps__c,StepNumber__c,OGMNotifiedOfRejections__c,ReviewGroup__r.Announcement__r.Name, Name From ReviewStep__c Where id = :reviewStepId];
                Integer currentStep = Integer.valueOf(revStep.StepNumber__c);
                if(c==0){
                    nextStep = currentStep+1;
                    if(currentStep!=1)
                        prevStep = currentStep-1;
                    c = c+1;
                }
                ReviewStep__c nextRevStep;
                ReviewStep__c prevRevStep;
                Set<Id> userIdSet = new Set<Id>();
                List<ReviewStep__c> prevReviewSteps = [SELECT Id,Name,Status__c,ReviewGroup__c FROM ReviewStep__c WHERE StepNumber__c = :prevStep AND ReviewGroup__c = :revStep.ReviewGroup__c Order by StepNumber__c LIMIT 1]; 
                List<ReviewStep__c> nextReviewSteps = [SELECT Id,Name,Status__c,ReviewGroup__c FROM ReviewStep__c WHERE StepNumber__c>= :nextStep AND ReviewGroup__c = :revStep.ReviewGroup__c Order by StepNumber__c LIMIT 1];
                List<ReviewStep__c> revStepList = [Select Id,ReviewersCount__c, CountReviewPanels__c,Name,Status__c, StepNumber__c from ReviewStep__c where id=:nextReviewSteps.get(0).Id limit 1];
                system.debug('---revStepList---'+revStepList);
                ReviewStep__c reviStep = revStepList[0];
                List<PanelApplication__c> panelAppList = new List<PanelApplication__c>();
                List<ReviewPanel__c> revPanelList= [Select Id, ReviewersCount__c,EndDate__c from ReviewPanel__c where ReviewStep__c = :nextReviewSteps.get(0).Id];
                List<ReviewStepApplication__c> rsappList = [Select Id, Name,Application__c from ReviewStepApplication__c where ReviewStep__c=:nextReviewSteps.get(0).Id ];
                List<ReviewStepApplication__c> promotedApplications = new List<ReviewStepApplication__c>();
                if(prevReviewSteps.size()>0)
                    prevRevStep = prevReviewSteps.get(0);
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
                    for(ReviewStepApplication__c rsApp : rsaList){
                        if(rsApp.Decision__c == 'Approved' && rsApp.IsOGMPromoted__c == false){
                            ReviewStepApplication__c promotedApp = new ReviewStepApplication__c();
                            if(revStep.RecordType.Name == 'Application'){
                                promotedApp.Application__c = rsApp.Application__c;
                                promotedApp.RecordTypeId=Schema.SobjectType.ReviewStepApplication__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
                                promotedApp.MinimumAwardAmount__c=rsApp.MinimumAwardAmount__c;
                                promotedApp.MaximumAwardAmount__c=rsApp.MaximumAwardAmount__c;
                            }
                            rsApp.IsAppPromoted__c = True;
                            //The below field is set to True when the revstepapp is promoted to next step or rejected. Refer PromoteApplicationHelper1 and ReviewRejectRedirectHelper classes.
                            rsApp.ReviewStepAppFinalDecision__c = True;
                            promotedApp.ReviewStep__c = nextReviewStepId;
                            
                            if (nextStep == 3) { //Done so that the average score field in the management review syncs correcly with the average SME score
                                promotedApp.TotalScore__c = rsApp.TotalScore__c;
                                promotedApp.NumberOfSMEReviews__c = rsApp.NumberOfReviews__c;
                                system.debug('****************Number of SME reviews'+ promotedApp.NumberOfSMEReviews__c + '      ' + rsApp.NumberOfReviews__c);
                            }
                            promotedApplications.add(promotedApp);
                        }
                    }
                    
                    if(promotedApplications!=null && promotedApplications.size()>0)
                        insert promotedApplications;
                    
                    update rsaList;
                    
                    revStep.OGMNotifiedOfRejections__c = true;
                    /*if(revStep.NoofApplicationsPending__c == 0){
                        revStep.Status__c='Completed';
                        system.debug('Review Step Status changed');
                    }*/
                    //Sai Yerubandi -- To change the Review Step Status according to batch approvals
                    ReviewStep__c revsStep = [Select RecordType.Name, RecordType.DeveloperName,NoofApplicationsPending__c,ReviewGroup__c,NoRemainingApps__c,StepNumber__c,OGMNotifiedOfRejections__c,ReviewGroup__r.Announcement__r.Name, Name From ReviewStep__c Where id = :reviewStepId]; 
                    system.debug('**************************No. of remaing apps is ' + revsStep.NoRemainingApps__c);
                    system.debug('**************************Current Step' + currentStep);
                    if(currentStep == 1 && revsStep.NoRemainingApps__c == 0){
                        revStep.Status__c='Completed';
                        system.debug('**************************Inside the loops');
                        update revStep;
                    }
                    else if(currentStep == 2  && revsStep.NoRemainingApps__c == 0 && prevRevStep.Status__c == 'Completed'){
                        revStep.Status__c='Completed';
                        update revStep;
                    }
                    
                    //Sai Yerubandi -- To add the promoted applications to the PanelApplication__c List of SME review since the Initiate button is disabled once initiated
                    /*if(nextRevStep.name == 'SME Review' && nextRevStep.Status__c == 'In Progress'){
                        for(ReviewStepApplication__c revStpApp : rsaList){
                            system.debug('revStepApp---'+revStpApp);
                            if(revStpApp.isAppPromoted__c == True){
                                for(ReviewPanel__c revPanel : revPanelList){
                                    system.debug('revPanel---'+revPanel);
                                    PanelApplication__c panelApp = new PanelApplication__c();
                                    panelApp.Application__c=revStpApp.Application__c;
                                    panelApp.ReviewPanel__c=revPanel.Id;
                                    panelAppList.add(panelApp);
                                    system.debug('inside of revcount loop');
                                }
                            }
                        }
                        system.debug('Out panelapplist size' +panelApplist.size() + 'what'+ panelApplist[0]);
                        insert panelAppList;
                        update revStep;
                        
                    }*/
                    /*if(reviStep.StepNumber__c != 3){
                        if(panelAppList!=null && panelAppList.size()>0){
                            insert panelAppList;
                            update revStep;
                            system.debug('---panelAppList---'+panelAppList);
                        }
                    }
                    else{
                        update reviStep;
                    }*/
                }
                /*if(nextReviewSteps.size() > 0){
                    nextReviewStepId = nextReviewSteps.get(0).Id;
                    List<ReviewStepApplication__c> promApps= [SELECT Id,TotalScore__c,NumberOfReviews__c from ReviewStepApplication__c where ReviewStep__c=:nextReviewStepId];
                    if(promApps!=null){
                        for(ReviewStepApplication__c rstepApp : rsaList){
                    		for(ReviewStepApplication__c promApp : promApps){
                            	if(nextStep == 3){
                                	promApp.TotalScore__c = rstepApp.TotalScore__c;
                                    promApp.NumberOfSMEReviews__c = rstepApp.NumberOfReviews__c;
                            	}
                    		}
                        update promApps;
                    }
                    }
                }*/
                
                
            }
            catch(Exception e){
                resultMap.put('Message',e.getMessage());
                Database.rollback(sp);
            }
        }
        
        if(preventNotification == false && appsRejected == false){
            errResultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-53478'));
            isError = true;
        }
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-78792')));
        PageReference pageref = Page.ReviewStepView;
        pageref.getParameters().put('id',nextReviewStepId);
        pageref.setRedirect(true);
        resultMap.put('PageReference', pageref);
        return resultMap;
    }

}