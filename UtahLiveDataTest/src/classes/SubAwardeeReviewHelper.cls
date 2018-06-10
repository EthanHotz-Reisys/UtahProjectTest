global with sharing class SubAwardeeReviewHelper extends GNT.DynamicLayoutActionRedirect {
    global override PageReference whenClicked(){      
        String ns = AppUtils.getNamespacePrefix(); 
        List<String> errors = new List<String>();  
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Award__c award = [SELECT Id,Name,CreatedbyId,Status__c,Grant__r.GranteePOC__c,Grant__r.Id,GrantAwardName__c,
                          Grant__r.InternalOrganization__r.status__c, Grant__r.Program__r.AwardLetterRequired__c
                          FROM Award__c WHERE id =: recordId];
        if (award.Status__c == 'Approved'){
            if(award.Grant__r.InternalOrganization__r.status__c !='Debarred'){
                    award.Status__c = 'Sent to Grantee Review';
                    update award;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Sent to Sub-Awardee Review'));
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-82257')));
                    //GNT.TaskCreationHandler.createTasks(award.Grant__r.GranteePOC__c, recordId, 'Grantee POC Award Review',award.Name, null, false, System.TODAY() + 7, null, true); 
                    GNT.TaskCreationHandler.createTasks(award.Grant__r.GranteePOC__c, recordId, 'Grantee POC Award Review',award.Name, null, false, System.TODAY() + 7, null, award.GrantAwardName__c, true); 
                    system.debug('record id is ' +recordId + ' and GranteePOC is ' +award.Grant__r.GranteePOC__c);
                    //new GNT.EmailFeeder().TargetObjectID(award.Grant__r.GranteePOC__c).template('AwardReadyForApprovalSub').contextRecordId(recordId).send();
                    PageReference  returnPage = Page.AwardView;
                    returnPage.getParameters().put('Id', award.Id);
                    returnPage.setRedirect(true);
                    return returnPage;
            }else{
                  //errors.add ('The award cannot be sent for Grantee Review as for this Grantee Organization debarment process has been initiated');
                  errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-57029'));
            }
       
        }
        if (award.Status__c == 'Sent to Grantee Review'){
            if(award.Grant__r.InternalOrganization__r.status__c !='Debarred'){
                award.Status__c = 'Grantee Accepted';
                update award;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Award Accepted'));
                // Sai Teja - To change the status of the task to completed so it wont show up in sub recp pending tasks anymore; after he accepts the award.
                List<Task> taskList = [Select Id, Status, WhatId,lastModifieddate from Task where WhatId = :award.Id AND OwnerId=:award.Grant__r.GranteePOC__c AND Status='In Progress'];
                if(taskList!=null && taskList.size()>0){
                    for(Task task : taskList){
                        task.Status='Completed';
                    }
                    update taskList;
                }
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-12611')));
                //GNT.TaskCreationHandler.createTasks(award.CreatedbyId, recordId, 'Accepted Award Review',award.Name, null, false, System.TODAY() + 7, null, true);
                GNT.TaskCreationHandler.createTasks(award.CreatedbyId, recordId, 'Accepted Award Review',award.Name, null, false, System.TODAY() + 7, null, award.GrantAwardName__c, true);
                PageReference  returnPage = Page.AwardView;
                returnPage.getParameters().put('Id', award.Id);
                returnPage.setRedirect(true);
                return returnPage;
        }else{
            //errors.add ('The award cannot be accepted as for this Grantee Organization debarment process has been initiated');
            errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-88866'));
        }

        }
        if (award.Status__c == 'Grantee Accepted'){
        if(award.Grant__r.InternalOrganization__r.status__c !='Debarred'){
                award.Status__c = 'Activated';
                update award;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Award Activated'));
                system.debug('Grantee poc is '+award.Grant__r.GranteePOC__c);
                //new GNT.EmailFeeder().TargetObjectID(award.Grant__r.GranteePOC__c).template('AwardActivated').contextRecordId(recordId).send();
                if (award.Grant__r.Program__r.AwardLetterRequired__c == 'Yes') {
                    System.debug('AwardLetterRequired: ' + award.Grant__r.Program__r.AwardLetterRequired__c);
                    //new GNT.EmailFeeder().TargetObjectID(award.Grant__r.GranteePOC__c).template('AwardActivated').contextRecordId(recordId).send();
                }
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P26-GRNTR-12611')));  
                PageReference  returnPage = Page.AwardView;
                returnPage.getParameters().put('Id', award.Id);
                returnPage.setRedirect(true);
                return returnPage;
        }else{
                //errors.add ('The award cannot be activated as for this Grantee Organization debarment process has been initiated');
                errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-88866'));
        }

        }
        PageReference  returnPage = Page.AwardView;
        returnPage.getParameters().put('Id', award.Id);
        returnPage.setRedirect(true);
        return returnPage;
        
    }
}