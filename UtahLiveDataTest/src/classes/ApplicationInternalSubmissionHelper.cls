global with sharing class ApplicationInternalSubmissionHelper extends GNT.DynamicLayoutActionRedirect {

    global override PageReference whenClicked() {
        Savepoint sp = Database.setSavePoint();
        Boolean HideSubmit = true;
        Boolean isError = false;
        Decimal match;
        Integer appCount, maxAppCount;
        try {
            Id recordId = layoutHolder.getPrimarySObject().Id;
            //List<Attachment> attachment = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId];
            Application__c app = [
                                     SELECT Id, Name, OwnerId, ProposalDescription__c, Announcement__r.Program__r.ProgramPathway__c, IndirectCostPicklist__c, Announcement__r.OrganizationName__c, Announcement__r.Program__r.AttachmentsRequired__c, TotalFederalMatch__c, Announcement__r.GranteeMatch__c, Announcement__r.MatchRequired__c, TotalCashMatch__c, TotalInKindMatch__c, TotalGrantCost__c , PrimaryApplicant__r.Id, Status__c, Announcement__r.DaysLeft__c, Announcement__r.Name , ExternalOrganization__c, ExternalOrganization__r.ApplicantType__c, Announcement__c, FormsValidated__c, Announcement__r.MaxApplicationsAllowed__c, Announcement__r.ApplicationsReviewStatus__c, NumberOfReviews__c, InitialRequestedAmount__c, RequestedAmount__c, AwardCeiling__c, AwardFloor__c, ProgramBudgetTypeUSBE__c, Approver__c, WaiveWithdraw__c, GrantorOrganizationName__c, BudgetNarrative__c, BudgetAllocation__c
                                     FROM Application__c
                                     WHERE Id = :recordId Limit 1];
            Announcement__c announcementObj = [
                                                  SELECT ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c
                                                  FROM Announcement__c
                                                  WHERE Id = :app.Announcement__c limit 1];
            DateTime d = DateTime.newInstance(announcementObj.ApplicationDeadlineWithDateTime__c.year(), announcementObj.ApplicationDeadlineWithDateTime__c.month(), announcementObj.ApplicationDeadlineWithDateTime__c.day(), announcementObj.ApplicationDeadlineWithDateTime__c.hour(), announcementObj.ApplicationDeadlineWithDateTime__c.minute(), announcementObj.ApplicationDeadlineWithDateTime__c.second());
            User u = [SELECT Contact.Account.IsExtensionAllowed__c FROM User WHERE Id = :UserInfo.getUserId()];


            if (app.Announcement__r.OrganizationName__c == 'USBE' && (app.ProposalDescription__c == null || app.ProposalDescription__c.length() == 0)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out the description field of the application before submitting'));
                isError = true;
            }

          /*  if (app.Announcement__r.Program__r.ProgramPathway__c == 'Fed-Formula' && app.GrantorOrganizationName__c == 'USBE') {
                if (app.ProposalDescription__c == null || app.ProposalDescription__c.length() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure you enter a description into the application '));
                    isError = true;
                }
            } */

            if (u.Contact.Account.IsExtensionAllowed__c == true && announcementObj.TimeExtensionAllowed__c == true) {
                if (d + Integer.valueOf(announcementObj.ExtensionDays__c ) > DateTime.parse(System.now().format())) {
                    HideSubmit = false;
                }
            } else {
                if (d > DateTime.parse(System.now().format())) {
                    HideSubmit = false;
                }
            }

            if (app.GrantorOrganizationName__c != 'USBE') {
                if (app.TotalGrantCost__c == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input the application budget in the Budget Tab '));
                    isError = true;
                } else {
                    match = (app.TotalCashMatch__c + app.TotalInKindMatch__c) / app.TotalGrantCost__c * 100;
                }
            } else {
                List<ApplicationBudgetCategory2__c> appBudgetCatList = new List<ApplicationBudgetCategory2__c>([
                            SELECT Id, BudgetCategory__c, BudgetCategory__r.RowNumber__c, BudgetAmountUSBE__c, AdminCostValue__c, ProjectBudgetPlusAdminCost__c
                            FROM ApplicationBudgetCategory2__c
                            WHERE Application__c = : recordId AND BudgetCategory__r.RowNumber__c >= '500' AND BudgetCategory__r.RowNumber__c < '600']);
                Decimal sumAdminCostValue = 0;
                Decimal sumTotalBudget = 0;
                Decimal sumTotalCTE = 0;
                for (ApplicationBudgetCategory2__c appBudgetCatIterator : appBudgetCatList) {
                    sumAdminCostValue += appBudgetCatIterator.AdminCostValue__c;
                    sumTotalBudget += appBudgetCatIterator.BudgetAmountUSBE__c;
                    sumTotalCTE += appBudgetCatIterator.ProjectBudgetPlusAdminCost__c;
                }
                if (app.ProgramBudgetTypeUSBE__c == 'CTE') {
                    if (sumTotalCTE == null || sumTotalCTE == 0) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input the application budget in the Budget Tab'));
                        isError = true;
                    }
                    if (sumAdminCostValue > (sumTotalCTE * 0.05)) { //Admin costs cannot be over 5% of the total budget
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Total Admin Costs cannot be over 5% of the total budget'));
                        isError = true;
                    }
                    if (sumTotalCTE != app.BudgetAllocation__c && app.Announcement__r.Program__r.ProgramPathway__c != 'State-Competitive'  && app.Announcement__r.Program__r.ProgramPathway__c != 'Fed-Competitive') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your total budget must equal your budget allocation.'));
                        isError = true;
                    }
                } else {
                    if (sumTotalBudget == null || sumTotalBudget == 0) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input the application budget in the Budget Tab'));
                        isError = true;
                    }
                    if (sumTotalBudget != app.BudgetAllocation__c  && app.Announcement__r.Program__r.ProgramPathway__c != 'State-Competitive'  && app.Announcement__r.Program__r.ProgramPathway__c != 'Fed-Competitive') {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Your total budget must equal your budget allocation.'));
                        isError = true;
                    }
                }
                if (app.BudgetNarrative__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Budget Narrative is required before submission'));
                    isError = true;
                }
            }

            if ( app.Announcement__r.OrganizationName__c.equalsIgnoreCase('USBE')) {
                String attachmentTypes = app.Announcement__r.Program__r.AttachmentsRequired__c;
                Id progId = app.Announcement__r.Program__r.id;
                if (attachmentTypes != null && !String.isEmpty(attachmentTypes)) {
                    String[] attachmentTypesList = attachmentTypes.split('\\;');
                    Integer countOfFiles = 0;
                    Map<String, Integer> attCount = new Map<String, Integer>();
                    for (Integer i = 0; i < attachmentTypesList.size(); i++) {
                        String s = attachmentTypesList[i].trim().tolowercase();
                        attachmentTypesList[i] = s;
                        attCount.put(s, 0);
                    }
                    //for(String att1 : attachmentTypesList)
                    //  attCount.put(att1,0);
                    System.debug('count1: ' + attCount);
                    List<GNT__AttachmentExtension__c> list1 = [Select GNT__Classification__c FROM GNT__AttachmentExtension__c where GNT__ParentId__c = :recordId];
                    String s1; Integer c = 0;
                    for (GNT__AttachmentExtension__c AttchExt : list1) {
                        System.debug('Test count' + AttchExt.GNT__Classification__c);
                        s1 = (String.valueOf(AttchExt.GNT__Classification__c)).trim().tolowercase();
                        System.debug('Count2 ' + s1 + ' ' + s1.equalsIgnoreCase('State form'));
                        if (attCount.containsKey(s1)) {
                            System.debug('Count2 ' + s1 );
                            countOfFiles = 1 + attCount.get(s1);
                            attCount.put(s1, countOfFiles);
                        }
                    }
                    System.debug('Map count:' + attCount);
                    for (String att2 : attachmentTypesList) {
                        countOfFiles = attCount.get(att2);
                        System.debug('Count3 ' + att2 + ' ' + countOfFiles);
                        if ((countOfFiles == 0 || countOfFiles == null)  && !att2.equalsIgnoreCase('other') ) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-56212') + ' ' + att2 + ' as ' + att2 + ' file type.'));
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Under the  attachments tab, attach atleast one, but not more than one file of type ' +att2));
                            isError = true;

                        }
                    }
                }
            }
            if (app.Approver__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An internal approver is required'));
                isError = true;
            } else {
                if (String.valueof(app.Approver__c).equalsIgnoreCase(String.valueOf((UserInfo.getUserId())))) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The internal approver cannot submit the application for approval.'));
                    isError = true;
                }
            } 



            /*Shivankar: Giving Application access to Approver*/
            Map<String, Map<String, Application__Share>> shareMap = new Map<String, Map<String, Application__Share>>();
            if (!shareMap.containsKey(app.id)) {
                shareMap.put((ID)app.id, new Map<String, Application__Share>());
            }

            List<Application__Share> currentShares = [SELECT ParentId, AccessLevel, UserOrGroupId FROM Application__Share WHERE ParentId = :app.Id];
            if (!currentShares.isEmpty()) {
                for (Application__Share ps : currentShares) {
                    if (shareMap.containsKey(ps.ParentId))
                        shareMap.get(ps.ParentId).put(ps.userOrGroupId, ps);
                }
            }
            Application__Share share;
            List<Application__Share> shares = new List<Application__Share>();
            if (app.Approver__c != null) {
                if (shareMap.get(app.id).containsKey(app.Approver__c)) {
                    //Updates the existing records to Edit if they are currently set to read
                    if (shareMap.get(app.id).get(app.Approver__c).AccessLevel == 'Read') {
                        shareMap.get(app.id).get(app.Approver__c).AccessLevel = 'Edit';
                        shares.add(shareMap.get(app.id).get(app.Approver__c));
                    }
                } else {
                    share = new Application__Share(parentId = app.id, AccessLevel = 'Edit', UserOrGroupId = app.Approver__c, RowCause = Schema.Application__Share.RowCause.SharetoReviewStepReviewers__c);
                    shares.add(share);
                    shareMap.get(app.id).put(app.Approver__c, share);
                }
            }
            if (shares.size() > 0) {
                System.debug('Upsert');
                SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                SystemContextMethodsHelper.upsertApplicationShare(Shares);
            }

            /*
            Set<String> attNames = new Set<String>();
            for(Attachment att : attachment) {
                String attachName = att.Name.replaceAll('\\s+','');
                attachName = attachName.substring(0, attachName.lastIndexOf('.'));
                attNames.add(attachName);
            }
            if(!attNames.contains('AGENCYBUDGET')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please Attach Agency Budget in the attachments section or if you have already attached it, rename it to "AGENCY BUDGET"'));
            }
              */
            if (HideSubmit) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21359')));
                isError = true;
            }
            if (app.IndirectCostPicklist__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Indirect Cost \'Yes\' or \'No\' in the Overview Tab'));
                isError = true;
            }
            if (app.Status__c == 'Revision Initiated') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-83111')));
                isError = true;
            }
            if (app.Status__c == 'Submitted to Grantor') {
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application is already submitted to Grantor'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-47065')));
                isError = true;
            }
            if (match != null && app.Announcement__r.MatchRequired__c == true && match.setScale(2) < app.Announcement__r.GranteeMatch__c && app.ExternalOrganization__r.ApplicantType__c != 'Non Profit Victim Services') {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that the value of ((Total Cash Match+Total In-Kind Match)*100/Grant including indirect cost) is greater than ' + app.Announcement__r.GranteeMatch__c + '%. The present cash match percentage is ' + match.setScale(2) + '%.'));
                isError = true;
            }
            if (app.Announcement__r.DaysLeft__c < 0) {
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application can not be submitted after the Due date.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21359')));
                isError = true;
            }
            /*
            if(app.Status__c!='Internally Reviewed'){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Atleast one Peer Review must be Completed'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-70037')));
                isError = true;
            }
            */

            //Devi Thangavelu - 4/13/2018 - To fix the Bug 21104, uncommented the FormsValidated code below
            if (!app.FormsValidated__c) {
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Forms needs to be validated before the application can be submitted.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61201')));
                isError = true;
            }
            /*
            if(app.TotalFederalMatch__c>app.AwardCeiling__c){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested Amount can not be greater than Award Ceiling Amount'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-65227')));
                isError = true;
            }
            */
            /*
            if(app.RequestedAmount__c<app.AwardFloor__c){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested Amount can not be less than Award Floor Amount'));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33051')));
               isError = true;
            }
            */
            /*
            if(app.NumberOfReviews__c<1)    {
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One Review is required for application to be submitted.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-01106')));
                //PageReference pf = Page.ApplicationView;
                //pf.getParameters().put('id', app.Id);
                //pf.setRedirect(true);
                isError = true;
            }
            */
            List<Application__c> appList = [Select Id, Name FROM Application__c WHERE Announcement__c = :app.Announcement__c AND ExternalOrganization__c = :app.ExternalOrganization__c AND Status__c NOT IN ('Created', 'Internally Reviewed', 'Snapshot')];
            if (appList != null &&  appList.size() > 0) {
                appCount = appList.size();
            } else {
                appCount = 0;
            }
            if (app.Announcement__r.MaxApplicationsAllowed__c != null && app.Announcement__r.MaxApplicationsAllowed__c > 0) {
                maxAppCount = (Integer)app.Announcement__r.MaxApplicationsAllowed__c;
            } else {
                maxAppCount = 1;
            }
            if (maxAppCount <= appCount) {
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application can not be submitted to Grantor as you have reached the maximum limit for allowed applications for '+app.Announcement__r.Name));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application can not be submitted to Grantor as you have reached the maximum limit for allowed applications for ' + app.Announcement__r.Name));
                isError = true;
            }

            if (isError == false) {
                //app.Status__c = 'Submitted to Grantor';
                app.Status__c = 'Submitted For Approval';
                app.SubmittedOn__c = System.Now();
                //app.InitialRequestedAmount__c=app.RequestedAmount__c;
                app.SubmittedBy__c = UserInfo.getUserId();
                if (app.WaiveWithdraw__c == null) { app.WaiveWithdraw__c = 'Not Applicable'; } //Done just in case the default value setting still isn't working
                update app;
                List<Task> taskList = [Select Id, Status, WhatId from Task where WhatId = :app.Id AND OwnerId = :UserInfo.getUserId()];
                if (taskList != null && taskList.size() > 0) {
                    for (Task task : taskList) {
                        task.Status = 'Completed';
                    }
                    update taskList;
                }
                /*
                if(app.Announcement__r.ApplicationsReviewStatus__c!='Not Started' && app.Announcement__r.ApplicationsReviewStatus__c!='Ready for Review'){
                    SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
                    helper.insertSingleApplicationToReview(app);
                }
                */
                //TaskCreationHandler.createApprovalProcessTasks(app.Id, 'Review Application Request', app.Name, null, System.TODAY() + 7,  true);
                GNT.TaskCreationHandler.createApprovalProcessTasks(app.Id, 'Internal Review Application Request', app.Name, null, System.TODAY() + 7, 'This application has been submitted for internal approval',  true);
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Application has been successfully submitted.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-81305')));
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-49018')));
                PageReference pf = Page.ApplicationView;
                pf.getParameters().put('id', app.Id);
                pf.setRedirect(true);
                return pf;
            } else {
                return null;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));
            return null;
        }
    }
}