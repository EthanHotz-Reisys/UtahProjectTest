public with sharing class ProgramTriggerHelperUSBE extends GNT.TriggerHelper {
    public static boolean skipTrigger = false;
    private Map<Id, String> recordIdNameMap = new Map<Id, String>();
    public override void processBeforeInsert() {
        GNT.NameTemplateTriggerHelper.beforeInsert();
        shareWithInternalUsers(Trigger.new);
        checkGovGrantsKey(Trigger.new);
    }

    public override void processAfterInsert() {
        if (skipTrigger == false) {
            //Logic to create Review Step Templates, Review Panels for Grantor Programs
            Map<Id, RecordType> recordIdMap = new  Map<Id, RecordType>([Select Id, Name from RecordType where sObjectType = :'Program__c']);
            for (String Key : recordIdMap.keyset()) {
                recordIdNameMap.put(key, recordIdMap.get(key).Name);
            }
            List<Program__c> programList = new List<Program__c>();
            for (Program__c prg : (List<Program__c>)Trigger.new) {
                if (recordIdNameMap.get(prg.RecordTypeId) == 'Internal Program') {
                    programList.add(prg);
                }
            }
            createProgramSpecificRSTemplates(programList);
            addDefaultPackages(programList);
            InsertBudgetPerioddates(programList);
            insertOwnerinRolesandResp(programList);
            insertProgrammaticContactinProgramContact(programList);
            //insertOwnerinProgramContact(programList);
            insertPlaceholderRoles((List<Program__c>) Trigger.New);
        }
        shareWithExe(Trigger.new);
    }

    public override void processBeforeUpdate() {
        updateShareWithInternalUsers();
        //createSentToOwnerGratorTask();
        checkGovGrantsKey(Trigger.new);
    }

    public override void processAfterUpdate() {
        if (skipTrigger == false) {
            //deleteApprovalProcess();
            insertProgrammaticContactAfterUpdate(Trigger.new);
            updateReviewers(Trigger.new);
        }
    }

    public void createProgramSpecificRSTemplates(List<Program__c> programlst) {
        List<ReviewStepTemplate__c> lstRST = [
                SELECT Id, Name, StepNumber__c, Description__c
                FROM ReviewStepTemplate__c
                WHERE DefaultStep__c = true AND CustomAppName__c = 'StateasGrantor' AND Announcement__c = null AND Program__c = null];
        System.debug('lstRST: ' + lstRST);
        GNT__PageTemplate__c rsLayoutForStep123 = [Select id From GNT__PageTemplate__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_Step123Layout', true)];
        GNT__PageTemplate__c rsLayoutForStep4 = [Select id From GNT__PageTemplate__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_StepLayout4', true)];
        GNT__PageTemplate__c panelLayout = [Select id From GNT__PageTemplate__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_PanelLayout', true)];
        //  GNT__Package__c prescreenPackage = [Select Id From GNT__Package__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_PrescreenReviewPackage', true)];
        //  GNT__Package__c externalPackage = [Select Id From GNT__Package__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_ExternalReviewPackage', true)];
        //  GNT__Package__c internalPackage = [Select Id From GNT__Package__c Where Name = :GNT.KeyValueStoreHelper.getTextValue('RST_InternalReviewPackage', true)];
        // Test debug statements which can be removed
        EmailTemplate approvalTemplate = [Select DeveloperName From EmailTemplate Where DeveloperName = :GNT.KeyValueStoreHelper.getTextValue('RST_ApplicationPromotedEmail', true) LIMIT 1];
        EmailTemplate rejectionTemplate = [Select DeveloperName From EmailTemplate Where DeveloperName = :GNT.KeyValueStoreHelper.getTextValue('RST_ApplicationRejectionEmail', true) LIMIT 1];
        String approvalTempName = approvalTemplate.DeveloperName;
        String rejectionTempName = rejectionTemplate.DeveloperName;
        List<ReviewStepTemplate__c> rstList = new List<ReviewStepTemplate__c>();
        List<ReviewPanelTemplate__c> rptList = new List<ReviewPanelTemplate__c>();
        //  Id rsLayoutId = rsLayoutForStep123.Id;
        Id rsLayoutId = rsLayoutForStep123.Id;
        for (Program__c prog : (List<Program__c>)trigger.new) { //
            for (ReviewStepTemplate__c rstObj : lstRST) {
                if (prog.ReviewProcess__c == 'One step review' && (rstObj.StepNumber__c == 1 || rstObj.StepNumber__c == 4)) { //This is a one-step review process, so only create the Prescreen and FDM review step templates
                    // create review step template
                    ReviewStepTemplate__c rst = createReviewStepTemplate(prog.Id, rstObj.Name, rstObj.Description__c , rsLayoutId, Integer.valueOf(rstObj.StepNumber__c),  approvalTempName, rejectionTempName);
                    rst.ReviewTypeName__c = (rstObj.StepNumber__c == 1) ? 'One Step Review' : 'Funding Decision Memo';
                    rstList.add(rst);
                } else if (prog.ReviewProcess__c != null && prog.ReviewProcess__c == 'No Review') {
                    continue;
                } else if (prog.ReviewProcess__c == null || prog.ReviewProcess__c == 'Three step review') {
                    // create review step template
                    ReviewStepTemplate__c rst = createReviewStepTemplate(prog.Id, rstObj.Name, rstObj.Description__c , rsLayoutId, Integer.valueOf(rstObj.StepNumber__c),  approvalTempName, rejectionTempName);
                    rst.ReviewTypeName__c = rstObj.Name;
                    rstList.add(rst);
                }
            }
        }
        insert rstList;
        for (ReviewStepTemplate__c rst : rstList) {
            if (rst.StepNumber__c != 4) {
                ReviewPanelTemplate__c rpt = createReviewPanelTemplate(rst, panelLayout.Id);
                rptList.add(rpt);
            }
        }
        insert rptList;
    }

    private void addDefaultPackages(List<Program__c> lstPrograms) {
        List<BusinessPackage__c> programDefPack = new List<BusinessPackage__c>();
        List<BusinessPackage__c> defaultPackList = [
                    Select GrantorOrgWideDefault__c, ApplicationName__c, PackageConfig__c, PackageType__c
                    from BusinessPackage__c
                    where PackageType__c in('App-Review') and ApplicationName__c = :'StateAsGrantor' and GrantorOrgWideDefault__c = :true ];
        /*
        List<BusinessPackage__c> defaultPackListOneStepApproval = [
            SELECT GrantorOrgWideDefault__c,ApplicationName__c,PackageConfig__c,PackageType__c
            FROM BusinessPackage__c
            WHERE PackageType__c IN('Application Review Package One Step') AND ApplicationName__c=:'StateAsGrantor' AND UniquePackageName__c = 'OneStepReviewPackage'];
        */
        List<BusinessPackage__c> defaultPackListOneStepApproval = [
                    SELECT GrantorOrgWideDefault__c, ApplicationName__c, PackageConfig__c, PackageType__c
                    FROM BusinessPackage__c
                    WHERE PackageType__c IN('App-Review') AND ApplicationName__c = :'StateAsGrantor' AND UniquePackageName__c = 'OneStepReviewPackage'];

        if ( defaultPackList != null || defaultPackListOneStepApproval != null ) { // removing the Size check when moved to new org  && defaultPackList.size()==5
            for (Program__c prog : lstPrograms) {
                if (prog.ReviewProcess__c == 'One step review') {
                    for (BusinessPackage__c pack : defaultPackListOneStepApproval) {
                        BusinessPackage__c defaultPack = new BusinessPackage__c();
                        defaultPack.Program__c = prog.Id;
                        defaultPack.PackageConfig__c = pack.PackageConfig__c;
                        defaultPack.PackageType__c  = pack.PackageType__c;
                        programDefPack.add(defaultPack);
                    }
                } else if (prog.ReviewProcess__c == 'No Review') {
                    continue;
                } else {
                    for (BusinessPackage__c pack : defaultPackList) {
                        BusinessPackage__c defaultPack = new BusinessPackage__c();
                        defaultPack.Program__c = prog.Id;
                        defaultPack.PackageConfig__c = pack.PackageConfig__c;
                        defaultPack.PackageType__c  = pack.PackageType__c;
                        programDefPack.add(defaultPack);
                    }
                }
            }
            insert programDefPack;
        }
    }

    public ReviewStepTemplate__c createReviewStepTemplate(Id recordId, String name, String description , Id revStepTemplateId, Integer stepNumber,  String approvalTemplate, String rejectionTemplate) {
        ReviewStepTemplate__c rst =  new ReviewStepTemplate__c();
        rst.ReviewLevelAcceptance__c = false;
        rst.UserType__c = 'Internal';
        rst.Name = name;
        rst.StepNumber__c = stepNumber;
        rst.RecordTypeId = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        rst.Description__c = description;
        rst.Program__c = recordId;
        rst.ReviewStepLayout__c = revStepTemplateId;
        rst.RejectionEmailTemplate__c = rejectionTemplate;
        rst.ApprovalEmailTemplate__c = approvalTemplate;
        rst.PanelHeadAssignNotificationTemplate__c = 'NotificationofPanelAssignment';
        return rst;
    }

    public ReviewPanelTemplate__c createReviewPanelTemplate(ReviewStepTemplate__c rst, Id panelLayoutId) {
        ReviewPanelTemplate__c rpt = new ReviewPanelTemplate__c();
        rpt.RecordTypeId = Schema.SObjectType.ReviewPanelTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        rpt.name = rst.name + ' Panel';
        rpt.Chair__c = UserInfo.getUserId();
        rpt.Sequence__c = 1;
        rpt.ReviewStepTemplate__c = rst.Id;
        rpt.IsDefaultPanel__c = true;
        rpt.ReviewFormConfig__c = rst.ReviewFormConfig__c;
        rpt.Description__c = 'Panel created for ' + rst.Description__c;
        rpt.PanelLayout__c = panelLayoutId;
        rpt.EndDate__c = System.Today() + 7;
        rpt.Purpose__c = rst.name + ' Description';
        if (rst.StepNumber__c == 2) {
            rpt.UserType__c = 'External';
            rpt.ExcludeFromScoring__c = false;
        } else {
            rpt.UserType__c = 'Internal';
            rpt.ExcludeFromScoring__c = true;
        }
        return rpt;
    }

    /*Insert BudgetPeriod Records Based on Project Period Start Date and Project period End date*/
    private void InsertBudgetPerioddates(List<Program__c> lstPrograms) {
        List<BudgetPeriod__c> lstbp = new List<BudgetPeriod__c>();
        for (Program__c program : (List<Program__c>) lstPrograms) {
            BudgetPeriod__c budgetPeriod = new BudgetPeriod__c();
            budgetPeriod.SupportYear__c = 'BP-01';
            budgetPeriod.BudgetStartDate__c = program.StartDate__c;
            budgetPeriod.BudgetEndDate__c = program.EndDate__c;
            budgetPeriod.SequenceNumber__c = 0;
            budgetPeriod.Program__c = program.id;
            budgetPeriod.Status__c = 'Active';
            lstbp.add(budgetPeriod);
        }
        if (!lstbp.isempty())
            insert lstbp;
    }
    /* Insert owner of Award in Roles and Responsibility*/

    private void insertOwnerinRolesandResp(List<Program__c> programList) {
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'RolesAndResponsibilities__c' and DeveloperName = 'Program'];
        for (Program__c program : (List<Program__c>) programList) {
            RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
            rresp.Program__c = program.id;
            rresp.Name__c = program.CreatedById;
            //rresp.Role__c = 'Other';
            rresp.BusinessRole__c = 'Owner';
            rresp.recordTypeId = recordTypeList[0].Id;
            listrolesandresp.add(rresp);
        }
        if (!listrolesandresp.isempty()) {
            insert listrolesandresp;
        }
    }

    /*private void deleteApprovalProcess() {
        List<Id> sentToOwnerProgramIds = new List<Id>();

        Map<Id, Program__c> oldPgm = (Map<Id, Program__c>)Trigger.oldMap;
        for (Program__c newPgmVal : (List<Program__c>)Trigger.new) {
            if (newPgmVal.Status__c == 'Change Requested' && oldPgm.get(newPgmVal.Id).Status__c == 'Submitted for Approval') {
                Approval.ProcessWorkItemRequest pwr = new Approval.ProcessWorkItemRequest();
                List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :newPgmVal.Id]);
                // Retrieve the process work instance id associated to the process instance
                List<ProcessInstanceWorkitem>  workitem = new List<ProcessInstanceWorkitem>([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id]);
                if ((workitem != null) && (workitem.size() > 0)) {
                    pwr.SetComments('statusToUpdate');

                    pwr.setWorkItemId(workitem[0].id);
                    pwr.setAction('Removed');
                    // Execute process request
                    Approval.ProcessResult pr = Approval.process(pwr);
                }
            }
        }
    }*/
    //This method will be called after recall functionality.
    /*private void createSentToOwnerGratorTask() {
        List<Id> sentToOwnerProgramIds = new List<Id>();
        List<Task> appTaskList = new List<Task>();
        Map<Id, Program__c> oldPgm = (Map<Id, Program__c>)Trigger.oldMap;

        for (Program__c newPgmVal : (List<Program__c>)Trigger.new) {
            if (newPgmVal.Status__c == 'Created' && oldPgm.get(newPgmVal.Id).Status__c == 'Change Requested') {
                sentToOwnerProgramIds.add(newPgmVal.Id);
                newPgmVal.Status__c = 'Change Requested';
            }
        }
        for (Id pgmId : sentToOwnerProgramIds) {
            appTaskList.add( GNT.TaskCreationHandler.createTasks(oldPgm.get(pgmId).OwnerId, pgmId, 'Program Sent To Owner', oldPgm.get(pgmId).Name, null, false, null, 'Other', oldPgm.get(pgmId).ProgramName__c, false).get(0));
        }
        if (Schema.sObjectType.Program__c.isCreateable()) {
            insert appTaskList;
        }
        System.debug('appTaskList--------------------------->' + appTaskList);

    }*/

    private void shareWithInternalUsers(List<Program__c> lstPrograms) {
        for (Program__c prg : lstPrograms) {
            prg.ProgGroupCode__c = prg.ProgramGroupCode__c;
        }
    }

    private void updateShareWithInternalUsers() {
        for (Program__c prog : (List<Program__c>) Trigger.new) {
            Program__c oldProg = (Program__c) Trigger.oldMap.get(prog.Id);
            if (prog.ProgramGroupCode__c != oldProg.ProgramGroupCode__c) {
                prog.ProgGroupCode__c = prog.ProgramGroupCode__c;
            }
        }
    }

    private void shareWithExe(List<Program__c> lstPrograms) {
        List<Program__Share> shares = new List<Program__Share>();
        List<User> exeList = [SELECT Id FROM User WHERE Profile.Name = 'EXE' AND IsActive = TRUE];

        for (Program__c program : lstPrograms) {
            for (User exe : exeList) {
                shares.add(new Program__Share(parentId = program.id, AccessLevel = 'Edit', UserOrGroupId = exe.Id, RowCause = Schema.Program__Share.RowCause.SharingForEXE__c));
            }
        }

        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.updatePrograms(shares);
    }

    /* When the program is approved copy the name of Agency from Formula to Text for Internal and NGO programs */
    //private void copyAgencyNameToTextField(){

    //    Map<Id,RecordType> recordIdMap = new  Map<Id,RecordType>([Select Id,Name from RecordType where sObjectType =:'Program__c']);
    //    for(String Key:recordIdMap.keyset()){
    //            recordIdNameMap.put(key, recordIdMap.get(key).Name);
    //    }

    //    for(Program__c prg: (List<Program__c>)Trigger.new){

    //          Program__c oldProg = (Program__c)Trigger.oldMap.get(prg.Id);
    //          Program__c newProg = (Program__c)Trigger.newMap.get(prg.Id);

    //         if((recordIdNameMap.get(prg.RecordTypeId)=='Internal Program' || recordIdNameMap.get(prg.RecordTypeId)=='NGO Program') &&
    //            (oldProg.Status__c != 'Approved' && newProg.Status__c == 'Approved')){
    //            prg.InternalOrganization__c = prg.OrganizationName__c;
    //        }
    //    }
    //}

    private void insertOwnerinProgramContact(List<Program__c> programList) {
        List<ProgramContacts__c> programContact = new List<ProgramContacts__c>();
        List<Id> programOwnerIds = new List<Id>();
        Map<Id, Id> userToContact = new Map<Id, Id>();
        for (Program__c program : programList) {
            programOwnerIds.add(program.CreatedById);
        }
        List<Contact> contactsList = [Select id, UserReference__c from Contact where UserReference__c = :programOwnerIds];
        for (Contact contactSingle : contactsList) {
            userToContact.put(contactSingle.UserReference__c, contactSingle.Id);
        }
        for (Program__c program : programList) {
            ProgramContacts__c progCont = new ProgramContacts__c();
            progCont.Program__c = program.Id;
            progCont.Contact__c = userToContact.get(program.CreatedById);
            programContact.add(progCont);
        }
        if (!programContact.isempty()) {
            insert programContact;
        }
    }

    private void insertProgrammaticContactinProgramContact (List<Program__c> programList) {
        List<ProgramContacts__c> programContact = new List<ProgramContacts__c>();
        for (Program__c program : programList) {
            if (program.ProgrammaticContact__c != null) {
                ProgramContacts__c progCont = new ProgramContacts__c();
                progCont.Program__c = program.Id;
                progCont.Contact__c = program.ProgrammaticContact__c;
                programContact.add(progCont);
            }
        }
        insert programContact;
    }


    private void insertProgrammaticContactAfterUpdate (List<Program__c> newPrograms) {
        List<ProgramContacts__c> programContact = new List<ProgramContacts__c>();
        List<ID> ProgcontactIDsToBeDeleted = new List<ID>();
        for (Program__c newProg : newPrograms) {
            Program__c oldProg = (Program__c) Trigger.OldMap.get(newProg.Id);
            if (oldProg.ProgrammaticContact__c != newProg.ProgrammaticContact__c) {
                if (newProg.ProgrammaticContact__c != null){
                    ProgramContacts__c progCont = new ProgramContacts__c();
                    progCont.Program__c = newProg.Id;
                    progCont.Contact__c = newProg.ProgrammaticContact__c;
                    programContact.add(progCont);
                }
                if (oldProg.ProgrammaticContact__c != null){
                    ProgcontactIDsToBeDeleted.add(oldProg.ProgrammaticContact__c);
                }
            }
        }
        if (ProgcontactIDsToBeDeleted.size() > 0){
            List<ProgramContacts__c> programContacttoBeDeleted = [Select id from ProgramContacts__c where Contact__c IN:ProgcontactIDsToBeDeleted];
            delete programContacttoBeDeleted;
        }
        insert programContact;
    }

    private void updateReviewers (List<Program__c> programList) {
        Set<Id> programIds = new Set<Id>();
        Set<Id> gmIds = new Set<Id>();
        for (Program__c program : programList) {
            Program__c programOld = (Program__c) Trigger.OldMap.get(program.Id);
            if (program.GrantsManager__c != programOld.GrantsManager__c) {
                programIds.add(program.Id);
                gmIds.add(programOld.GrantsManager__c);
            }
        }

        if (programIds.size() > 0) {
            List<ReviewPanelTemplate__c> panelList = [SELECT Id, ReviewStepTemplate__r.Program__c FROM ReviewPanelTemplate__c WHERE ReviewStepTemplate__r.Name = 'Pre-Screen Review' AND ReviewStepTemplate__r.Program__c IN: programIds];
            List<PanelUserTemplate__c> gmList = [SELECT Id, Reviewer__c, ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c FROM PanelUserTemplate__c WHERE
                                                 Reviewer__c IN: gmIds AND ReviewPanelTemplate__r.ReviewStepTemplate__r.Name = 'Pre-Screen Review' AND ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c IN: programIds];

            Map<Id, ReviewPanelTemplate__c> panelMap = new Map<Id, ReviewPanelTemplate__c>();
            for (ReviewPanelTemplate__c panel : panelList) {
                panelMap.put(panel.ReviewStepTemplate__r.Program__c, panel);
            }

            Map<Id, PanelUserTemplate__c> gmMap = new Map<Id, PanelUserTemplate__c>();
            for (PanelUserTemplate__c gm : gmList) {
                gmMap.put(gm.ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c, gm);
            }

            List<PanelUserTemplate__c> newReviewers = new List<PanelUserTemplate__c>();
            List<PanelUserTemplate__c> oldReviewers = new List<PanelUserTemplate__c>();
            for (Program__c program : programList) {
                ReviewPanelTemplate__c panel = panelMap.get(program.Id);
                PanelUserTemplate__c gm = gmMap.get(program.Id);
                Program__c programOld = (Program__c) Trigger.OldMap.get(program.Id);

                if (program.GrantsManager__c != null && panel != null) {
                    PanelUserTemplate__c newReviewer = new PanelUserTemplate__c();
                    newReviewer.Reviewer__c = program.GrantsManager__c;
                    newReviewer.ReviewPanelTemplate__c = panel.Id;
                    newReviewers.add(newReviewer);
                }

                if (gm != null && programOld.GrantsManager__c == gm.Reviewer__c) {
                    oldReviewers.add(gm);
                }
            }
            delete oldReviewers;
            Savepoint sp = Database.setSavepoint();
            try{
                insert newReviewers;
            }
            catch(Exception e){
                Database.rollback(sp);
            }
        }
    }

    private void checkGovGrantsKey(List<Program__c> programnew) {
        Set<String> keySet = new Set<String>();
        Set<Id> programIds = new Set<Id>();
        for (Program__c program : programnew){
            if (program.ProgramKey__c != null){
                keySet.add(program.ProgramKey__c);
            }
            programIds.add(program.Id);
        }
        List<Program__c> programList = [Select Id,ProgramKey__c from Program__c where ProgramKey__c IN: keySet AND Id NOT IN: programIds];
        for (Program__c program : programList){
            for (Program__c newProgram : programnew){
                if (program.ProgramKey__c == newProgram.ProgramKey__c){
                    newProgram.addError('The GovGrants program key already exists please enter a unique value');
                }
            }
        }
    }
    
    
    private void insertPlaceholderRoles(List<Program__c> triggerList) {
        Set<String> programRecordTypes = new Set<String>{'ProgramUSBE', 'ProgramUploadUSBE'};
        Set<String> uploadProgramPathways = new Set<String>{'MPS', 'Lump-Sum-No-App'};
        Map<Boolean, String> isUploadPathwayMapRecordType = new Map<Boolean, String> {
            true => 'ProgramUploadUSBE',
            false => 'ProgramUSBE' 
        };
    
        Map<String, Set<String>> recordTypeMapBusinessRole = new Map<String, Set<String>>{
            'ProgramUSBE' => new Set<String>{'Executive Approver', 'Program Approver', 'Grants Manager', 'Award Approver 1', 'Award Approver 2', 'Payment Approver 1', 'Payment Approver 2', 'Payment Approver 3', 'Payment Approver 4'},
            'ProgramUploadUSBE' => new Set<String>{'Executive Approver', 'Program Approver', 'Grants Manager', 'Award Approver 1', 'Award Approver 2', 'Payment Approver 1', 'Payment Approver 2'} 
        };
    
        Map<String, Id> recordTypeNameMapRecordTypeId = new Map<String, Id>();
        List<RecordType> recordTypes = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE DeveloperName IN: programRecordTypes AND sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
        for (RecordType recordTypeIterator : recordTypes) {
            recordTypeNameMapRecordTypeId.put(recordTypeIterator.DeveloperName, recordTypeIterator.Id);
        }
    
        List<RolesAndResponsibilities__c> rrInsertList = new List<RolesAndResponsibilities__c>();
        for (Program__c programIterator : triggerList) {
            String recordTypeName = isUploadPathwayMapRecordType.get(uploadProgramPathways.contains(programIterator.ProgramPathway__c));
            Id currentRecordTypeId = recordTypeNameMapRecordTypeId.get(recordTypeName);
            Set<String> businessRoleSet = recordTypeMapBusinessRole.get(recordTypeName);
            for (String businessRoleIterator : businessRoleSet) {
                RolesAndResponsibilities__c addRole = new RolesAndResponsibilities__c();
                addRole.Agency__c = programIterator.Account__c; //The roles for a program will always be for someone of that agency/org
                addRole.RecordTypeId = currentRecordTypeId;
                addRole.UserType__c = 'User';
                addRole.ChangeChildObjects__c = 'Update All Derivative Records';
                addRole.InsertType__c = 'N/A';
                addRole.BusinessRole__c = businessRoleIterator;
                addRole.Program__c =  programIterator.Id;
                addRole.Name__c = null;
                rrInsertList.add(addRole);  
            }       
        }
    
        if (rrInsertList.size() > 0) {
            RolesAndRespTriggerHelperUSBE.skipTrigger = true;
            insert rrInsertList;
            RolesAndRespTriggerHelperUSBE.skipTrigger = false;
        }
    }
    
}