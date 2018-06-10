global with sharing class ReviseBudgetForAllocationChange extends GNT.DynamicLayoutActionRedirect{
    global override PageReference whenClicked() {
        Savepoint sp = Database.setSavePoint();
        Id awardId = layoutHolder.getPrimarySObject().Id;       
        
        try {
            Award__c currentAward = [
                SELECT Id, Name, Approver__c, AwardedAmount__c 
                FROM Award__c 
                WHERE Id =: awardId];
            if (currentAward.Approver__c != null) {
                //currentAward.CurrentAllocatedAmount__c = currentAward.AwardedAmount__c;
                currentAward.WaiveAllocationStatus__c = 'Sent For Internal Acceptance';
                USBEAwardTriggerHelper.skipTrigger = true;
                USBEAwardTriggerHelper.skipTriggers = true;
                update currentAward;
                USBEAwardTriggerHelper.skipTrigger = false;
                USBEAwardTriggerHelper.skipTriggers = false;
                
                //List<Task> taskList = [SELECT Id, Status, WhatId, GNT__TaskAction__c FROM Task WHERE WhatId =: awardId AND Status='In Progress' AND GNT__TaskAction__c = 'Accept Or Waive Allocation Amount'];
                List<Task> taskList = [SELECT Id, Status, WhatId, GNT__TaskAction__c FROM Task WHERE WhatId =: awardId AND GNT__TaskAction__c = 'Accept Or Waive Allocation Amount'];
                if(taskList != null && taskList.size()>0){
                    for(Task task: taskList){
                        task.Status='Completed';
                    }                   
                    update taskList;
                }
                
                //Create internal approval process task (which automatically has the email functionality in place)
                System.debug('Internal approval task creation');
                GNT.TaskCreationHandler.createApprovalProcessTasks(currentAward.Id, 'Accept Award Allocation Update Internal Approval', currentAward.Name, null, System.TODAY() + 7, currentAward.Name, true); 
                System.debug('***Task successfully sent ***');              
    
                //Redirect to the AwardView page
                PageReference pf = Page.ApproveRejectAwardAllocationChange;
                pf.getParameters().put('id', awardId);
                pf.setRedirect(true);
                return pf;
            }
            else {
                System.debug('You need to assign an internal approver to the award');
                return null;            
            }
        }
        /*
        try {
            //They have accepted the allocation change, so close the task that told them to do so or waive it
            //List<Task> taskList = [SELECT Id, Status, WhatId, GNT__TaskAction__c FROM Task WHERE WhatId =: awardId AND Status='In Progress' AND GNT__TaskAction__c = 'Accept Or Waive Allocation Amount'];
            List<Task> taskList = [SELECT Id, Status, WhatId, GNT__TaskAction__c FROM Task WHERE WhatId =: awardId AND GNT__TaskAction__c = 'Accept Or Waive Allocation Amount'];
            if(taskList != null && taskList.size()>0){
                for(Task task: taskList){
                    task.Status='Completed';
                }                   
                update taskList;
            }
            
            List<GrantContact__c> grantContactList = [
                SELECT Id, Award__c, Contact__c, Contact__r.UserReference__c, Contact__r.Email 
                FROM GrantContact__c
                WHERE Award__c =: awardId AND Contact__r.UserReference__c != null];
            System.debug('MANUALDEBUG >>> grantContactList: ' + grantContactList);
            List<Id> contactIdList = new List<Id>();
            Map<Id, Id> awardMapContact = new Map<Id, Id>();
            List<String> mailTo;
            Map<Id, String[]> recIdMapEmail;
            Map<Id, Map<Id, String[]>> awardIdMapRecIdMapEmail = new Map<Id,Map<Id, String[]>>();
            //Map<Id, Email> contactMapEmail = new Map<Id, Email>();
            System.debug('>>> ' + grantContactList.size());
            for (GrantContact__c grantContactIterator : grantContactList) {
                System.debug('MANUALDEBUG >>> ' + grantContactIterator.Contact__r.UserReference__c);
                System.debug('MANUALDEBUG >>> gcia: ' + grantContactIterator.Award__c + ' gci: ' + grantContactIterator.Contact__c);
                contactIdList.add(grantContactIterator.Contact__c);
                awardMapContact.put(grantContactIterator.Award__c, grantContactIterator.Contact__c); //Maps the AwardId to the ContactId
                //contactMapEmail.put(grantContactIterator.Contact__c, grantContactIterator.Contact__r.Email);
                mailTo = new List<String>();
                mailTo.add(grantContactIterator.Contact__r.Email);
                recIdMapEmail = new Map<Id, String[]>();
                recIdMapEmail.put(grantContactIterator.Award__c, mailTo);
                awardIdMapRecIdMapEmail.put(grantContactIterator.Award__c, recIdMapEmail);
            }
            System.debug('MANUALDEBUG >>> awardMapContact: ' + awardMapContact + ' size ' + awardMapContact.size());
            
            //List<Contact> contactList = [SELECT Id, UserReference__c, OwnerId FROM Contact WHERE Id IN: contactIdList];
            List<User> userList = [
                SELECT Id, ContactId 
                FROM User 
                WHERE ContactId IN: contactIdList];
            Map<Id, Id> contactMapUser = new Map<Id, Id>(); //Map User to Contact
            for (User userIterator : userList) {
                contactMapUser.put(userIterator.ContactId, userIterator.Id);
            }
            System.debug('MANUALDEBUG >>> contactMapUser: ' + contactMapUser);
            
           
            List<Task> budgetRevisionTaskList = new List<Task>();
            EmailTemplate emailTemplate = [
                SELECT Id, Name 
                FROM EmailTemplate 
                WHERE Name = 'Award ready for subrecipient approval' LIMIT 1];
            
            Award__c currentAward = [SELECT Id FROM Award__c WHERE Id =: awardId];
            currentAward.BudgetRevisionInitiated__c = 'In Progress';//Automatically initiate revision for the awards
            currentAward.BudgetRevisionInitiatedByUSBE__c = 'Allocation Change';
            currentAward.CurrentRevisionStatus__c = 'Created';
            //Create task and email to modify the budget
            for (GrantContact__c grantContactIterator : grantContactList) {
                List<Task> budgetRevisionTask = GNT.TaskCreationHandler.createTasks(contactMapUser.get(awardMapContact.get(currentAward.Id)), currentAward.Id, 'Complete Budget Revision', currentAward.Name, null, false, System.TODAY() + 7, 'Other', currentAward.Name, false);
                System.debug('MANUALDEBUG >>> budgetRevisionTask: ' + budgetRevisionTask);
                System.debug('MANUALDEBUG >>> ' + contactMapUser.get(awardMapContact.get(currentAward.Id)));
                budgetRevisionTaskList.addAll(budgetRevisionTask);
                
                Id currentContact = awardMapContact.get(currentAward.Id);
                AppUtils.sendEmailUsingTemplate(emailTemplate.Id, awardIdMapRecIdMapEmail.get(currentAward.Id), currentContact, false);
                System.debug('MANUALDEBUG >>> emailTemplateId, awardIdMapRecIdMapEmail, currentContactId: ' + emailTemplate.Id + ', ' + awardIdMapRecIdMapEmail.get(currentAward.Id) + ', ' + currentContact);                          
            }
            if (!budgetRevisionTaskList.isEmpty()) { insert budgetRevisionTaskList; } //Creates tasks for the grant contacts
            USBEAwardTriggerHelper.skipTrigger = true;
            USBEAwardTriggerHelper.skipTriggers = true;
            update currentAward;
            USBEAwardTriggerHelper.skipTrigger = false;
            USBEAwardTriggerHelper.skipTriggers = false;
            
            //Redirect to the award view page
            PageReference pf = Page.AwardView;
            pf.getParameters().put('id', awardId);
            pf.setRedirect(true);
            return pf;
        }
        */
        catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage())); 
            return null;
        }
    }
}