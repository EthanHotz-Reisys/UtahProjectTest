/*
    This is a helper class for the Application Trigger

    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2014-03-04  Vinayak Sharma      Created
    2014-04-23  Hafsa Syed          Added incrementTotalApplications method
    2014-04-24  Manasi Gangal       Added method updateSubmittedtoInternalCheckbox for update context only.
    2014-04-23  Hafsa Syed          Updated incrementTotalApplications method and Added decrementTotalApplications method
    2014-05-13  Hafsa Syed          Added populateExternalOrg method
    2014-05-13  Kunal Shah          Added createAward method
    2014-05-14  Ryan Chadwick       Added submitted by method
    2014-05-15  Vani Valluru        Added UpdateAppTemplName method and Added SetAppTemplName
    2015-01-14  William Moore       Added handleNewRequestStatus and handleApplicationRequest methods
    2015-08-03  Shrawan Raina       Modified updateExternalOrgLookup, checkAnnouncementDeadline to handle null conditions
    **********************************************************************************************************************
*/

global with sharing class ApplicationTriggerHelper extends GNT.TriggerHelper {

    private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
    List<RolesAndResponsibilities__c> lstRolesAndResponsibilities = new List<RolesAndResponsibilities__c>();
    global static boolean skipTrigger = false;

    public override void processBeforeInsert() {
        GNT.NameTemplateTriggerHelper.beforeInsert();
        if (skipTrigger == false) {
            updateIndirectPercentage(Trigger.New);
            updateAssignedTo();
            populateExternalOrg(Trigger.New);
            UpdateAppTemplName(Trigger.New);   // Not used to the Grantee Side Davinder Delete it this is not required
            updateExternalOrgLookup();
            updateHideForm(Trigger.New);
            shareWithInternalUsers(Trigger.new);
            System.debug('AppName is ' + appName);
            if (appName == 'StateasGrantee') {
                updatePreApplication();
            }


            if (appName != 'StateasGrantee') {
                copyPrimarySecondaryDetails(Trigger.New);
            }
            List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'Application__c'
                                               and Name = 'Grantee'];
            if (appName != null && appName == 'StateasGrantee') {
                for (Application__c app : (List<Application__c>) Trigger.New) {
                    if (!recordTypeList.isEmpty()) {
                        app.recordTypeId = recordTypeList[0].Id;
                    }
                }
            }

            //If application's grantor is USBE, automatically pull in the LEA's indirect cost for this fiscal year from their vendor profile
            Map<Id, Application__c> triggerMap = new Map<Id, Application__c>();
            List<Application__c> triggerList = new List<Application__c>();
            for (Application__c appIterator : (List<Application__c>) Trigger.new) {
                if (appIterator.GrantorOrganizationName__c == 'USBE') {
                    triggerMap.put(appIterator.Id, appIterator);
                    triggerList.add(appIterator);

                    if (appIterator.WaiveWithdraw__c == null) { appIterator.WaiveWithdraw__c = 'Not Applicable'; }
                }
            }
            if (!triggerList.isEmpty() && triggerList != null) {
                pullIndirectCostFromVendorProfile(triggerMap, triggerList);
                //pullIndirectCostFromVendorProfile(triggerMap, (List<Application__c>) Trigger.new);
                pullBAFromLEAProfile(triggerList);
            }
        }
    }

    public override void processAfterInsert() {
        shareToExternalUser();
        //TODO: temporarily commenting out the logic as we should build UI for owner to perform manual share
        if (!skipTrigger) {
            //UpdateExtOrgNoofApplications(Trigger.new);ss
            // Pankaj : as exeternal user we have recipent as name.
            //incrementTotalApplications(Trigger.New, (Map<Id,Application__c>)Trigger.oldMap);
            if (appName == 'StateasGrantee') {
                insertOwnerinRolesandResp();
                addDefaultFundingOppServiceArea();
                createBudPeriodProjAreaBudCat(Trigger.New);
                populateAnnouncementRolesAndResponsiblities(Trigger.new);  // If the Default Roles and Repsonsibilities from the Program if Ex
                updateGranteeAnnouncement(Trigger.new);     // Update the Announcement Status
                createTasks(Trigger.new);
                updatePreApplication(Trigger.new);
            } else {
                system.debug('--processAfterInsert-after insert-');
                createBudPeriodProjAreaBudCatGrantor(Trigger.New);
                copyBudgetDataFromPreApplication(Trigger.New);
            }

            //   createApplicationBudgetCategories(Trigger.New);
            if (appName != 'StateasGrantee') {
                updateQualifiedOpportunity(Trigger.New);
            }
            addRolesandResponsibilities(Trigger.New);
            //budgetUploadApplicationEmailTask((List<Application__c>) Trigger.new);
        }
    }

    public override void processBeforeUpdate() {
        //disallowOwnerToUpdateAfterSubmission();
        //Method checks if it is an internal user or an external user
        if (!skipTrigger) {
            updateIndirectPercentage(Trigger.New);
            shareWithInternalUsers(Trigger.new);
            checkProfile((Map<Id, Application__c>)Trigger.oldMap, Trigger.New);
            updateSubmittedBy();
            UpdateAppTemplName(Trigger.New);  // Not used to the Grantee Side Davinder Delete it this is not required
            handleApplicationRequestStatus();
            updateExternalOrgLookup();
            updateHideForm(Trigger.New);
            checkAnnouncementDeadline(Trigger.New);
            updateApplicationStatusOnApproval();
            IncrementApplicationUpdationCount(Trigger.New);
            //incrementTotalApplications(Trigger.New, (Map<Id,Application__c>)Trigger.oldMap);

        }
        incrementTotalApplications(Trigger.New, (Map<Id, Application__c>)Trigger.oldMap);
    }

    public override void processAfterUpdate() {
        if (!skipTrigger) {
            //UpdateExtOrgNoofApplications(Trigger.new);
            //shareWithInternalUsers(Trigger.new);
            if (appName != 'StateasGrantee') {
                //addSharingSettings((Map<Id,Application__c>)Trigger.newMap,(Map<Id,Application__c>)Trigger.oldMap);
                createAwardTask((Map<Id, Application__c>)Trigger.newMap, (Map<Id, Application__c>)Trigger.oldMap);
                sendSubmissionEmail();
                handleApprovedRequestStatus();
                updateApplicationCount();
                handleNewRequestStatus();
                updateAllBudgetCategories((List<Application__c>) Trigger.new, (List<Application__c>) Trigger.old);
            }
            if (appName == 'StateasGrantee') {
                UpdateFOAValues(trigger.new);
            }
            deleteTasksForReviewers((List<Application__c>) Trigger.new);
            notifyGrantorWaiveWithdraw((List<Application__c>) Trigger.old, (List<Application__c>) Trigger.new);
        }
    }

    public override void processBeforeDelete() {
        if (!skipTrigger) {
            //UpdateExtOrgNoofApplications(Trigger.old);
            decrementTotalApplications(Trigger.Old);
        }
    }

    public override void processAfterDelete() {
        if (!skipTrigger) {
            decrementApplicationCount();
        }
    }


    private void updateIndirectPercentage(List<Application__c> appList) {
        for (Application__c app : appList) {
            if (app.IndirectCostPicklist__c != 'Yes') {
                app.IndirectCostPercentage__c = 0;
            }
        }
    }

    private void insertOwnerinRolesandResp() {
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        String AppRecordtype;
        if (appName == 'StateasGrantee') {
            AppRecordtype = 'Application';
        } else if (appName == 'StateasGrantor') {
            AppRecordtype = 'GrantorApplication';
        }
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'RolesAndResponsibilities__c' and DeveloperName = :AppRecordtype];
        for (Application__c app : (List<Application__c>) Trigger.New) {

            rresp.Application__c = app.id;
            rresp.Name__c = app.ownerid;
            //rresp.Role__c = 'Other';
            rresp.BusinessRole__c = 'Owner';
            rresp.recordTypeId = recordTypeList[0].Id;
            lstRolesAndResponsibilities.add(rresp);
        }
        if (!listrolesandresp.isempty()) {
            insert listrolesandresp;
        }
        RolesandResponsibilitiesTriggerHelper.skipTrigger = false;
    }


    private void shareWithInternalUsers(List<Application__c> lstApp) {
        for (Application__c app : lstApp) {
            app.AppGroupCode__c = app.ApplicationGroupCode__c;
        }
    }

    private void copyPrimarySecondaryDetails(List<Application__c> apps) {
        Map<Id, Application__c> accountAppMap = new Map<Id, Application__c>();
        Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
        Map<Id, User> contactUserMap = new Map<Id, User>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();


        for (Application__c app : apps) {
            accountAppMap.put(app.ExternalOrganization__c, app);
            accountIdSet.add(app.ExternalOrganization__c);
        }
        List<Contact> contactList = [Select Id, OwnerId, UserRoleFormula__c, Account.Id, FirstName, LastName, Salutation, Title, HomePhone, Fax, Email from Contact where Account.Id in :accountIdSet];
        for (Contact contact : contactList) {
            contactIdSet.add(contact.Id);
            //accountContactMap.put(temp.AccountId,temp);
            List<Contact> newList = accountContactMap.get(contact.AccountId);
            if (newList == null) {
                newList = new List<Contact>();
                newList.add(contact);
            } else {
                newList.add(contact);
            }
            accountContactMap.put(contact.AccountId, newList);
        }
        List<User> userList = [Select Id, GNT__OrganizationId__c, ContactId from User where ContactId in :contactIdSet];
        for (User user : userList) {
            contactUserMap.put(user.ContactId, user);
        }

        for (Id accountId : accountAppMap.keySet()) {
            Application__c newApp = (Application__c)accountAppMap.get(accountId);
            List<Contact> newList = accountContactMap.get(accountId);
            if (newList != null ) {
                for (Contact contact : newList) {


                    if (contact.UserRoleFormula__c == 'Primary Applicant') {


                        if (contact.FirstName <> null) {
                            newApp.AuthorizedRepresentativeName__c = contact.FirstName;
                        }
                        if (contact.LastName <> null) {
                            newApp.AuthorizedRepresentativeLastName__c   = contact.LastName;
                        }
                        if (contact.Title <> null) {
                            newApp.AuthorizedRepresentativeTitle__c = contact.Title;
                        }
                        if (contact.HomePhone <> null) {
                            newApp.AuthorizedRepresentativePhone1__c = contact.HomePhone;
                        }
                        if (contact.Email <> null) {
                            newApp.AuthorizedRepresentativeEmail1__c = contact.Email;
                        }
                        if (contact.Fax <> null) {
                            newApp.AuthorizedRepresentativeFax__c = contact.Fax;
                        }
                        if (contactUserMap.get(contact.Id) <> null) {
                            newApp.PrimaryApplicant__c = ((User)contactUserMap.get(contact.Id)).Id;
                        }
                        newApp.Status__c = 'Created';
                    } else if (contact.UserRoleFormula__c == 'Secondary Applicant') {

                        if (contact.FirstName <> null) {
                            newApp.FormSecondaryFirstName__c = contact.FirstName;
                        }
                        if (contact.LastName <> null) {
                            newApp.FormSecondaryLastName__c  = contact.LastName;
                        }
                        if (contact.Title <> null) {
                            newApp.FormSecondaryTitle__c = contact.Title;
                        }
                        if (contact.HomePhone <> null) {
                            newApp.SecondaryContactPhone__c = contact.HomePhone;
                        }
                        if (contact.Email <> null) {
                            newApp.SecondaryContactEmail__c = contact.Email;
                        }
                        if (contact.Fax <> null) {
                            newApp.FormFaxNumber__c = contact.Fax;
                        }
                        if (contactUserMap.get(contact.Id) <> null) {
                            newApp.SecondaryApplicant__c = ((User)contactUserMap.get(contact.Id)).Id;
                        }
                    } else {
                        //newRole.BusinessRole__c='Other';
                    }

                }
            }
        }
    }

    private void addRolesandResponsibilities(List<Application__c> apps) {
        Map<Id, Application__c> accountAppMap = new Map<Id, Application__c>();
        Map<Id, List<Contact>> accountContactMap = new Map<Id, List<Contact>>();
        Map<Id, User> contactUserMap = new Map<Id, User>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        List<RolesAndResponsibilities__c> rolesList = new List<RolesAndResponsibilities__c>();

        // Adding Project Director and Ebiz POC to Roles and Responsibiltites. RecordType should be added to avoid missing Roles while editing
        List<RecordType> recType = [select Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = 'RolesAndResponsibilities__c' and DeveloperName = 'Application'];
        for (Application__c ap : apps) {
            /*if(ap.ProjectDirector__c <> null){
                RolesAndResponsibilities__c projectDirector = new RolesAndResponsibilities__c();
                projectDirector.Name__c = ap.ProjectDirector__c;
                //projectDirector.Role__c = ApplicationConstantHelper.ROLEARESP_ROLE_PROGRAM;
                projectDirector.BusinessRole__c= 'Program Approver';
                projectDirector.Application__c = ap.Id;
                projectDirector.RecordTypeId = recType[0].Id;
                rolesList.add(projectDirector);
            }*/
            if (ap.FedBizOps__c <> null) {
                RolesAndResponsibilities__c ebizPoc = new RolesAndResponsibilities__c();
                ebizPoc.Name__c = ap.FedBizOps__c;
                //ebizPoc.Role__c = ApplicationConstantHelper.ROLEARESP_ROLE_PROGRAM;
                ebizPoc.BusinessRole__c = 'EBiz POC';
                ebizPoc.Application__c = ap.Id;
                ebizPoc.RecordTypeId = recType[0].Id;
                rolesList.add(ebizPoc);
            }
        }
        for (Application__c app : apps) {
            accountAppMap.put(app.ExternalOrganization__c, app);
            accountIdSet.add(app.ExternalOrganization__c);
        }

        List<Contact> contactList = [Select Id, OwnerId, UserRoleFormula__c, KeyContact__c, Account.Id, FirstName, LastName, Salutation, Title, HomePhone, Fax, Email from Contact where Account.Id in :accountIdSet];
        system.debug('--contactList2--' + contactList);
        for (Contact contact : contactList) {
            contactIdSet.add(contact.Id);
            //accountContactMap.put(temp.AccountId,temp);
            List<Contact> newList = accountContactMap.get(contact.AccountId);
            if (newList == null) {
                newList = new List<Contact>();
                newList.add(contact);
            } else {
                newList.add(contact);
            }
            accountContactMap.put(contact.AccountId, newList);
        }

        List<User> userList = [Select Id, GNT__OrganizationId__c, ContactId from User where ContactId in :contactIdSet];


        for (User user : userList) {
            contactUserMap.put(user.ContactId, user);
        }


        for (Id accountId : accountAppMap.keySet()) {
            Application__c newApp = (Application__c)accountAppMap.get(accountId);
            List<Contact> newList = accountContactMap.get(accountId);
            if (newList != null ) {
                for (Contact contact : newList) {
                    if (contactUserMap.get(contact.Id) != null) {
                        RolesAndResponsibilities__c newRole = new RolesAndResponsibilities__c();
                        newRole.Agency__c = accountId;
                        newRole.Application__c = newApp.Id;
                        newRole.Name__c = ((User)contactUserMap.get(contact.Id)).Id;
                        // swati added logic for key POC
                        if (contact.UserRoleFormula__c == 'Primary Applicant' && contact.KeyContact__c == true) {
                            newRole.BusinessRole__c = 'Key POC';

                        } else if (contact.UserRoleFormula__c == 'Secondary Applicant') {
                            newRole.BusinessRole__c = 'Program Reviewer';
                        } else {
                            newRole.BusinessRole__c = 'Author';
                        }
                        //newRole.Role__c='Other';
                        rolesList.add(newRole);
                    }
                }
            }
        }
        System.debug('Roles List ----->' + rolesList);
        if (rolesList.size() > 0) {
            insert rolesList;
        }
        RolesandResponsibilitiesTriggerHelper.skipTrigger = false;
    }


    private void populateAnnouncementRolesAndResponsiblities(List<Application__c> appList) {

        Map<Id, Id> annIds = new Map<Id, Id>();

        for (Application__c newapp : appList) {
            annIds.put(newapp.Announcement__c, newapp.Id);
        }
        List<RolesAndResponsibilities__c> roleAndResponsiblility = [Select Name__c, BusinessRole__c, Responsibility__c, Announcement__c from RolesAndResponsibilities__c where
                BusinessRole__c != 'Owner' and Announcement__c in :annIds.keyset() ];
        RecordType appRecordType = [SELECT CreatedById, Description, DeveloperName, Id, Name, SobjectType FROM RecordType where sObjectType = : AppUtils.getNamespacePrefix() + 'RolesAndResponsibilities__c' and DeveloperName = :'Application' ];
        Map<Id, List<RolesAndResponsibilities__c>> annRoleMap = new Map<Id, List<RolesAndResponsibilities__c>>();

        for (RolesAndResponsibilities__c role : roleAndResponsiblility) {
            List<RolesAndResponsibilities__c> lstRolesResp = annRoleMap.get(role.Announcement__c);
            if (lstRolesResp == null) {
                lstRolesResp = new List<RolesAndResponsibilities__c>();
                annRoleMap.put(role.Announcement__c, lstRolesResp);
            }
            lstRolesResp.add(role);
        }


        for (Application__c newapp : appList) {
            Id applicationId = annIds.get(newapp.Announcement__c);
            List<RolesAndResponsibilities__c> roleAndResp = annRoleMap.get(newapp.Announcement__c);
            if (roleAndResp != null) {
                for (RolesAndResponsibilities__c role : roleAndResp ) {
                    RolesAndResponsibilities__c rolesAndResp = new RolesAndResponsibilities__c();
                    rolesAndResp.Name__c = role.Name__c;
                    rolesAndResp.Responsibility__c = role.Responsibility__c;
                    //rolesAndResp.Role__c = role.Role__c;
                    rolesAndResp.BusinessRole__c = role.BusinessRole__c;
                    rolesAndResp.Application__c = applicationId;
                    rolesAndResp.RecordTypeId = appRecordType.Id;
                    lstRolesAndResponsibilities.add(rolesAndResp);

                }
            }
        }
        insert lstRolesAndResponsibilities;
    }

    public void updateHideForm(List<Application__c> appList){
        List<Id> annIdList = new List<Id>();
        
        for(Application__c app : appList){
            annIdList.add(app.Announcement__c);
        }
        
        AggregateResult[] aggs = [SELECT FundingOpportunity__c annId FROM BusinessPackage__c WHERE PackageType__c = 'Application' AND FundingOpportunity__c IN :annIdList GROUP BY FundingOpportunity__c];
        Set<String> annHasPacIds = new Set<String>();
        for(AggregateResult agg : aggs){
            annHasPacIds.add(String.valueOf(agg.get('annId')));
        }
        
        for(Application__c app : appList){
            if(!annHasPacIds.contains(app.Announcement__c)){
                app.HideForm__c = true;
                app.FormsValidated__c = true;
            }
        }
    }

    /*
     private void disallowOwnerToUpdateAfterSubmission(){
         for(Application__c newapp :(List<Application__c>)Trigger.new){
             System.debug('newapp.status__c ----'+newapp.status__c );
             System.debug('newapp.OwnerId ----'+newapp.OwnerId + '-------UserInfo.getUserId()-----'+ UserInfo.getUserId());
             if(newapp.status__c == 'Submitted' && newapp.OwnerId == UserInfo.getUserId()) {
                 String msg = 'No updates are allowed once the application is submitted.';
                 newapp.addError(msg);
                 return;
             }
         }
     }  */

    private void createBudPeriodProjAreaBudCat(List<Application__c> apps) {
        Set<Id> appIds = new Set<Id>();
        Set<Id> announcementIds = new Set<Id>();
        Map<Id, List<Application__c>> annAppListMap = new Map<Id, List<Application__c>>();
        Map<Id, List<BudgetPeriod__c>> annBpListMap = new Map<Id, List<BudgetPeriod__c>>();
        Map<Id, List<AnnouncementServiceArea__c>> annAsaListMap = new Map<Id, List<AnnouncementServiceArea__c>>();
        Map<Id, List<FundingOpportunityBudgetCategory__c>> annFoBcListMap = new Map<Id, List<FundingOpportunityBudgetCategory__c>>();
        Map<Id, Map<Id, BudgetPeriod__c>> appBpIdMap = new Map<Id, Map<Id, BudgetPeriod__c>>();
        Map<Id, Map<Id, ApplicationServiceArea__c>> appAsaIdMap = new Map<Id, Map<Id, ApplicationServiceArea__c>>();

        List<BudgetPeriod__c> annBudPeriodList;
        List<AnnouncementServiceArea__c> annSaList;
        List<BudgetPeriod__c> budgetPeriodList = new List<BudgetPeriod__c>();
        List<ApplicationServiceArea__c> appSaList = new List<ApplicationServiceArea__c>();
        List<ApplicationBudgetCategory2__c> appBudCatList = new List<ApplicationBudgetCategory2__c>();
        List<BudgetPeriod__c> budPeriodList;
        List<AnnouncementServiceArea__c>  annServiceAreaList;
        List<FundingOpportunityBudgetCategory__c>  foBudList;


        for (Application__c app : apps) {
            List<Application__c> newAppList;
            announcementIds.add(app.Announcement__c);
            appIds.add(app.Id);
            system.debug('App Id is:' + app.Id);
        }
        system.debug('AnnouncementIds:' + announcementIds);

        budPeriodList = [Select id, Name, SupportYear__c, BudgetEndDate__c, SequenceNumber__c, FundingOpportunity__c, Notes__c, BudgetStartDate__c, Status__c
                         from BudgetPeriod__c where FundingOpportunity__c in :announcementIds];
        annServiceAreaList = [Select Id, BudgetPeriod__c, ServiceArea__c, Announcement__c from AnnouncementServiceArea__c where Announcement__c  in :announcementIds];
        //foBudList = [Select Id,FundingOpportunity__c,BudgetPeriod__c,FundingOpportunityProjectArea__c,FundingOpportunityBudgetPeriod__r.FundingOpportunityProjectArea__c ,FundingOpportunityBudgetPeriod__r.BudgetPeriod__c ,BudgetCategory__c
        //            from FundingOpportunityBudgetCategory__c where FundingOpportunity__c in :announcementIds];

        for (BudgetPeriod__c bp : budPeriodList) {
            List<BudgetPeriod__c> newBudPeriodList;

            if (annBpListMap.get(bp.FundingOpportunity__c) <> null) {
                annBpListMap.get(bp.FundingOpportunity__c).add(bp);
            } else {
                newBudPeriodList = new List<BudgetPeriod__c>();
                newBudPeriodList.add(bp);
                annBpListMap.put(bp.FundingOpportunity__c, newBudPeriodList);
            }
        }

        for (AnnouncementServiceArea__c asa : annServiceAreaList) {
            List<AnnouncementServiceArea__c> asaList;

            if (annAsaListMap.get(asa.Announcement__c) <> null) {
                annAsaListMap.get(asa.Announcement__c).add(asa);
            } else {
                asaList = new List<AnnouncementServiceArea__c>();
                asaList.add(asa);
                annAsaListMap.put(asa.Announcement__c, asaList);
            }
        }

        //for(FundingOpportunityBudgetCategory__c foBc:foBudList){
        //    List<FundingOpportunityBudgetCategory__c> foBcList;

        //    if(annFoBcListMap.get(foBc.FundingOpportunity__c) <> null){
        //        annFoBcListMap.get(foBc.FundingOpportunity__c).add(foBc);
        //    }else{
        //        foBcList = new List<FundingOpportunityBudgetCategory__c>();
        //        foBcList.add(foBc);
        //        annFoBcListMap.put(foBc.FundingOpportunity__c,foBcList);
        //    }
        //}

        for (Application__c app : apps) {
            annBudPeriodList = annBpListMap.get(app.Announcement__c);
            if (annBudPeriodList <> null) {
                for (BudgetPeriod__c bp : annBudPeriodList) {
                    BudgetPeriod__c appBp = new BudgetPeriod__c();
                    appBp.Application__c = app.Id;
                    appBp.SupportYear__c = bp.SupportYear__c;
                    //appBp.Name=bp.Name;
                    appBp.BudgetEndDate__c = bp.BudgetEndDate__c;
                    appBp.Notes__c = bp.Notes__c;
                    appBp.BudgetStartDate__c = bp.BudgetStartDate__c;
                    appBp.Status__c = bp.Status__c;
                    appBp.SequenceNumber__c = bp.SequenceNumber__c;
                    budgetPeriodList.add(appBp);
                    if (appBpIdMap.get(app.Id) <> null) {
                        appBpIdMap.get(app.Id).put(bp.Id, appBp);
                    } else {
                        Map<Id, BudgetPeriod__c> bpIdMap = new Map<Id, BudgetPeriod__c>();
                        bpIdMap.put(bp.Id, appBp);
                        appBpIdMap.put(app.Id, bpIdMap);
                    }
                }
            }

        }
        if (budgetPeriodList.size() > 0) {
            insert budgetPeriodList;
            system.debug('budgetPeriodList--' + budgetPeriodList.size());
        }
        for (Application__c app : apps) {
            annSaList = annAsaListMap.get(app.Announcement__c);
            if (annSaList <> null) {
                for (AnnouncementServiceArea__c asa : annSaList) {
                    ApplicationServiceArea__c appSa = new ApplicationServiceArea__c();
                    appSa.ServiceAreaLookup__c = asa.ServiceArea__c;
                    appSa.Application__c = app.Id;
                    appSa.ServiceArea__c = asa.Id;
                    if (asa.BudgetPeriod__c <> null) {
                        if (appBpIdMap.get(app.Id) <> null) {
                            if (appBpIdMap.get(app.Id).get(asa.BudgetPeriod__c) <> null) {
                                appSa.BudgetPeriod__c = ((BudgetPeriod__c)appBpIdMap.get(app.Id).get(asa.BudgetPeriod__c)).Id;
                            }
                        }
                    }
                    appSaList.add(appSa);
                    if (appAsaIdMap.get(app.Id) <> null) {
                        appAsaIdMap.get(app.Id).put(asa.Id, appSa);
                    } else {
                        Map<Id, ApplicationServiceArea__c> appIdMap = new Map<Id, ApplicationServiceArea__c>();
                        appIdMap.put(asa.Id, appSa);
                        appAsaIdMap.put(app.Id, appIdMap);
                    }

                }
            }
        }
        if (appSaList.size() > 0) {
            insert appSaList;
            system.debug('appSaList--' + appSaList.size());
        }

        for (Application__c app : apps) {
            if (app.ConstructionPackageIncluded__c == GNT.KeyValueStoreHelper.getTextValue('Budget Non Construction Form', true)) {
                List<String> nonConstructLst = new List<String>();
                nonConstructLst.add('Federal');
                nonConstructLst.add('Non Federal');

                for (String val : nonConstructLst) {
                    FormBudgetInformation__c form = new FormBudgetInformation__c();
                    form.GrantProgramFunctionOrActivity__c = val;
                }
            }

        }
        system.debug('appIds---' + appIds);
        List<ApplicationServiceArea__c> lstappServiceAreas = [Select Id from ApplicationServiceArea__c where  Application__c in :appIds ];
        List<BudgetPeriod__c> lstBudgetPeriod = [Select Id from BudgetPeriod__c where  Application__c in :appIds ];

        List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'BudgetCategory__c' and Name = 'External'];
        List<BudgetCategory__c> nonConlstBudgetCat = [Select Id, Name from BudgetCategory__c where Status__c = 'Active' AND recordTypeId = :recordTypeList[0].Id AND Class__c = 'Non Construction'];
        List<BudgetCategory__c> conlstBudgetCat = [Select Id, Name from BudgetCategory__c where Status__c = 'Active' AND recordTypeId = :recordTypeList[0].Id AND Class__c = 'construction'];

        for (Application__c app : apps) {

            //foBudList = annFoBcListMap.get(app.Announcement__c);

            for (BudgetPeriod__c bp : (List<BudgetPeriod__c>)lstBudgetPeriod) {
                System.debug(' BudgetPeriod__c   >> ' + bp);
                for (ApplicationServiceArea__c asa : (List<ApplicationServiceArea__c>)lstappServiceAreas ) {
                    System.debug('  ApplicationServiceArea__c   >> ' + asa);

                    if (app.ConstructionPackageIncluded__c == 'Construction') {
                        for (BudgetCategory__c objBC : conlstBudgetCat) {
                            ApplicationBudgetCategory2__c abc = new ApplicationBudgetCategory2__c();
                            abc.Application__c = app.Id;
                            abc.BudgetCategory__c = objBC.Id;
                            abc.BudgetPeriod__c = bp.Id;
                            abc.ServiceArea__c = asa.Id;
                            appBudCatList.add(abc);
                        }
                    } else {
                        for (BudgetCategory__c objBC : nonConlstBudgetCat) {
                            ApplicationBudgetCategory2__c abc = new ApplicationBudgetCategory2__c();
                            abc.Application__c = app.Id;
                            abc.BudgetCategory__c = objBC.Id;
                            abc.BudgetPeriod__c = bp.Id;
                            abc.ServiceArea__c = asa.Id;
                            appBudCatList.add(abc);
                        }
                    }
                    //if(foBudList <> null){
                    //// iterate over the Project Area and Service Areas
                    //  for(FundingOpportunityBudgetCategory__c foBd: foBudList){
                    //        ApplicationBudgetCategory2__c abc = new ApplicationBudgetCategory2__c();
                    //        abc.Application__c=app.Id;
                    //        abc.BudgetCategory__c=foBd.BudgetCategory__c;
                    //        abc.BudgetPeriod__c=bp.Id;   //  this is the Application budget Period now
                    //        abc.ServiceArea__c=asa.Id;  // should be application project area created above

                    //       // if(foBd.BudgetCategory__c != null && bp.Id != null){
                    //            appBudCatList.add(abc);
                    //        //}
                    //    }
                    //}
                }  // close the Service Area
            }// close the budget Period
        }
        if (appBudCatList.size() > 0) {
            system.debug('*** sarat testing - ' + appBudCatList);
            insert appBudCatList;
        }

    }


    private void updateApplicationStatusOnApproval() {
        Map<Id, Application__c> oldApplicationMap = (Map<Id, Application__c>)trigger.oldMap;
        Map<Id, Application__c> newApprovedApplicationMap = new Map<Id, Application__c>();
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (newapp.ChangeRequestStatus__c == 'Change Request Approved' && oldApplicationMap.get(newapp.id).ChangeRequestStatus__c != 'Change Request Approved') {
                newapp.status__c = 'Approved';
            } else if (newapp.ChangeRequestStatus__c == 'Change Request Disapproved' && oldApplicationMap.get(newapp.id).ChangeRequestStatus__c != 'Change Request Disapproved') {
                newapp.status__c = 'Disapproved';
            }
        }
    }
    private void updateExternalOrgLookup() {
        GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        if (userPrefs != null) {
            for (Application__c newapp : (List<Application__c>)Trigger.new) {
                if (newapp.ExternalOrganization__c == null && userPrefs.GNT__OrganizationAccountId__c != null) {
                    newapp.ExternalOrganization__c = userPrefs.GNT__OrganizationAccountId__c;
                }
            }
        }
    }

    /*
    *   Send confirmation mail to applicant that Application has been submitted for Review
    */

    private void sendSubmissionEmail() {
        Map<Id, Id> targetObjectWhatIdMap = new Map<Id, Id>();
        Map<Id, Id> WhatIdtemplateMap = new Map<Id, Id>();
        List<Id> ownerIds = new List<Id>();
        boolean sendEmail = false;
        Map<Id, Application__c> oldApplicationMap = (Map<Id, Application__c>)trigger.oldMap;
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            ownerIds.add(newapp.ownerId);
        }
        Map<Id, User> userMap = new Map<Id, User>([select contactId from user where id in :ownerIds]);
        Map<Id, Id> userContactMap = new Map<Id, Id>();
        for (Id userId : userMap.keySet()) {
            userContactMap.put(userId, userMap.get(userId).contactId);
        }
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (newapp.EnableApplicationSubmissionEmail__c == true  && !String.isEmpty(newApp.ApplicationSubmissionTemplate__c) &&
                    newapp.Status__c == 'Submitted' && oldApplicationMap.get(newapp.id).Status__c != 'Submitted') {
                targetObjectWhatIdMap.put(newapp.id, userContactMap.get(newapp.ownerId));
                WhatIdtemplateMap.put(newapp.id, newapp.ApplicationSubmissionTemplate__c);
                sendEmail = true;
                String msg = 'Application is successfully Submitted';
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm, msg);
                ApexPages.addMessage(myMsg);
            }
        }
        if (sendEmail) {
            GNT.AppUtils.sendEmailUsingTemplate(WhatIdtemplateMap, targetObjectWhatIdMap, true);
        }
    }

    /*private void shareApplicationWithReviewer(){
       List<Id> applicationId = new List<Id>();
       List<Id> lstAppsReviewAndApprover = new List<Id>();
       Map<Id,List<Id>> appUserList = new Map<Id,List<Id>>();
       List<RolesAndResponsibilities__c> lstRolesAndResponsibilities = [Select Name__c,BusinessRole__c,Application__c from RolesAndResponsibilities__c where BusinessRole__c LIKE '%Reviewer%' and Application__c in: Trigger.new];
       for(RolesAndResponsibilities__c role: lstRolesAndResponsibilities){

            List<Id> reviewerList = appUserList.get((Id)role.Application__c);
            if(reviewerList == null){
                reviewerList = new List<Id>();
                appUserList.put(role.Application__c,reviewerList);
              }
              reviewerList.add(role.Name__c);
              lstAppsReviewAndApprover.add((Id)role.Application__c);
       }

       List<Application__c> applicationList = [Select Id,createdBy.ManagerId,ProgramApprover__c,FiscalApproval__c,FedBizOps__c,OwnerManager__c from Application__c where
                                               FiscalApproval__c != null and ProgramApprover__c!= null and FedBizOps__c != null and Id in :lstAppsReviewAndApprover];
       for(Application__c app : applicationList) {

             List<Id> reviewerList = appUserList.get(app.Id);
            if(reviewerList == null){
                reviewerList = new List<Id>();
                appUserList.put(app.Id,reviewerList);
            }
             reviewerList.add(app.ProgramApprover__c);
             reviewerList.add(app.FiscalApproval__c);
             reviewerList.add(app.FedBizOps__c);
       }
             SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
             SystemContextMethodsHelper.shareAnnouncement(appUserList);
    } */



    /*
     * Changes ChangeRequests on submitted applications to complete
     */
    private void handleNewRequestStatus() {
        Map<Id, Application__c> oldApplicationMap = (Map<Id, Application__c>)trigger.oldMap;
        Map<Id, Application__c> newApplicationMap = new Map<Id, Application__c>();
        Map<Id, Application__c> newApprovedApplicationMap = new Map<Id, Application__c>();
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (newapp.Status__c == 'Submitted' && oldApplicationMap.get(newapp.id).Status__c != 'Submitted' ) {
                newApplicationMap.put(newapp.id, newapp);
            }
        }
        List<ChangeRequest__c> allRequests = [SELECT Status__c, Application__c FROM ChangeRequest__c WHERE
                                              (Status__c in('Initiated', 'Accepted') AND Application__c IN: newApplicationMap.keySet())];
        for (ChangeRequest__c request : allRequests) {
            request.Status__c = 'Completed';
            request.ChangeRequestPendingOn__c = 'Internal';
        }
        update allRequests;
        return;
    }

    /*
    * Changes ChangeRequests on approved applications to complete
    */
    private void handleApprovedRequestStatus() {
        Map<Id, Application__c> oldApplicationMap = (Map<Id, Application__c>)trigger.oldMap;
        Map<Id, Application__c> newApprovedApplicationMap = new Map<Id, Application__c>();
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if ((newapp.ChangeRequestStatus__c == 'Change Request Approved' && oldApplicationMap.get(newapp.id).ChangeRequestStatus__c != 'Change Request Approved') || (newapp.ChangeRequestStatus__c == 'Change Request Disapproved' && oldApplicationMap.get(newapp.id).ChangeRequestStatus__c != 'Change Request Disapproved')) {
                newApprovedApplicationMap.put(newapp.id, newapp);
            }
        }
        List<ChangeRequest__c> allRequests = [SELECT Status__c, Application__c, ReviewerAgreedOn__c, ReviewerApprovalStatus__c FROM ChangeRequest__c WHERE
                                              (Status__c = 'Completed' AND Application__c IN: newApprovedApplicationMap.keySet())];
        for (ChangeRequest__c request : allRequests) {
            if (newApprovedApplicationMap.get(request.Application__c).ChangeRequestStatus__c == 'Change Request Approved') {
                request.ReviewerAgreedOn__c = system.now();
                request.ReviewerApprovalStatus__c = 'Approved';
            } else if (newApprovedApplicationMap.get(request.Application__c).ChangeRequestStatus__c == 'Change Request Disapproved') {
                request.ReviewerApprovalStatus__c = 'Denied';
            }
            request.ChangeRequestPendingOn__c = '';
        }
        if (allRequests.size () > 0) {
            update allRequests;
        }
    }
    /*
     * Updates ChangeRequestStatus to completed on submitted applications
     */
    private void handleApplicationRequestStatus() {
        Map<Id, Application__c> oldApplicationMap = (Map<Id, Application__c>)trigger.oldMap;
        Map<Id, Application__c> newApplicationMap = new Map<Id, Application__c>();
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (newapp.Status__c == 'Submitted' && oldApplicationMap.get(newapp.id).Status__c != 'Submitted' && (newapp.ChangeRequestStatus__c  == 'Change Request Accepted' || newapp.ChangeRequestStatus__c == 'Change Request Assigned')) {
                newapp.ChangeRequestStatus__c = 'Change Request Completed';
            }
        }
        return;
    }
    /*
     * Populates the SubmittedBy__c field if sbmitted from external to internal
     */
    private void updateSubmittedBy() {
        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (Trigger.oldMap.containsKey(newapp.Id)) {
                Application__c oldapp = (Application__c)Trigger.oldMap.get(newapp.Id);
                if (newapp.Status__c == 'Submitted' && oldapp.Status__c != 'Submitted') {
                    newapp.SubmittedBy__c = UserInfo.getUserId();
                    newapp.SubmittedOn__c = System.now();
                    newapp.Submitted_to_Internal__c = true;
                }
            }
        }
    }

    /*
     * Updates Applications count for an announcement by each applicant
     */
    private void updateApplicationCount() {
        Set<Id> applicantOrgId = new Set<Id>();
        Set<Id> annId = new Set<Id>();
        Boolean flag = false;
        List<Application__c> newAppList = new List<Application__c>();

        system.debug('inside updateApplicationCount................................................');

        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (newapp.Status__c == 'Submitted to Grantor') {
                applicantOrgId.add(newapp.ExternalOrganization__c);
                annId.add(newapp.Announcement__c);
            }
        }

        List<Application__c> appList = [Select Id, Name, CountSubmittedApps__c from Application__c where Announcement__c in : annId and ExternalOrganization__c in :applicantOrgId and Status__c = 'Submitted to Grantor'];
        Integer count = appList == null ? 0 : appList.size();
        for (Application__c app : appList) {
            app.CountSubmittedApps__c = count;
            newAppList.add(app);
        }



        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            if (Trigger.oldMap.containsKey(newapp.Id)) {
                Application__c oldapp = (Application__c)Trigger.oldMap.get(newapp.Id);
                if (newapp.Status__c == 'Submitted to Grantor' && oldapp.Status__c != 'Submitted to Grantor') {
                    //   newapp.SubmittedBy__c = UserInfo.getUserId();
                    //   newapp.SubmittedOn__c = System.now();
                    flag = true;
                }
            }
        }

        if (newAppList.size() > 0 && flag)
            update newAppList;
    }


    /*
    * Decrement Applications count for an announcement by each applicant when it is withdrawn
    */
    private void decrementApplicationCount() {
        Set<Id> applicantOrgId = new Set<Id>();
        Set<Id> annId = new Set<Id>();
        Boolean flag = false;
        List<Application__c> newAppList = new List<Application__c>();

        system.debug('inside decrementApplicationCount................................................');

        for (Application__c newapp : (List<Application__c>)Trigger.old) {
            if (newapp.Status__c == 'Withdrawn') {
                applicantOrgId.add(newapp.ExternalOrganization__c);
                annId.add(newapp.Announcement__c);
            }
        }

        List<Application__c> appList = [Select Id, Name, CountSubmittedApps__c from Application__c where Announcement__c in : annId and ExternalOrganization__c in :applicantOrgId and Status__c = 'Submitted to Grantor'];
        Integer count = appList == null ? 0 : appList.size();
        for (Application__c app : appList) {
            app.CountSubmittedApps__c = count;
            newAppList.add(app);
        }



        for (Application__c newapp : (List<Application__c>)Trigger.old) {
            if (Trigger.oldMap.containsKey(newapp.Id)) {
                Application__c oldapp = (Application__c)Trigger.oldMap.get(newapp.Id);
                if (newapp.Status__c == 'Withdrawn' && oldapp.Status__c != 'Withdrawn') {
                    //   newapp.SubmittedBy__c = UserInfo.getUserId();
                    //   newapp.SubmittedOn__c = System.now();
                    flag = true;
                }
            }
        }

        if (newAppList.size() > 0 && flag)
            update newAppList;
    }

    /*
        Method checks if internal user or external user
        Action - If external User - Status is submitted - Updating record is not allowed once Application is submitted
        Action - If internal User - Allow Update
    */
    private void checkProfile(Map<Id, Application__c> oldApps, List<Application__c> applicationList) {
        for (Application__c applicationInstance : applicationList) {
            Application__c oldApp = oldApps.get(applicationInstance.Id);
        }
    }

    /*share with external users of same organization*/
    private void shareToExternalUser() {
        Id roleId = UserInfo.getUserRoleId();
        List<Group> publicGroup  = [select id from Group where type = 'Role' and relatedId = :roleId];
        if (publicGroup != null && publicGroup.size() > 0) {
            List<Application__Share> applicationShares  = new List<Application__Share>();
            List<Application__c> appList = trigger.new;
            for (Application__c app : appList) {
                Application__Share applicationShare = new Application__Share();
                applicationShare.parentId = app.id;
                applicationShare.UserOrGroupId = publicGroup[0].id;
                applicationShare.AccessLevel = 'edit';
                applicationShare.RowCause = Schema.Application__Share.RowCause.SharetoExternalUsers__c;
                applicationShares.add(applicationShare);
            }
            if (applicationShares.size () > 0) {
                SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                SystemContextMethodsHelper.upsertApplicationShare(applicationShares);
            }
        }
    }
    /* Add Share object to manually share the Application  created by  Community users with Internal SF users
    based on Account lookup which is present on the program.
    */
    //private void addSharingSettings(Map<Id,Application__c> applicationMap,Map<Id,Application__c> oldMap){
    //    Set<String> acctNames = new Set<String>();
    //    for(Application__c application : applicationMap.values()){
    //        acctNames.add(application.ProgramAccountName__c);
    //    }

    //    Map<Id, UserRole> roleMap = new Map<Id, UserRole>([Select Id, Name from UserRole where Name in :acctNames]);
    //    Map<String, UserRole> roleMapByName = new Map<String, UserRole>(); //key->role name
    //    for (UserRole role : roleMap.values()) {
    //        roleMapByName.put(role.Name, role);
    //    }

    //    List<Group> groups= [select id, RelatedId from Group where type='Role' and RelatedId in : roleMap.keySet()];
    //    Map<Id,Group> groupMap = new Map<Id,Group>();  //key->role id
    //    for(Group grp : groups){
    //        groupMap.put(grp.RelatedId,grp);
    //    }

    //    List<Application__Share> applicationShares  = new List<Application__Share>();
    //    for(Application__c Application : applicationMap.values()){
    //        Application__c oldApp = oldMap.get(application.Id);
    //        if(application.Status__c == 'Submitted' && oldApp.Status__c != 'Submitted'){
    //            UserRole role = roleMapByName.get(application.ProgramAccountName__c);
    //            if(role != null){
    //                Group grp = groupMap.get(role.Id);
    //                Application__Share applicationShare= new Application__Share();
    //                applicationShare.ParentId = Application.Id;
    //                applicationShare.UserOrGroupId = grp.id;
    //                applicationShare.AccessLevel = 'Edit';
    //                applicationShares.add(applicationShare);
    //            }

    //        }
    //    }

    //    // Insert all of the newly created Share records and capture save result
    //    if(Schema.sObjectType.Application__c.isCreateable()){
    //        //insert applicationShares;
    //        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
    //        SystemContextMethodsHelper.insertApplicationShare(applicationShares);
    //    }
    //}

    private void incrementTotalApplications(List<Application__c> applicationList, Map<Id, Application__c> oldMap) {
        Set<Id> announceIds = new Set<Id>();
        for (Application__c app : applicationList) {
            if ((app.Status__c == 'Submitted to Grantor' ||  app.Status__c == 'Submitted For Approval') && oldMap.get(app.Id).Status__c == 'Internally Reviewed') {
                announceIds.add(app.Announcement__c);
            }
        }

        if (announceIds.size() > 0) {
            Map<Id, Announcement__c> announceMap = new Map<Id, Announcement__c>([SELECT Id, NumberOfApplications__c
                    FROM Announcement__c WHERE Id IN :announceIds]);
            List<OpportunityQualification__c>  oppQualList = [Select id, OpportunityStatus__c from OpportunityQualification__c where FundingOpportunity__c IN :announceIds];
            List<Announcement__c> announceList = new List<Announcement__c>();

            for (OpportunityQualification__c oppQual : oppQualList) {
                oppQual.OpportunityStatus__c = 'Submitted to Grantor';
            }

            for (Application__c appln : applicationList) {
                //if (oldMap.get(appln.id).Submitted_to_Internal__c == false && appln.Submitted_to_Internal__c == true){
                Announcement__c announce = announceMap.get(appln.Announcement__c);
                if (announce.NumberOfApplications__c == null) {
                    announce.NumberOfApplications__c = 0;
                } else {
                    announce.NumberOfApplications__c = announce.NumberOfApplications__c + 1;
                }

                announceList.add(announce);
                //}
            }
            if (oppQualList <> null && oppQualList.size() > 0) {
                update oppQualList;
            }
            SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
            SystemContextMethodsHelper.updateAnnouncements(announceList);
        }
    }

    private void decrementTotalApplications(List<Application__c> applicationList) {
        Set<Id> announceIds = new Set<Id>();
        for (Application__c app : applicationList) {
            announceIds.add(app.Announcement__c);
        }

        Map<Id, Announcement__c> announceMap = new Map<Id, Announcement__c>([SELECT Id, NumberOfApplications__c
                FROM Announcement__c WHERE Id IN :announceIds]);
        for (Application__c appln : applicationList) {
            if (appln.Submitted_to_Internal__c == true) {
                Announcement__c announce = announceMap.get(appln.Announcement__c);
                if (announce.NumberOfApplications__c != null) {
                    announce.NumberOfApplications__c = announce.NumberOfApplications__c - 1;
                }
            }
        }
        List<Announcement__c> annToUpdate = new List<Announcement__c>();
        for (Announcement__c ann : announceMap.values()) {
            annToUpdate.add(ann);
        }
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.updateAnnouncements(annToUpdate);
    }

    /*
      Method: createAwardTask
      Purpose: This method creates a task for creating award to the Assigned to user.
    */
    private void createAwardTask(Map<Id, Application__c> applicationNewMap, Map<Id, Application__c> applicationOldMap) {
        List<Task> createAwardTaskList = new List<Task>();
        for (Application__c newApplication : applicationNewMap.values()) {
            if (newApplication.Status__c == 'Approved' && applicationOldMap.get(newApplication.Id).Status__c != 'Approved')  {
                //Task taskForAward = GNT.TaskCreationHandler.createTasks(newApplication.AssignedTo__c, newApplication.Id, 'Create Award', newApplication.Name, null, false, null, 'Other', false).get(0);
                Task taskForAward = GNT.TaskCreationHandler.createTasks(newApplication.AssignedTo__c, newApplication.Id, 'Create Award', newApplication.Name, null, false, null, 'Other', newApplication.Title__c, false).get(0);
                createAwardTaskList.add(taskForAward);
            }
        }
        if (Schema.sObjectType.Application__c.isCreateable()) {
            insert createAwardTaskList;
        }
    }

    /*
        METHOD TO CHECK IF A GRANT EXISTS FOR A NEW AWARD CREATION
        - CHECK WILL BE BASED ON EXTERNAL ORGANIZATION IN AWARD'S APPLICATION
        - IF EXTERNAL USER'S ORGANIZATION IS FOUND IN PREVIOUS AWARDED APPLICATIONS, A GRANT ALREADY EXISTS
    */
    /* private Id checkGrantsExists(Id ExternalOrganizationId){
         Id grantId;
         List<Award__c> awards = [SELECT ID,NAME,Grant__c FROM AWARD__c WHERE Application__r.ExternalOrganization__c = : ExternalOrganizationId];
         if(awards.size() > 0){
             grantId = awards.get(0).Grant__c;
         }else {
             grantId = null;
         }
         return grantId;
     }*/

    /* METHOD TO FIND THE SUPPORT YEAR FOR A GRANT */
    /*public integer getSupportYear(Date grantStart, Date budgetStart){
        integer supportYear;
        supportYear = grantStart.year() - budgetStart.year();
        return supportYear;
    }*/

    /* This method populates the ExternalOrganization field on application based on the Owner's Organization.*/
    /* For Grantee we only populate this Field if it is Empty */
    private void populateExternalOrg(List<Application__c> applicationList) {
        Set<Id> ownerIdSet = new Set<Id>();
        for (Application__c app : applicationList) {
            ownerIdSet.add(app.OwnerId);
        }
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, GNT__OrganizationId__c FROM User WHERE Id IN :ownerIdSet]);
        for (Application__c appln : applicationList) {
            User owner = userMap.get(appln.OwnerId);
            if (owner != null) {
                if (appName.equals('StateasGrantee') && appln.ExternalOrganization__c != null) {
                    appln.ExternalOrganization__c = owner.GNT__OrganizationId__c;
                } else {
                    appln.ExternalOrganization__c = owner.GNT__OrganizationId__c;
                }
            }
        }
    }

    /*Method Used to print PDF files for applications at Awards or Review Assignment level  */
    public static void UpdateAppTemplName(List<Application__c> lApplication) {
        Set<String> sAnnouncIds = new Set<String>();
        List<Application__c> lApp = new List<Application__c>();
        // Iterate the list of Application records and collect a Set of Announcment object ids
        for (Application__c ObjApp : lApplication) {
            if (ObjApp.Announcement__c != null && ObjApp.PageTemplateName__c == null) {
                sAnnouncIds.add(ObjApp.Announcement__c);
                lApp.add(ObjApp);
            }
        }
        // If the size of Set is greater than 0 then process records
        //   if(sAnnouncIds.size() > 0)
        // SetAppTemplName(lApp, sAnnouncIds);  // Davinder I have deleted this method for now as it looks redundant
    }

    /*
    * Populates the AssignedTo__c field on Application with Announcement.OwnerId
    */
    private void updateAssignedTo() {
        List<Id> AnnId = new List<Id>();
        for (Application__c app :  (List<Application__c>) Trigger.New) {
            AnnId.add(app.Announcement__c);
        }

        Map<Id, Id> mapAnnOwner = new Map<Id, Id>();
        for (Announcement__c ann : [Select Id, OwnerId FROM Announcement__c WHERE ID IN : AnnId]) {
            mapAnnOwner.put(ann.Id, ann.OwnerId);
        }

        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            newapp.AssignedTo__c = mapAnnOwner.get(newApp.Announcement__c);
        }
    }


    /*
       This method will check Announcement deadline date and Application Deadline Date and time.
    */
    private void checkAnnouncementDeadline(List<Application__c> AppList) {
        GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
        if (userPrefs != null) {
            if (userPrefs.GNT__ProfileName__c == 'Applicant') {
                Set<Id> annIds = new Set<Id>();
                for (Application__c newapp : AppList) {
                    annIds.add(newapp.Announcement__c);
                }

                Map<Id, Announcement__c> annMap = new Map<Id, Announcement__c>([Select Id, ApplicationDeadlineWithDateTime__c,
                        ApplicationPostDeadlineMessage__c from Announcement__c where Id in :annIds]);

                for (Application__c newapp : AppList) {
                    Announcement__c ann = annMap.get(newapp.Announcement__c);
                    System.debug('ann.ApplicationDeadlineWithDateTime__c--->>>' + ann.ApplicationDeadlineWithDateTime__c);
                    if (ann.ApplicationDeadlineWithDateTime__c < System.now()) {
                        newapp.addError(ann.ApplicationPostDeadlineMessage__c);
                    }
                }
            }
        }
    }

    private void updatePreApplication() {
        Map<Id, Application__c> announcementsMap =  new Map<Id, Application__c>();
        List<Id> preApplicationIds = new List<Id>();

        for (Application__c newapp : (List<Application__c>)Trigger.new) {
            announcementsMap.put(newapp.Announcement__c, newapp);
            preApplicationIds.add(newapp.Announcement__c);
        }

        List<PreApplication__c> lstPreApplication = [Select Id, Announcement__c from PreApplication__c where Announcement__c in: preApplicationIds ];
        for (PreApplication__c preApp : lstPreApplication) {
            Application__c application = announcementsMap.get(preApp.Announcement__c);
            application.PreApplication__c = preApp.Id;
        }
    }

    private void updateGranteeAnnouncement(List<Application__c> appList) {

        Map<Id, Id> oppAnnMap = new Map<Id, Id>();
        for (Application__c app : appList) {
            oppAnnMap.put(app.Id, app.Announcement__c);
        }

        List<Announcement__c> lstAnnouncements = [Select Id, Status__c from Announcement__c where Id in : oppAnnMap.values() ];

        for (Announcement__c announcement : lstAnnouncements) {
            announcement.Status__c = 'Converted to Application';
        }
        update lstAnnouncements;
    }


    private void updatePreApplication(List<Application__c> appList) {

        Map<Id, Id> oppPreAppMap = new Map<Id, Id>();
        for (Application__c app : appList) {
            oppPreAppMap.put(app.Id, app.PreApplication__c);
        }

        List<PreApplication__c> lstPreApplications = [Select Id, Status__c from PreApplication__c where Id in : oppPreAppMap.values() ];

        for (PreApplication__c announcement : lstPreApplications) {
            announcement.Status__c = 'Converted to Application';
        }
        update lstPreApplications;
    }


    private void createTasks(List<Application__c> lstApp) {
        List<Task> lstTasks = new List<Task>();
        System.debug('CREATE TASKS IS ' + lstTasks);
        for (Application__c app : lstApp) {
            Date dueDate = date.newinstance(app.ApplicationDeadlineWithDateTime__c.year(), app.ApplicationDeadlineWithDateTime__c.month(), app.ApplicationDeadlineWithDateTime__c.day());
            /*List<Task> appTask = GNT.TaskCreationHandler.createTasks(app.createdById, app.Id, 'Complete Application', app.Title__c, null, false,
                                 null, 'Other', false);     */
            List<Task> appTask = GNT.TaskCreationHandler.createTasks(app.createdById, app.Id, 'Complete Application', app.Name, null, false,
                                 null, 'Other', app.Title__c, false);



            System.debug('The list of Tasks is 00 ' + appTask);
            lstTasks.addAll(appTask);
        }
        System.debug('The list of Tasks is 11 ' + lstTasks);
        if (lstTasks.size() > 0) {
            insert lstTasks;
        }
    }

    private void IncrementApplicationUpdationCount(List<Application__c> appList) {
        for (Application__c app : appList) {
            if (app.ApplicationUpdateCount__c != null) {
                app.ApplicationUpdateCount__c = app.ApplicationUpdateCount__c + 1;
                System.debug('app.ApplicationUpdateCount__c-->>' + app.ApplicationUpdateCount__c);
            }
        }

    }

    /** Method updates Sponsored submission status and Opportunity Result based on Application Status at Grantee side**/

    private void UpdateFOAValues(List<Application__c> applications) {
        List<Id> listIds = new List<Id>();
        for (Application__c childObj : applications) {
            listIds.add(childObj.Announcement__c);
        }
        List<Announcement__c> annlist = [select Id, (select Id , name, Status__c from Applications__r) from Announcement__c WHERE ID IN :listIds];
        for (Announcement__c foa : annlist) {
            List<Application__c> childApps = annlist[0].Applications__r;
            for (Application__c app : childApps) {
                if (app.Status__c == 'Submitted to Grantor') foa.SponsoredSubmissionStatus__c = true;
                if (app.Status__c == 'Accepted')  foa.OpportunityResult__c = 'Won';
                if (app.Status__c == 'Rejected')  foa.OpportunityResult__c = 'Lost';
            }
        }
        update annlist;
    }

    // This method updates Qualified Announcement's Application field with the newly created Application. This acts as a link to Application from
    // a qualified annoucement.

    private void updateQualifiedOpportunity(List<Application__c> applications) {
        List<Id> listIds = new List<Id>();
        for (Application__c childObj : applications) {
            listIds.add(childObj.Announcement__c);
        }
        List<OpportunityQualification__c> qualifiedAnnlist = [select Id, Application__c from OpportunityQualification__c WHERE FundingOpportunity__c IN :listIds];
        for (OpportunityQualification__c qualAnn : qualifiedAnnlist) {

            for (Application__c app : applications) {

                qualAnn.Application__c = app.Id;
                if (qualAnn.ApplicationCreated__c != true && qualAnn.OpportunityStatus__c != 'Converted to Application') {
                    qualAnn.ApplicationCreated__c = true;
                    qualAnn.OpportunityStatus__c = 'Converted to Application';
                }
            }
        }
        update qualifiedAnnlist;
    }

    private void createBudPeriodProjAreaBudCatGrantor(List<Application__c> apps) {
        Set<Id> appIds = new Set<Id>();
        Set<Id> announcementIds = new Set<Id>();
        Map<Id, List<Application__c>> annAppListMap = new Map<Id, List<Application__c>>();
        Map<Id, List<BudgetPeriod__c>> annBpListMap = new Map<Id, List<BudgetPeriod__c>>();
        Map<Id, List<AnnouncementServiceArea__c>> annAsaListMap = new Map<Id, List<AnnouncementServiceArea__c>>();
        Map<Id, List<FundingOpportunityBudgetCategory__c>> annFoBcListMap = new Map<Id, List<FundingOpportunityBudgetCategory__c>>();
        Map<Id, Map<Id, BudgetPeriod__c>> appBpIdMap = new Map<Id, Map<Id, BudgetPeriod__c>>();
        Map<Id, Map<Id, ApplicationServiceArea__c>> appAsaIdMap = new Map<Id, Map<Id, ApplicationServiceArea__c>>();

        List<BudgetPeriod__c> annBudPeriodList;
        List<AnnouncementServiceArea__c> annSaList;
        List<BudgetPeriod__c> budgetPeriodList = new List<BudgetPeriod__c>();
        List<ApplicationServiceArea__c> appSaList = new List<ApplicationServiceArea__c>();
        List<ApplicationBudgetCategory2__c> appBudCatList = new List<ApplicationBudgetCategory2__c>();
        List<BudgetPeriod__c> budPeriodList;
        List<AnnouncementServiceArea__c>  annServiceAreaList;
        List<FundingOpportunityBudgetCategory__c>  foBudList;
        Map<Id, String> annBudgetPeriodMap = new Map<Id, String>();
        BudgetPeriod__c firstBP = new BudgetPeriod__c();


        for (Application__c app : apps) {
            List<Application__c> newAppList;
            announcementIds.add(app.Announcement__c);
        }
        budPeriodList = [Select id, SupportYear__c, BudgetEndDate__c, FundingOpportunity__c, SequenceNumber__c, Notes__c, BudgetStartDate__c, Status__c
                         from BudgetPeriod__c where FundingOpportunity__c in :announcementIds];
        system.debug('BudPeriodList is:' + budPeriodList);
        annServiceAreaList = [Select Id, BudgetPeriod__c, ServiceArea__c, Announcement__c from AnnouncementServiceArea__c where Announcement__c  in :announcementIds];
        system.debug('Announcementservicearea is:' + annServiceAreaList);
        foBudList = [Select Id, FundingOpportunity__c, BudgetPeriod__c, FundingOpportunityProjectArea__c, FundingOpportunityBudgetPeriod__r.FundingOpportunityProjectArea__c , FundingOpportunityBudgetPeriod__r.BudgetPeriod__c , BudgetCategory__c
                     from FundingOpportunityBudgetCategory__c where FundingOpportunity__c in :announcementIds];
        List<Application__c> appList = [Select Id, Name, Announcement__r.BudgetingPeriod__c from Application__c where Announcement__c IN : announcementIds];
        for (BudgetPeriod__c bp : budPeriodList) {
            List<BudgetPeriod__c> newBudPeriodList;

            if (annBpListMap.get(bp.FundingOpportunity__c) <> null) {
                annBpListMap.get(bp.FundingOpportunity__c).add(bp);
            } else {
                newBudPeriodList = new List<BudgetPeriod__c>();
                newBudPeriodList.add(bp);
                annBpListMap.put(bp.FundingOpportunity__c, newBudPeriodList);
            }
        }

        for (Application__c app : appList) {
            annBudgetPeriodMap.put(app.Id, app.Announcement__r.BudgetingPeriod__c);
        }

        for (AnnouncementServiceArea__c asa : annServiceAreaList) {
            List<AnnouncementServiceArea__c> asaList;

            if (annAsaListMap.get(asa.Announcement__c) <> null) {
                annAsaListMap.get(asa.Announcement__c).add(asa);
            } else {
                asaList = new List<AnnouncementServiceArea__c>();
                asaList.add(asa);
                annAsaListMap.put(asa.Announcement__c, asaList);
            }
        }

        for (FundingOpportunityBudgetCategory__c foBc : foBudList) {
            List<FundingOpportunityBudgetCategory__c> foBcList;

            if (annFoBcListMap.get(foBc.FundingOpportunity__c) <> null) {
                annFoBcListMap.get(foBc.FundingOpportunity__c).add(foBc);
            } else {
                foBcList = new List<FundingOpportunityBudgetCategory__c>();
                foBcList.add(foBc);
                annFoBcListMap.put(foBc.FundingOpportunity__c, foBcList);
            }
        }

        for (Application__c app : apps) {
            String budPeriodSetting = annBudgetPeriodMap.get(app.Id);
            System.debug('**budPeriodSetting--' + budPeriodSetting);
            annBudPeriodList = annBpListMap.get(app.Announcement__c);
            if (annBudPeriodList <> null) {
                if (budPeriodSetting == 'Only First Budget Period') {
                    System.debug('**budPeriodSetting-only first BP-');
                    BudgetPeriod__c bp = annBudPeriodList[0];
                    BudgetPeriod__c appBp = new BudgetPeriod__c();
                    appBp.Application__c = app.Id;
                    appBp.SupportYear__c = bp.SupportYear__c;
                    appBp.BudgetEndDate__c = bp.BudgetEndDate__c;
                    appBp.Notes__c = bp.Notes__c;
                    appBp.BudgetStartDate__c = bp.BudgetStartDate__c;
                    appBp.Status__c = bp.Status__c;
                    appBp.SequenceNumber__c = bp.SequenceNumber__c;
                    firstBP = appBp;
                    budgetPeriodList.add(appBp);
                    if (appBpIdMap.get(app.Id) <> null) {
                        appBpIdMap.get(app.Id).put(bp.Id, appBp);
                    } else {
                        Map<Id, BudgetPeriod__c> bpIdMap = new Map<Id, BudgetPeriod__c>();
                        bpIdMap.put(bp.Id, appBp);
                        appBpIdMap.put(app.Id, bpIdMap);
                    }
                } else {
                    System.debug('**budPeriodSetting-all BPs-');
                    Integer count = 0;
                    System.debug('**budPeriodSetting-annBudPeriodList-' + annBudPeriodList);
                    for (BudgetPeriod__c bp : annBudPeriodList) {
                        System.debug('**budPeriodSetting-bp-' + bp);
                        BudgetPeriod__c appBp = new BudgetPeriod__c();
                        appBp.Application__c = app.Id;
                        appBp.SupportYear__c = bp.SupportYear__c;
                        appBp.BudgetEndDate__c = bp.BudgetEndDate__c;
                        appBp.Notes__c = bp.Notes__c;
                        appBp.BudgetStartDate__c = bp.BudgetStartDate__c;
                        appBp.Status__c = bp.Status__c;
                        appBp.SequenceNumber__c = bp.SequenceNumber__c;
                        if (count == 0)
                            firstBP = appBp;
                        count++;
                        budgetPeriodList.add(appBp);
                        if (appBpIdMap.get(app.Id) <> null) {
                            appBpIdMap.get(app.Id).put(bp.Id, appBp);
                        } else {
                            Map<Id, BudgetPeriod__c> bpIdMap = new Map<Id, BudgetPeriod__c>();
                            bpIdMap.put(bp.Id, appBp);
                            appBpIdMap.put(app.Id, bpIdMap);
                        }
                    }
                } // End of else
            }
        }
        if (budgetPeriodList.size() > 0) {
            insert budgetPeriodList;
        }
        for (Application__c app : apps) {
            annSaList = annAsaListMap.get(app.Announcement__c);
            if (annSaList <> null) {
                for (AnnouncementServiceArea__c asa : annSaList) {
                    ApplicationServiceArea__c appSa = new ApplicationServiceArea__c();
                    appSa.ServiceAreaLookup__c = asa.ServiceArea__c;
                    appSa.Application__c = app.Id;
                    appSa.ServiceArea__c = asa.Id;
                    if (asa.BudgetPeriod__c <> null) {
                        if (appBpIdMap.get(app.Id) <> null) {
                            if (appBpIdMap.get(app.Id).get(asa.BudgetPeriod__c) <> null) {
                                appSa.BudgetPeriod__c = ((BudgetPeriod__c)appBpIdMap.get(app.Id).get(asa.BudgetPeriod__c)).Id;
                            }
                        }
                    }
                    appSaList.add(appSa);
                    if (appAsaIdMap.get(app.Id) <> null) {
                        appAsaIdMap.get(app.Id).put(asa.Id, appSa);
                    } else {
                        Map<Id, ApplicationServiceArea__c> appIdMap = new Map<Id, ApplicationServiceArea__c>();
                        appIdMap.put(asa.Id, appSa);
                        appAsaIdMap.put(app.Id, appIdMap);
                    }

                }
            }
        }
        if (appSaList.size() > 0) {
            insert appSaList;
        }

        system.debug('foBudList--' + foBudList.size());
        system.debug('appBpIdMap--' + appBpIdMap);
        List<BudgetCategory__c> indirecCostsLst = [Select Id, CategoryName__c from BudgetCategory__c where CategoryName__c IN ('Total Indirect Costs (Applies only to Lines 1-7):', 'Indirect Costs')];
        Map<String, BudgetCategory__c> bcMap = new Map<String, BudgetCategory__c>();
        for (BudgetCategory__c bc : indirecCostsLst) {
            if (!bcMap.containsKey(bc.CategoryName__c)) {
                bcMap.put(bc.CategoryName__c, bc);
            }
        }

        for (Application__c app : apps) {

            foBudList = annFoBcListMap.get(app.Announcement__c);
            if (foBudList <> null) {
                String budgetCategoryTypeForOrg = '';
                BudgetCategory__c indirecCosts;
                if (app.GrantorOrganizationName__c == 'USBE') { //Grantor Org is USBE, need to tailor the indirect cost budget category specifically for it
                    indirecCosts = bcMap.get('Total Indirect Costs (Applies only to Lines 1-7):') ;
                } else { //Grantor org isn't USBE, continue with the standard indirect budget category logic
                    indirecCosts = bcMap.get('Indirect Costs') ;
                }

                //BudgetCategory__c indirecCosts = [Select Id from BudgetCategory__c where CategoryName__c = 'Indirect Costs' limit 1];
                if (!Test.isRunningTest()) {
                    for (BudgetPeriod__c temp : appBpIdMap.get(app.Id).values()) {
                        if (indirecCosts != null && appAsaIdMap.get(app.Id) != null && foBudList.size() > 0 && foBudList[0].FundingOpportunityProjectArea__c != null) {
                            ApplicationBudgetCategory2__c dummyIndirectCost = new ApplicationBudgetCategory2__c(Application__c = app.Id, BudgetCategory__c = indirecCosts.Id, BudgetPeriod__c = temp.Id, ServiceArea__c = ((ApplicationServiceArea__c) appAsaIdMap.get(app.Id).get(foBudList[0].FundingOpportunityProjectArea__c)).Id);
                            appBudCatList.add(dummyIndirectCost);
                        }
                        
                    }
                }
                Integer count = 0;
                for (FundingOpportunityBudgetCategory__c foBd : foBudList) {

                    ApplicationBudgetCategory2__c abc = new ApplicationBudgetCategory2__c();
                    abc.Application__c = app.Id;
                    abc.BudgetCategory__c = foBd.BudgetCategory__c;
                    if (foBd.BudgetPeriod__c <> null) {
                        if (appBpIdMap.get(app.Id) <> null) {
                            if (appBpIdMap.get(app.Id).get(foBd.BudgetPeriod__c) <> null) {
                                abc.BudgetPeriod__c = ((BudgetPeriod__c)appBpIdMap.get(app.Id).get(foBd.BudgetPeriod__c)).Id;
                                system.debug('firstBP.Id--' + firstBP.Id);
                                system.debug('abc.BudgetPeriod__c--' + abc.BudgetPeriod__c);
                                if (firstBP.Id == abc.BudgetPeriod__c)
                                    abc.IsFirstBudgetPeriodRelated__c = true;
                                system.debug('abc--' + abc);
                            }
                        }
                    }
                    if (foBd.FundingOpportunityProjectArea__c <> null) {
                        //abc.ServiceArea__c=appAsaIdMap.get(app.Id).
                        if (appAsaIdMap.get(app.Id) <> null) {
                            if (appAsaIdMap.get(app.Id).get(foBd.FundingOpportunityProjectArea__c) <> null) {
                                abc.ServiceArea__c = ((ApplicationServiceArea__c)appAsaIdMap.get(app.Id).get(foBd.FundingOpportunityProjectArea__c)).Id;
                            }
                        }
                    }
                    if (abc.BudgetPeriod__c != null && abc.ServiceArea__c != null) {
                        appBudCatList.add(abc);
                    }
                }
            }
        }
        if (appBudCatList.size() > 0) {
            insert appBudCatList;
        }
    }

    // Copies Budget Information from Pre Application in Grantor side
    private void copyBudgetDataFromPreApplication(List<Application__c> apps) {
        System.debug('--copyBudgetDataFromPreApplication------------->>>>>>>>>>>>>>>>>>>>>>');
        Set<Id> announcementIds = new Set<Id>();
        Set<Id> appIds = new Set<Id>();
        Map<Id, List<ApplicationBudgetCategory2__c>> applicationBudgetCategoriesMap =
            new Map<Id, List<ApplicationBudgetCategory2__c>>();
        Set<Id> applicationBudgetCategoryIds = new Set<Id>();
        Set<Id> preapplicationBudgetCategoryIds = new Set<Id>();
        for (Application__c app : (List<Application__c>)Trigger.new) {
            if (app.PreApplication__c != null) {
                announcementIds.add(app.Announcement__c);
                appIds.add(app.Id);
            }
        }

        if (announcementIds.isEmpty()) return;
        System.debug('--copyBudgetDataFromPreApplication------------->>>>>>>>>>>>>>>>>>>>>>' + announcementIds);

        Map<Id, PreApplication__c> preAppMap = new Map<Id, PreApplication__c>([Select Id, Name from PreApplication__c where Announcement__c in :announcementIds]);

        List<BuildUpItem__c> buildupItems = [Select Title__c, Narrative__c, StartDate__c, EndDate__c, PreApplicationBudgetCategory__c, UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c, AllowableDirect__c , Indirect__c, GrantorShare__c, GranteeShare__c from BuildUpItem__c
                                             where PreApplicationBudgetCategory__r.PreApplication__c in : preAppMap.keySet()];

        List<PreApplicationBudgetCategory__c> preapplicationBudgetCategoriesList =
            [select Id, ServiceArea__c, BudgetCategory__c, PreApplication__c,
             GrantorAmount__c, GranteeAmount__c, Amount__c, GranteeShare__c,
             ServiceArea__r.ServiceAreaLookup__c
             from PreApplicationBudgetCategory__c
             where PreApplication__c IN :preAppMap.keyset()];

        for (PreApplicationBudgetCategory__c preapp : preapplicationBudgetCategoriesList) {
            preapplicationBudgetCategoryIds.add(preapp.Id);
        }

        List<ApplicationBudgetCategory2__c> applicationBudgetCategoriesList =
            [select Id, ServiceArea__c, BudgetCategory__c, Application__c,
             GrantorAmount__c, GranteeAmount__c, Amount__c, GranteeShare__c,
             ServiceArea__r.ServiceAreaLookup__c, Application__r.PreApplication__c
             from ApplicationBudgetCategory2__c
             where Application__c IN :appIds];
        for (ApplicationBudgetCategory2__c app : applicationBudgetCategoriesList) {
            applicationBudgetCategoryIds.add(app.Id);
            if (!applicationBudgetCategoriesMap.containsKey(app.Application__c)) {
                applicationBudgetCategoriesMap.put(app.Application__c, new List<ApplicationBudgetCategory2__c>());
            }
            applicationBudgetCategoriesMap.get(app.Application__c).add(app);
        }


        Map<Id, List<BuildUpItem__c>> preappBudCatToBuildUpMap =
            new Map<Id, List<BuildUpItem__c>>();
        List<BuildUpItem__c> preapplicationbuildUpItemsList =
            [select Title__c, Narrative__c, StartDate__c, EndDate__c, ApplicationBudgetCategory__r.Application__r.AmountThisAction__c,
             PreApplicationBudgetCategory__r.PreApplication__r.GranteeRequestedAmount__c, UnitPrice__c, Quantity__c, UnitofMeasurement__c, OtherCharges__c,
             TotalDirect__c, AllowableDirect__c , Indirect__c, TotalIndirect__c,
             GrandTotal__c, GrantorShare__c, GranteeShare__c,
             ApplicationBudgetCategory__c
             from BuildUpItem__c
             where PreApplicationBudgetCategory__c IN :preapplicationBudgetCategoryIds];

        for (BuildUpItem__c buildUpItem : preapplicationbuildUpItemsList) {
            if (!preappBudCatToBuildUpMap.containsKey(buildUpItem.preApplicationBudgetCategory__c)) {
                preappBudCatToBuildUpMap.put(buildUpItem.preApplicationBudgetCategory__c, new List<BuildUpItem__c>());
            }
            preappBudCatToBuildUpMap.get(buildUpItem.preApplicationBudgetCategory__c).add(buildUpItem);
        }

        List<BuildUpItem__c> appBuildUpItems = new List<BuildUpItem__c>();
        system.debug('------------preappBudCatToBuildUpMap----->>>>>>>>>>>>>>>>>>>>>>>>' + preappBudCatToBuildUpMap);

        system.debug('-------------applicationBudgetCategoriesList---->>>>>>>>>>>>>>>>>>>>>>>>' + applicationBudgetCategoriesList);
        system.debug('------------preapplicationBudgetCategoriesList----->>>>>>>>>>>>>>>>>>>>>>>>' + preapplicationBudgetCategoriesList);
        for (ApplicationBudgetCategory2__c appBC : applicationBudgetCategoriesList) {
            for (PreApplicationBudgetCategory__c preappBC : preapplicationBudgetCategoriesList) {
                List<BuildUpItem__c> preappbuildupitems = new List<BuildUpItem__c>();
                system.debug('------------preappbuildupitems----->>>>>>>>>>>>>>>>>>>appBC>>>>' + appBC);
                system.debug('------------preappbuildupitems----->>>>>>>>>>>>>>>>>>>preappBC>>>>>' + preappBC);

                if (appBC.Application__r.PreApplication__c == preappBC.PreApplication__c &&
                        preappBC.BudgetCategory__c.equals(appBC.BudgetCategory__c)
                        && preappBC.ServiceArea__r.ServiceAreaLookup__c.equals(
                            appBC.ServiceArea__r.ServiceAreaLookup__c)) {
                    system.debug('------------preappbuildupitems----->>>>>>>>>>>>>>>>>>>preappBC.Id>>>>>' + preappBC.Id);
                    if (preappBudCatToBuildUpMap.containsKey(preappBC.Id)) {
                        system.debug('------------preappbuildupitems----->>>>>>>>>>>>>>>>>>>inside>>>>>');
                        preappbuildupitems = preappBudCatToBuildUpMap.get(preappBC.Id);
                    }
                    system.debug('------------preappbuildupitems----->>>>>>>>>>>>>>>>>>>>>>>>' + preappbuildupitems);

                    for (BuildUpItem__c buildUpItem : preappbuildupitems) {
                        BuildUpItem__c appBuildUpItem = new BuildUpItem__c();
                        appBuildUpItem.Title__c = buildUpItem.Title__c;
                        appBuildUpItem.Narrative__c = buildUpItem.Narrative__c;
                        appBuildUpItem.StartDate__c = buildUpItem.StartDate__c;
                        appBuildUpItem.EndDate__c = buildUpItem.EndDate__c;
                        appBuildUpItem.UnitPrice__c = buildUpItem.UnitPrice__c;
                        appBuildUpItem.Quantity__c = buildUpItem.Quantity__c;
                        appBuildUpItem.UnitofMeasurement__c = buildUpItem.UnitofMeasurement__c;
                        appBuildUpItem.OtherCharges__c = buildUpItem.OtherCharges__c;
                        appBuildUpItem.AllowableDirect__c = buildUpItem.AllowableDirect__c;
                        appBuildUpItem.Indirect__c = buildUpItem.Indirect__c;
                        appBuildUpItem.GrantorShare__c = buildUpItem.GrantorShare__c;
                        appBuildUpItem.ApplicationBudgetCategory__c = appBC.Id;
                        appBuildUpItems.add(appBuildUpItem);
                    }
                }
            }
        }
        system.debug('----------------->>>>>>>>>>>>>>>>>>>>>>>>' + appBuildUpItems);
        insert appBuildUpItems;
    }

    private void addDefaultFundingOppServiceArea() {
        Set<Id> announcementIds = new Set<Id>();
        List<AnnouncementServiceArea__c> defAnnServiceArea = new  List<AnnouncementServiceArea__c>();
        for (Application__c app : (List<Application__c>)Trigger.new) {
            List<Application__c> newAppList;
            announcementIds.add(app.Announcement__c);
        }

        Map<Id, List<AnnouncementServiceArea__c>> annAsaListMap = new Map<Id, List<AnnouncementServiceArea__c>>();
        List<AnnouncementServiceArea__c>  annServiceAreaList = [Select Id, BudgetPeriod__c, ServiceArea__c, Announcement__c from AnnouncementServiceArea__c where Announcement__c  in :announcementIds];

        for (AnnouncementServiceArea__c asa : annServiceAreaList) {
            List<AnnouncementServiceArea__c> asaList;

            if (annAsaListMap.get(asa.Announcement__c) <> null) {
                annAsaListMap.get(asa.Announcement__c).add(asa);
            } else {
                asaList = new List<AnnouncementServiceArea__c>();
                asaList.add(asa);
                annAsaListMap.put(asa.Announcement__c, asaList);
            }
        }

        announcementIds.removeAll(annAsaListMap.keySet());

        List<ServiceArea__c> lstServiceArea = [Select Id from ServiceArea__c where Default__c = true];
        if (lstServiceArea.size() == 0) {
            for (Application__c app : (List<Application__c>)Trigger.new) {
                system.debug('***Sarat ' + GNT.ErrorMessageHelper.fetchMessage('P32-GRNTE-90074'));
                app.addError(GNT.ErrorMessageHelper.fetchMessage('P32-GRNTE-90074'));
                //app.addError('Test Message Sarat');
            }
        }

        if (lstServiceArea.size() != 0) {
            for (Id oppId : announcementIds) { // If no service Area is defined in the Opportunity then insert the Default Service Area
                AnnouncementServiceArea__c annServiceArea = new AnnouncementServiceArea__c();
                annServiceArea.Announcement__c = oppId;
                annServiceArea.ServiceArea__c = lstServiceArea[0].Id;
                defAnnServiceArea.add(annServiceArea);
            }
        }

        insert defAnnServiceArea;
    }

    /*update  No of Applications on External Organization*/
    //private void UpdateExtOrgNoofApplications(List<Application__c> lstapp){
    //    Set<Id> orgIds = new Set<Id>();
    //    for (Application__c app : lstapp) {
    //    if (app.ExternalOrganization__c != null) {
    //        orgIds.add(app.ExternalOrganization__c);
    //    }
    //   }
    //  List<Account> acctsToRollup = new List<Account>();
    //  for (AggregateResult ar : [SELECT ExternalOrganization__c orgId, Count(id) appCount
    //                           FROM Application__c
    //                           WHERE ExternalOrganization__c in: orgIds
    //                           GROUP BY ExternalOrganization__c]){
    //    Account a = new Account();
    //    a.Id = (Id) ar.get('orgId');
    //    a.NumberOfApplications__c = (Integer) ar.get('appCount');
    //    if(Trigger.isbefore && Trigger.isdelete && (ar.get('appCount')==1)){
    //        a.NumberOfApplications__c = 0;
    //    }
    //    acctsToRollup.add(a);
    //  }
    //    SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
    //    SystemContextMethodsHelper.updateAccounts(acctsToRollup);
    //}

    /* Charan - This method is used to delete all Reviewers task when the Status of Application is changed to Reviewed */
    private void deleteTasksForReviewers(List<Application__c> apps) {
        List<String> appIds = new List<String>();
        for (Application__c app : apps) {
            if (app.Status__c == 'Reviewed') {
                appIds.add(app.Name);
            }
        }
        List<Task> tsk = [SELECT Id FROM Task WHERE TrackingNumberLink1__c in:appIds and GNT__TaskAction__c in ('Review Application (Grantee)', 'Review Application') AND Status in ('Not Started', 'In Progress')];
        delete tsk;
    }

    private void updateAllBudgetCategories(List<Application__c> apps, List<Application__c> oldApps) {
        System.debug('MANUALDEBUG---Inside updateAllBudgetCategories');
        System.debug('MANUALDEBUG---Applications updated: ' + apps);
        System.debug('MANUALDEBUG---Grantor Org = ' + apps[0].GrantorOrganizationName__c);
        List<ApplicationBudgetCategory2__c> lst = [
                    SELECT Id, CatName__c, BudgetCategory__r.Name, BudgetCategory__r.RowNumber__c, BudgetAmountUSBE__c, TotalGrantCost__c, InKind__c, CashMatch__c, Federal__c, Amount__c, Application__r.TotalIndirectCost__c, Application__r.IndirectCostPercentage__c, Application__c, AdminCostValue__c, Application__r.TotalAdminCost__c, ProjectBudgetPlusAdminCost__c
                    FROM ApplicationBudgetCategory2__c
                    WHERE Application__c IN: apps];
        AggregateResult[] aggs = [Select Application__c appId, Sum(Federal__c)indSum from ApplicationBudgetCategory2__c where Application__c IN :apps AND CatName__c NOT IN ('Indirect Costs', 'Equipment') Group By Application__c];
        for (Application__c applicationIterator : apps) {
            if (applicationIterator.GrantorOrganizationName__c == 'USBE') {
                Application__c currOldApp;
                for (Application__c oldAppIterator : oldApps) {
                    if (oldAppIterator.Id == applicationIterator.Id) { currOldApp = oldAppIterator; }
                }
                Boolean buildupCategoryModified = false;
                for (ApplicationBudgetCategory2__c abc : lst) {
                    if (applicationIterator.Id == abc.Application__c) {
                        if (abc.BudgetCategory__r.RowNumber__c == '570') {
                            abc.BudgetAmountUSBE__c = abc.Amount__c.setScale(2);
                            if (applicationIterator.ProgramBudgetTypeUSBE__C == 'CTE') { abc.Federal__c = abc.ProjectBudgetPlusAdminCost__c; }
                            else { abc.Federal__c = abc.BudgetAmountUSBE__c; }
                            buildupCategoryModified = true;
                        } else if (abc.BudgetCategory__r.RowNumber__c == '599') {
                            if (buildupCategoryModified == true || applicationIterator.IndirectCostPercentage__c != currOldApp.IndirectCostPercentage__c) { //The buildup budget categories are modified here but we're skipping the ApplicationBudgetCategory trigger (to avoid uneeded recursion) so just update the indirect cost here. Also if the indirect cost percentage was modified we need to recalculate the total indirect cost
                                Decimal totalIndirectVal = 0;
                                Decimal totalAdminIndirect = 0;
                                for (ApplicationBudgetCategory2__c abc2 : lst) {
                                    if (abc2.BudgetCategory__r.RowNumber__c != '570' && abc2.BudgetCategory__r.RowNumber__c != '580' && abc2.BudgetCategory__r.RowNumber__c != '599') {
                                        totalIndirectVal += abc2.BudgetAmountUSBE__c;
                                        if (applicationIterator.ProgramBudgetTypeUSBE__c == 'CTE') {
                                            totalAdminIndirect += abc2.AdminCostValue__c;
                                        }
                                    }

                                }
                                abc.BudgetAmountUSBE__c = (totalIndirectVal * (abc.Application__r.IndirectCostPercentage__c / 100)).setScale(2);
                                if (applicationIterator.ProgramBudgetTypeUSBE__c == 'CTE') {
                                    abc.AdminCostValue__c = (totalAdminIndirect * (abc.Application__r.IndirectCostPercentage__c / 100)).setScale(2);
                                }
                            } else {
                                abc.BudgetAmountUSBE__c = abc.Application__r.TotalIndirectCost__c;
                                if (applicationIterator.ProgramBudgetTypeUSBE__c == 'CTE') {
                                    abc.AdminCostValue__c = abc.Application__r.TotalAdminCost__c;
                                }
                            }
                            System.debug('MANUALDEBUG---budgetAmountUSBE = ' + abc.BudgetAmountUSBE__c);
                            if (applicationIterator.ProgramBudgetTypeUSBE__C == 'CTE') { abc.Federal__c = abc.ProjectBudgetPlusAdminCost__c; }
                            else { abc.Federal__c = abc.BudgetAmountUSBE__c; }
                            abc.Amount__c = abc.BudgetAmountUSBE__c.setScale(2);
                        } else {
                            if (applicationIterator.ProgramBudgetTypeUSBE__C == 'CTE') { abc.Federal__c = abc.ProjectBudgetPlusAdminCost__c; }
                            else { abc.Federal__c = abc.BudgetAmountUSBE__c; }
                            abc.Amount__c = abc.BudgetAmountUSBE__c.setScale(2);
                        }
                    }
                }
            } else {
                Map<String, Decimal> appIndMap = new Map<String, Decimal>();
                for (AggregateResult agg : aggs) {
                    appIndMap.put(String.valueOf(agg.get('appId')), (Decimal)agg.get('indSum'));
                }
                for (ApplicationBudgetCategory2__c abc : lst) {
                    if (abc.CatName__c == 'Indirect Costs') {
                        abc.Federal__c = (appIndMap.get(abc.Application__c) * abc.Application__r.IndirectCostPercentage__c / 100).setScale(2);
                        abc.InKind__c = 0;
                        abc.CashMatch__c = 0;
                        abc.Amount__c = abc.Federal__c.setScale(2);
                        //}else if(!(abc.BudgetCategory__r.Name == 'Equipment')){
                    } else {
                        abc.TotalGrantCost__c = (abc.Federal__c + abc.Federal__c * abc.Application__r.IndirectCostPercentage__c / 100).setScale(2);
                        abc.Amount__c = (abc.Federal__c + abc.InKind__c + abc.CashMatch__c).setScale(2);
                    }
                }
                //update lst;
            }
        }
        ApplicationBudgetCategoryTriggerHelper.skipTrigger = true;
        update lst;
        ApplicationBudgetCategoryTriggerHelper.skipTrigger = false;
    }



    private void pullIndirectCostFromVendorProfile(Map<Id, Application__c> applicationMap, List<Application__c> triggerList) { //USBE creates multiple applications automatically via the excel upload
        //On application creation, if this is a USBE application we need to pull the indirect cost % from the corresponding LEA's profile
        System.debug('MANUALDEBUG >>> triggerList: ' + triggerList);
        List<Id> programIdList = new List<Id>();
        List<Id> leaIdList = new List<Id>();
        for (Application__c appIterator : triggerList) {
            appIterator.IndirectCostPicklist__c = 'Yes';
            programIdList.add(appIterator.ProgramId__c);
            leaIdList.add(appIterator.ExternalOrganization__c);
        }
        System.debug('MANUALDEBUG >>> programIdList: ' + programIdList);
        System.debug('MANUALDEBUG >>> leaIdList: ' + leaIdList);

        //Map program Id to it's indirect cost type
        System.debug('MANUALDEBUG >>> programIdListSize: ' + programIdList.size());
        List<Program__c> testProgList = new List<Program__c>([SELECT Id, USBEIndirectCostRate__c FROM Program__c WHERE USBEIndirectCostRate__c = : 'Restricted']);
        System.debug('MANUALDEBUG >>> testProgList: ' + testProgList);
        List<Program__c> programList = new List<Program__c>([SELECT Id, USBEIndirectCostRate__c FROM Program__c WHERE Id = : programIdList]);
        System.debug('MANUALDEBUG >>> programList: ' + programList);
        Map<Id, String> programIdMapIndirect = new Map<Id, String>();
        //for (Program__c programIterator : [SELECT Id, USBEIndirectCostRate__c FROM Program__c WHERE Id IN: programIdList]) {
        for (Program__c programIterator : programList) {
            System.debug('MANUALDEBUG >>> programIterator: ' + programIterator);
            programIdMapIndirect.put(programIterator.Id, programIterator.USBEIndirectCostRate__c);
        }
        System.debug('MANUALDEBUG >>> programIdMapIndirect: ' + programIdMapIndirect);


        //Create map of LEA to USBELEACostRate__c
        Map<Id, USBELEACostRate__c> leaMapIndirectObject = new Map<Id, USBELEACostRate__c>();
        List<USBELEACostRate__c> leaCostRateList = new List<USBELEACostRate__c>([SELECT Id, Account__c, Year__r.StartDate__c, Year__r.EndDate__c, UnrestrictedIndirectRate__c, RestrictedIndirectRate__c FROM USBELEACostRate__c WHERE Account__c IN: leaIdList]);
        System.debug('MANUALDEBUG >>> leaCostRateList: ' + leaCostRateList);
        for (Application__c appIterator : triggerList) {
            //Indirect cost object where the LEA is among the ones we want to create applications for and is of the fiscal year that the application applies to
            USBELEACostRate__c mostRecentIndirectObj;
            for (USBELEACostRate__c costRateObjIterator : leaCostRateList) {
                //Pull the intial fiscal year of the application and use that to get the indirect object which is of that fiscal year for that LEA
                System.debug('MANUALDEBUG >>> costRateObjIterator: ' + costRateObjIterator);
                if (costRateObjIterator <> null) {
                    if (appIterator.ExternalOrganization__c == costRateObjIterator.Account__c && costRateObjIterator.Year__r.StartDate__c <= appIterator.ProjectPeriodStartDate__c) {
                        if (mostRecentIndirectObj == null) {
                            mostRecentIndirectObj = costRateObjIterator;
                        } else {
                            if (costRateObjIterator.Year__r.StartDate__c >= mostRecentIndirectObj.Year__r.StartDate__c && costRateObjIterator.Year__r.EndDate__c >= mostRecentIndirectObj.Year__r.EndDate__c) {
                                mostRecentIndirectObj = costRateObjIterator;
                            }
                        }
                    }
                }
            }
            if (mostRecentIndirectObj <> null && mostRecentIndirectObj.Account__c <> null ) {
                System.debug('Debug Account ' + mostRecentIndirectObj);
                System.debug('Debug Obj ' + mostRecentIndirectObj.Account__c);

                leaMapIndirectObject.put(mostRecentIndirectObj.Account__c, mostRecentIndirectObj); //Map the indirect object of the right fiscal year to the LEA
            }
        }
        System.debug('MANUALDEBUG >>> leaMapIndirectObject: ' + leaMapIndirectObject);
        System.debug('MANUALDEBUG >>> leaCostRateList' + leaCostRateList);

        //Now go and assign the application's indirect rate from it's LEA's vendor profile
        for (Application__c appIterator : triggerList) {
            Id programId = appIterator.ProgramId__c; //Id of the program for the application
            String indirectType = programIdMapIndirect.get(programId); //Restricted or unrestricted
            Id leaId = appIterator.ExternalOrganization__c; //LEA's Id
            USBELEACostRate__c currentCostRateObj = leaMapIndirectObject.get(leaId); //The indirect object of the application's starting fiscal year for that LEA
            System.debug('MANUALDEBUG >>> appIteratorId' + appIterator.Id + ' programId: ' + programId + ' indirectType: ' + indirectType + ' leaId: ' + leaId + ' currentCostRateObj:' + currentCostRateObj);

            if (currentCostRateObj != null) {
                if (indirectType == 'Restricted') {
                    appIterator.IndirectCostPercentage__c = currentCostRateObj.RestrictedIndirectRate__c;
                } else if (indirectType == 'Unrestricted') {
                    appIterator.IndirectCostPercentage__c = currentCostRateObj.UnrestrictedIndirectRate__c;
                }
            }

        }
    }


    private void budgetUploadApplicationEmailTask(List<Application__c> triggerList) {
        List<Application__c> appList = new List<Application__c>();
        List<Id> userIdList = new List<Id>();
        for (Application__c appIter : triggerList) {
            if (appIter.GrantorOrganizationName__c == 'USBE' && appIter.CreatedByBudgetUpload__c == true) { //Is a USBE program that was created via budget upload
                appList.add(appIter);
                userIdList.add(appIter.OwnerId);
            }
        }
        if (appList.size() > 0) {
            List<User> userList = [SELECT Id, ContactId FROM User WHERE Id IN: userIdList];
            Map<Id, Id> userIdMapContactId = new Map<Id, Id>();
            Set<Id> contactIdSet = new Set<Id>();
            Map<Id, Set<Id>> userIdMapContactIdSet = new Map<Id, Set<Id>>();
            for (User userIter : userList) {
                userIdMapContactId.put(userIter.Id, userIter.ContactId);
                contactIdSet.add(userIter.ContactId);
            }
            Map<Id, Id> appIdMapContactId = new Map<Id, Id>();
            Map<Id, Set<Id>> appIdMapContactIdSet = new Map<Id, Set<Id>>();
            for (Application__c appIter : appList) {
                Set<Id> currAppContactIdSet = new Set<Id>();
                currAppContactIdSet.add(userIdMapContactId.get(appIter.OwnerId));
                appIdMapContactIdSet.put(appIter.Id, currAppContactIdSet);
                appIdMapContactId.put(appIter.Id, userIdMapContactId.get(appIter.OwnerId));
            }
            List<Task> taskList = new List<Task>();
            EmailTemplate templateEmail = [SELECT Id FROM EmailTemplate WHERE Name = 'Award ready for subrecipient approval' LIMIT 1];
            for (Application__c appIter : appList) {
                //List<Task> appTask = GNT.TaskCreationHandler.createTasks(appIter.OwnerId, appIter.Id, 'Complete and Submit Application', appIter.Name, null, false, System.TODAY() + 7, 'Other', appIter.Announcement__r.Name, false);
                List<Task> appTask = GNT.TaskCreationHandler.createTasks(appIter.OwnerId, appIter.Id, 'Complete and Submit Application', appIter.Name, null, false, System.TODAY() + 7, 'Other', appIter.Name, false);
                taskList.addAll(appTask);

                Id currentContact = appIdMapContactId.get(appIter.Id);
            }
            //Insert tasks to complete the application
            if (!taskList.isEmpty()) { insert taskList; }
            //Send email notifications
            GNT.AppUtils.sendEmailUsingTemplate(templateEmail.Id, appIdMapContactId, false);
        }
    }


    private void notifyGrantorWaiveWithdraw(List<Application__c> triggerListOld, List<Application__c> triggerList) {
        System.debug('MANUALDEBUG >>> In notifyGrantorWaiveWithdraw');
        List<Id> appIdList = new List<Id>();
        for (Application__c appIter : triggerList) {
            for (Application__c oldAppIter : triggerListOld) {
                //This is a USBE application created from a budget upload which just passed through the waive/withdraw internal approval process
                if (oldAppIter.Id == appIter.Id && appIter.GrantorOrganizationName__c == 'USBE' && appIter.CreatedByBudgetUpload__c == true && (appIter.WaiveWithdraw__c == 'Waive' || appIter.WaiveWithdraw__c == 'Withdraw') && (appIter.Status__c == 'Internally Reviewed')) {
                    System.debug('MANUALDEBUG >>> entered conditions for creating task and email');
                    appIdList.add(appIter.Id);
                }
            }
        }
        System.debug('MANUALDEBUG >>> appIdList : ' + appIdList);
        //Create a task and email for the SPI internal approver to notify the grantor when the internal approver approves the waive/withdraw of the application
        if (appIdList.size() > 0) {
            approvalNotifyGrantorWaiveWithdraw(appIdList);
        }
    }

    @future
    private static void approvalNotifyGrantorWaiveWithdraw(List<Id> appIdList) {
        System.debug('MANUALDEBUG >>> approvalNotifyGrantorWaiveWithdraw entered');
        List<Application__c> appList = [SELECT Id, Approver__c, WaiveWithdraw__c, Name FROM Application__c WHERE Id IN: appIdList];
        List<Task> taskList = new List<Task>();
        for (Application__c appIter : appList) {
            List<Task> appTask = GNT.TaskCreationHandler.createTasks(appIter.Approver__c, appIter.Id, ('Notify Grantor Of Application ' + appIter.WaiveWithdraw__c), appIter.Name, null, false, System.TODAY() + 7, 'Other', appIter.Name, false);
            taskList.addAll(appTask);
        }
        //Insert tasks to complete the application
        if (!taskList.isEmpty()) { insert taskList; }
    }
    
    private void pullBAFromLEAProfile(List<Application__c> appListUSBE) {
        List<Id> leaIds = new List<Id>();
        for (Application__c appIterator : appListUSBE) {
            leaIds.add(appIterator.ExternalOrganization__c);
        }
        Map<Id, Id> leaMapBA= new Map<Id, Id>();
        List<Account> leaList = [SELECT Id, UserBA__c FROM Account WHERE Id IN: leaIds];
        for (Account accountIterator : leaList) {
            leaMapBA.put(accountIterator.Id, accountIterator.UserBA__c);
        }
        if (leaList.size() > 0) {
            for (Application__c appIterator : appListUSBE) {
                if (leaMapBA.get(appIterator.ExternalOrganization__c) != null) {
                    appIterator.Approver__c = leaMapBA.get(appIterator.ExternalOrganization__c);
                    appIterator.LEAKeyPOC__c = leaMapBA.get(appIterator.ExternalOrganization__c);
                }   
            }
        }
    }
    
}