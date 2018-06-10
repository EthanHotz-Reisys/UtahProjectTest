global with sharing class USBELEACostRateTriggerHelper extends GNT.TriggerHelper{
    
    global static boolean skipTrigger = false;
    
    global override void processBeforeInsert(){
        if (skipTrigger != true){
            populateName(Trigger.new);
        }
    }
    global override void processAfterInsert(){
        //Trigger.new holds all the indirects that are being updated, so these are the only ones you care about
        //USBELEACostRate__c: Account__c (LEA), FiscalYear__c (Fiscal Year), RestrictedIndirectRate__c (Restricted %), UnrestrictedIndirectRate__c (Unrestricted %)
        if (skipTrigger != true){
            reviseBudgetForUpdatedIndirect((List<USBELEACostRate__c>) Trigger.new);
        }
    }
    global override void processAfterUpdate(){
        if (skipTrigger != true){
            reviseBudgetForUpdatedIndirect((List<USBELEACostRate__c>) Trigger.new);
        }
    }
    
    private void populateName(List<USBELEACostRate__c> costrates){
        String delims = '-+';
        for (USBELEACostRate__c costrate : costrates){
            String[] tokens = costrate.FiscalYear__c.split(delims);
            costrate.Name = tokens[1];
        }
    }
    
    private void reviseBudgetForUpdatedIndirect(List<USBELEACostRate__c> leaCostRateList) {
        Savepoint savestate = Database.setSavepoint();
        try {
            //Create a list of LEAs that are contained in the trigger list
            Map<Id, USBELEACostRate__c> leaMapIndirectObject = new Map<Id, USBELEACostRate__c>();
            List<Id> uploadFiscalYearIdlist = new List<Id>();
            for (USBELEACostRate__c usbeCostRateIterator : leaCostRateList) {
                uploadFiscalYearIdlist.add(usbeCostRateIterator.Year__c); //Check the fiscal year of the upload, 
                leaMapIndirectObject.put(usbeCostRateIterator.Account__c, usbeCostRateIterator);
            }
            List<FiscalYear__c> uploadFiscalYear = [SELECT Id, StartDate__c, EndDate__c FROM FiscalYear__c WHERE Id IN: uploadFiscalYearIdlist];
            System.debug('MANUALDEBUG >>> fiscalYears:' + uploadFiscalYear);
            System.debug('MANUALDEBUG >>> map LEA ID to cost rate obj: ' + leaMapIndirectObject);
    
            //Each upload for indirect change will be applied for the same fiscal year for them all. There will never be an upload for more than one fiscal year's indirect at a time
            //Find and store the list of whatever grants/awards that are active fiscal year we're doing the indirect cost update for where the LEA is in the list of LEAs
            //E.g. If it's currently the 2018 fiscal year and we're doing the upload for the 2019 fiscal year: DON'T check whatever grants are active for the 2018 fiscal year, DO check whatever grants are active during the 2019 fiscal year.    
            List<Award__c> awardList = 
                [SELECT Id, Name, GrantorOrganization__c, Grant__c, Grant__r.InternalOrganization__c, Grant__r.Program__c, Grant__r.Program__r.USBEIndirectCostRate__c, Grant__r.Program__r.StartDate__c, Grant__r.Program__r.EndDate__c, Grant__r.Program__r.ProgramPathway__c, Application__c, Application__r.IndirectCostPercentage__c, BudgetPeriodStartDates__c, BudgetPeriodEndDates__c, IndirectCostPercentage__c 
                FROM Award__c 
                WHERE GrantorOrganization__c = 'USBE' AND Status__c != 'Amended' AND Grant__r.Program__r.ProgramPathway__c IN('Fed-Formula', 'Fed-Competitive') AND Grant__r.InternalOrganization__c IN: leaMapIndirectObject.keySet() AND (Grant__r.Program__r.EndDate__c >: uploadFiscalYear[0].StartDate__c)]; 
            System.debug('MANUALDEBUG >>> awardListSize: ' + awardList.size());
            System.debug('MANUALDEBUG >>> awardList: ' + awardList);    
       
            List<User> leaUserList = [
                SELECT Id, Email, ProfileName__c, AccountId, ContactId 
                FROM User 
                WHERE AccountId IN: leaMapIndirectObject.keySet() AND (ProfileName__c = 'SPA' OR ProfileName__c = 'SPI')];
            Map<Id, List<User>> leaIdMapUserIdList = new Map<Id, List<User>>();
            Map<Id,User> userIdMapUserObj = new Map<Id,User>();
            for (User userIterator : leaUserList) {
                List<User> userList = leaIdMapUserIdList.get(userIterator.AccountId);
                if(userList == null){
                    userList = new List<User>();
                    leaIdMapUserIdList.put(userIterator.AccountId, userList);
                }
                userList.add(userIterator);
                userIdMapUserObj.put(userIterator.Id, userIterator);
            }
            System.debug('MANUALDEBUG >>> leaUserList: ' + leaUserList);    
            System.debug('MANUALDEBUG >>> leaIdMapUserIdList: ' + leaIdMapUserIdList); //Maps the LEA account Id to the list of Recipient Users who are associated with that LEA
            System.debug('MANUALDEBUG >>> userIdMapUserObj: ' + userIdMapUserObj);
    
            if (!awardList.isEmpty()) { //If there are awards that fit this criteria
                //If there are current LEA initiated budget revisions on those awards, reject them and reset the award so that the USBE budget revision takes precidence
                Set<String> revisionNotInProgressStatusList = new Set<String>{'Not Started', 'Change Requested', 'Rejected', 'Active'};
                List<Id> awardIdsList = new List<Id>();
                for (Award__c awardIterator : awardList) {
                    awardIdsList.add(awardIterator.Id);
                }
                //Find all AmendmentRequest__c whose Award__c are in the list of edited Awards and their Status__c is not in Active/Change Requested/Rejected/Revised
                List<AmendmentRequest__c> budgetRevisionList = [
                    SELECT Id, Award__r.BudgetRevisionInitiatedByUSBE__c, Status__c
                    FROM AmendmentRequest__c 
                    WHERE Award__c IN: awardIdsList AND Award__r.BudgetRevisionInitiatedByUSBE__c = 'Not Initiated By USBE' AND Status__c NOT IN: revisionNotInProgressStatusList];
                if (!budgetRevisionList.isEmpty()) {
                    //If any of the budget revisions are locked due to an approval process
                    List<AmendmentRequest__c> lockedBudgetRevisions = new List<AmendmentRequest__c>();
                    List<Id> budgetRevisionIdList = new List<Id>();
                    for (AmendmentRequest__c amendmentRequestIterator : budgetRevisionList) {
                        if(Approval.isLocked(amendmentRequestIterator)) {
                            lockedBudgetRevisions.add(amendmentRequestIterator);
                        }
                        budgetRevisionIdList.add(amendmentRequestIterator.Id);
                    }
                    if (lockedBudgetRevisions.size() > 0) { //If there are any who are locked, unlock them
                        Approval.UnlockResult[] unlockResultList = Approval.unlock(lockedBudgetRevisions, false);
                        for(Approval.UnlockResult unlockResultIterator : unlockResultList) { // Iterate through each returned result
                            if (unlockResultIterator.isSuccess()) { // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully unlocked record with ID: ' + unlockResultIterator.getId());
                            }
                            else { // Operation failed, so get all errors                       
                                for(Database.Error err : unlockResultIterator.getErrors()) {                 
                                    System.debug('Error has occured with: ' + err.getFields() + ' : ' + err.getStatusCode() + ' : ' + err.getMessage());
                                }
                            }
                        }   
                    }
                    //Get approval processes for those LEA budget revision records
                    List<ProcessInstanceWorkItem> approvalItemList = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId IN: budgetRevisionIdList AND ProcessInstance.Status = 'Pending'];
                    for (ProcessInstanceWorkItem approvalItem : approvalItemList) {
                        Approval.ProcessWorkItemRequest request = new Approval.ProcessWorkItemRequest();
                        request.setComments('Rejected Due Change In Indirect Rate');
                        request.setAction('Reject');
                        request.setWorkItemId(approvalItem.Id);
                        Approval.ProcessResult result = Approval.process(request);
                    }
                    //Get tasks for those LEA budget revision records
                    List<Task> taskList = [SELECT Id FROM Task WHERE WhatId IN: budgetRevisionIdList AND Status != 'Completed']; 
                    for (Task taskIterator : taskList) {
                        taskIterator.Status = 'Completed';
                    }
                    update taskList;
                    //The AmendmentRequestTriggerHelper automatically handles resetting the Award in preparation for a new budget revision
                    for (AmendmentRequest__c budgetRevisionIterator : budgetRevisionList) { //All records are unlocked and are available for modification
                        //Close all approval processes and tasks for those LEA budget revision records
                        budgetRevisionIterator.Status__c = 'Rejected'; //Set those LEA budget revisions as rejected. 
                    }
                    update budgetRevisionList; 
                }
                //Now that those LEA budget revisions are rejected, we can modify the awards to initiate the USBE budget revisions (continue with the workflow)
    
    
                //List<Task> budgetRevisionTaskList = new List<Task>();
                List<GNT.TaskCreationHandler.TaskBulkClass> tasksList = new List<GNT.TaskCreationHandler.TaskBulkClass>();
                /*INDIRECT ---------- */EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Award ready for subrecipient approval' LIMIT 1];
                //For each award/grant in the activeInUpcomingFiscalYear list       
                for (Award__c awardIterator : awardList) {
                    //Check which LEA the grant/awards are for
                    Id leaId = awardIterator.Grant__r.InternalOrganization__c;
                    //Get the list of users in said LEA
                    List<User> currentAwardLeaUserList = leaIdMapUserIdList.get(leaId);
                    List<String> mailTo = new List<String>();
                    Map<Id, String[]> recIdMapEmail = new Map<Id, String[]>();
                    Map<Id, Map<Id, String[]>> awardIdMapRecIdMapEmail = new Map<Id,Map<Id, String[]>>();
                    //Check the award/grant's program's indirect cost rate type (restricted or unrestricted)
                    String costRateType = awardIterator.Grant__r.Program__r.USBEIndirectCostRate__c;
                    System.debug('MANUALDEBUG >>> costRateType: ' + costRateType);
                    //Get the triggerList indirect object corresponding to the Award's LEA
                    USBELEACostRate__c costRateObjForLEA = leaMapIndirectObject.get(leaId);
                    //Pull the indirect cost % of the program's indirect cost rate type for the LEA
                    if (costRateType == 'Restricted') {
                        if (awardIterator.IndirectCostPercentage__c != costRateObjForLEA.RestrictedIndirectRate__c) { //If the uploaded indirect cost is different from the new one
                            //awardIterator.IndirectCostPercentage__c = costRateObjForLEA.RestrictedIndirectRate__c; //Update indirect                
                            awardIterator.IndirectCostPercentageProposed__c = costRateObjForLEA.RestrictedIndirectRate__c; //Update indirect  
                            awardIterator.BudgetRevisionInitiated__c = 'In Progress';//Automatically initiate revision for the awards
                            awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Indirect Change';
                            //Create task and email to the LEA to do the revision                        
                            for (User userIterator : currentAwardLeaUserList) {
                                //List<Task> budgetRevisionTask = GNT.TaskCreationHandler.createTasks(userIterator.Id, awardIterator.Id, 'Complete Budget Revision', awardIterator.Name, null, false, System.TODAY() + 7, 'Other', awardIterator.Name, false);
                                //budgetRevisionTaskList.addAll(budgetRevisionTask);
                                //mailTo.add(userIterator.Email);
                                GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                                task.ownerUserId = userIterator.Id;
                                task.recordId = awardIterator.Id;
                                task.action = 'Complete Budget Revision';
                                task.recordName = awardIterator.Name;
                                task.startDate = System.TODAY();
                                task.dueDate = System.TODAY() + 7;
                                task.subject ='Complete Budget Revision';                
                                tasksList.add(task);
                            }
                        }
                    }
                    else if (costRateType == 'Unrestricted') {
                        if (awardIterator.IndirectCostPercentage__c != costRateObjForLEA.UnrestrictedIndirectRate__c) {
                            //awardIterator.IndirectCostPercentage__c = costRateObjForLEA.UnrestrictedIndirectRate__c;
                            awardIterator.IndirectCostPercentageProposed__c = costRateObjForLEA.UnrestrictedIndirectRate__c;
                            awardIterator.BudgetRevisionInitiated__c = 'In Progress';
                            awardIterator.BudgetRevisionInitiatedByUSBE__c = 'Indirect Change';
                            awardIterator.CurrentRevisionStatus__c = 'Created';
                            //Create task and email to the LEA to do the revision
                            //Create task and email to the LEA to do the revision                        
                            for (User userIterator : currentAwardLeaUserList) {
                                //List<Task> budgetRevisionTask = GNT.TaskCreationHandler.createTasks(userIterator.Id, awardIterator.Id, 'Complete Budget Revision', awardIterator.Name, null, false, System.TODAY() + 7, 'Other', awardIterator.Name, false);
                                //budgetRevisionTaskList.addAll(budgetRevisionTask);
                                //mailTo.add(userIterator.Email);
                                GNT.TaskCreationHandler.TaskBulkClass task = new GNT.TaskCreationHandler.TaskBulkClass();
                                task.ownerUserId = userIterator.Id;
                                task.recordId = awardIterator.Id;
                                task.action = 'Complete Budget Revision';
                                task.recordName = awardIterator.Name;
                                task.startDate = System.TODAY();
                                task.dueDate = System.TODAY() + 7;
                                task.subject ='Complete Budget Revision';                 
                                tasksList.add(task);
                            }
                        }
                    }
                    //recIdMapEmail.put(awardIterator.Id, mailTo);
                    //awardIdMapRecIdMapEmail.put(awardIterator.Id, recIdMapEmail);
                    //Id currentContact = currentAwardLeaUserList[0].ContactId;//Dummy contact id used by the AppUtils method
                    //AppUtils.sendEmailUsingTemplate(emailTemplate.Id, awardIdMapRecIdMapEmail.get(awardIterator.Id), currentContact, false);
                    //System.debug('MANUALDEBUG >>> emailTemplateId, awardIdMapRecIdMapEmail, currentContactId: ' + emailTemplate.Id + ', ' + awardIdMapRecIdMapEmail.get(awardIterator.Id) + ', ' + currentContact);
                }
                if (!awardList.isEmpty()) { 
                    USBEAwardTriggerHelper.skipTrigger = true;
                    USBEAwardTriggerHelper.skipTriggers = true;
                    USBEAwardTriggerHelper.skipfromAmendment = true;
                    update awardList; 
                    USBEAwardTriggerHelper.skipTrigger = false;
                    USBEAwardTriggerHelper.skipTriggers = true;
                    USBEAwardTriggerHelper.skipfromAmendment = true;
                }
                if(tasksList.size() > 0){
                    List<Task> insertedTaskList = GNT.TaskCreationHandler.createBulkTasks(tasksList,true); 
                    
                    Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
                    for(Task taskIterator : insertedTaskList){
                        System.debug('MANUALDEBUG >>> taskIterator: ' + taskIterator);
                        List<String> toAddress = recIdToAddressMap.get(taskIterator.WhatId); 
                        if (toAddress == null) {
                            toAddress = new List<String>();
                            recIdToAddressMap.put(taskIterator.WhatId,toAddress);
                        }
                        User u = userIdMapUserObj.get(taskIterator.OwnerId);
                        toAddress.add(u.Email);
                        System.debug('MANUALDEBUG >>> toAddress: ' + toAddress);
                        recIdToAddressMap.put(taskIterator.WhatId,toAddress);
                    }
                    GNT.AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, leaUserList[0].ContactId, false);
                }
                //if (!budgetRevisionTaskList.isEmpty()) { insert budgetRevisionTaskList; } 
            }         
        }
        catch (Exception E) {
            Database.rollback(savestate);
            System.debug('ERROR: ' + e.getMessage());
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }                
    }
    
}