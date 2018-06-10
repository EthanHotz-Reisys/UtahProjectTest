/*
    All code for Trigger on Roles and Responsibilities Object
    ***********************************************************
    Audit History
    ***********************************************************
    05/29/2015      Ramu Loke             Created
    08/30/2015      Vinayak Sharma        Edited
    07/14/2017      Charan Mareedu        Refactored the Code
    2017-09-21      Shah Kadirmohideen            Code Reviewed
    02/07/2018      Harshada Kale                 Code Review Fixed
    ***********************************************************
*/

public with sharing class RolesandResponsibilitiesTriggerHelper extends GNT.TriggerHelper {

    // The Roles Wrapper contains the field Name and Api Name of a SObject.
    // The purpose of the class is to store the api field Names of the particular
    //      object because the naming of api fields are different from each SObject.s
    //  Eg: for Announcement the 'Program Approver' api field is 'ProgramApprover__c' where as
    //      for Award the 'Program Approver' api field is 'POUser__c'.
    // Since we are copying the Id of user to respective SObject it is necessary to
    //      storing the field API names.
    public class RoleWrapper {
        public String roleName;
        public String userLookupFieldName;

        public RoleWrapper(String roleName, String userLookupFieldName) {
            this.roleName = roleName;
            this.userLookupFieldName = userLookupFieldName;
        }
    }

    // The SObject Wrapper Stores the Role Wrapper List along with other required values.
    // The Other fields are used to store the action String for grantor or grantee for the
    //       given SObject.
    // Eg: Task action for Announcement on grantor side 'Review Grantor Announcement' and
    //      on grantee side is 'Review the opportunity'.
    // hasRecordType tells which app side of the app we are dealing with and is set to false
    //   and has grantee side as default and can be set to true when dealing on grantor side.
    // If we need to deal with any other actions in future it can be added here.=
    public class SObjectWrapper {
        public List<RoleWrapper> roles;
        // public Map<String,String> fieldMap=new Map<String,String>();
        public String grantorTaskAction; //default
        public String granteeTaskAction;
        public Boolean hasRecordType = false;
        public String relationTitle;
        public String helperText;
        public SObjectWrapper(List<RoleWrapper> roles, String grantorTaskAction,
                String granteeTaskAction, Boolean hasRecordType,
                String relationTitle,String helperText) {
            this.roles = roles;
            this.grantorTaskAction=grantorTaskAction;
            this.granteeTaskAction=granteeTaskAction;
            this.hasRecordType = hasRecordType;
            this.relationTitle=relationTitle;
            this.helperText=helperText;
        }
        public SObjectWrapper(List<RoleWrapper> roles,String granteeTaskAction,String relationTitle,String helperText){
            this.roles=roles;
            this.granteeTaskAction=granteeTaskAction;
            this.relationTitle=relationTitle;
            this.helperText=helperText;
        }
        public SObjectWrapper(List<RoleWrapper> roles){
            this.roles=roles;
        }
    }

    // wrapMap map stores the SObjectWrapper along with the SObject API name.
    // Eg: wrapMap[0]=['Announcement__c',SObjectWrapper];
    public static Map<String, SObjectWrapper> wrapMap = new Map<String, SObjectWrapper>();
    private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    public static boolean skipTrigger = false;
    public static Map<String,String> shareParentObjs=new Map<String,String>();

    // All the API Field name are initialized in the static block which is common for a given
    //     R&R r
    // 'Review Application (Grantee)','Review Pre-Application (Grantee)','Review the opportunity'
    static{
        List<RoleWrapper> appRoles=new List<RoleWrapper>();
        appRoles.add(new RoleWrapper('Fiscal Approver','FiscalApproval__c'));
        appRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('Application__c',new SObjectWrapper(appRoles,'Review Application (Grantee)',
                'Title__c','Review Application'));
        List<RoleWrapper> amdRoles=new List<RoleWrapper>();
        amdRoles.add(new RoleWrapper('Fiscal Approver','FiscalApprover__c'));
        amdRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        amdRoles.add(new RoleWrapper('Executive Approver', 'ExecutiveApprover__c'));
        amdRoles.add(new RoleWrapper('Owner','AwardOwner__c'));
        wrapMap.put('AmendmentRequest__c',new SObjectWrapper(amdRoles));
        List<RoleWrapper> annRoles=new List<RoleWrapper>();
        annRoles.add(new RoleWrapper('Fiscal Approver','FinancialApprover__c'));
        annRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        annRoles.add(new RoleWrapper('Key POC','PointofContact__c'));
        annRoles.add(new RoleWrapper('Executive Approver','Executive__c'));
        annRoles.add(new RoleWrapper('Program Reviewer','AnnouncementReviewer__c'));
        wrapMap.put('Announcement__c',new SObjectWrapper(annRoles,'Review Grantor Announcement',
                'Review the opportunity',true,
                'AnnouncementName__c','Other'));
        List<RoleWrapper> preAppRoles=new List<RoleWrapper>();
        preAppRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        preAppRoles.add(new RoleWrapper('Fiscal Approver','Fiscal_Approver__c'));
        wrapMap.put('PreApplication__c',new SObjectWrapper(preAppRoles,'Review Pre-Application (Grantee)',
                'Title__c','Review Pre-Application'));
        List<RoleWrapper> awdRoles=new List<RoleWrapper>();
        awdRoles.add(new RoleWrapper('Fiscal Approver','FOUser__c'));
        awdRoles.add(new RoleWrapper('Program Approver','POUser__c'));
        awdRoles.add(new RoleWrapper('Executive Approver','Comptroller__c'));
        awdRoles.add(new RoleWrapper('Grants Administrator','GrantAdministrator__c'));
        wrapMap.put('Award__c',new SObjectWrapper(awdRoles));
        List<RoleWrapper> clsOutRoles=new List<RoleWrapper>();
        clsOutRoles.add(new RoleWrapper('Program Approver','POApprover__c'));
        clsOutRoles.add(new RoleWrapper('Fiscal Approver','FOApprover__c'));
        wrapMap.put('Closeout__c', new SObjectWrapper(clsOutRoles));
        List<RoleWrapper> rskAssRoles=new List<RoleWrapper>();
        rskAssRoles.add(new RoleWrapper('Program Approver','Approver__c'));
        wrapMap.put('RiskAssessment__c', new SObjectWrapper(rskAssRoles));
        List<RoleWrapper> prgmRoles=new List<RoleWrapper>();
        prgmRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('Program__c', new SObjectWrapper(prgmRoles));
        List<RoleWrapper> proRprtRoles=new List<RoleWrapper>();
        proRprtRoles.add(new RoleWrapper('POC','EmailPOC__c'));
        proRprtRoles.add(new RoleWrapper('Fiscal Approver','FiscalApprover__c'));
        proRprtRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('ProgressReports__c', new SObjectWrapper(proRprtRoles));
        List<RoleWrapper> pmtReqRoles=new List<RoleWrapper>();
        pmtReqRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        pmtReqRoles.add(new RoleWrapper('Fiscal Approver','FiscalApprover__c'));
        wrapMap.put('PaymentRequest__c', new SObjectWrapper(pmtReqRoles));        
        List<RoleWrapper> siteVstRoles=new List<RoleWrapper>();
        siteVstRoles.add(new RoleWrapper('POC','EmailPOC__c'));
        siteVstRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('SiteVisit__c', new SObjectWrapper(siteVstRoles));
        List<RoleWrapper> finetPrograms =new List<RoleWrapper>();
        finetPrograms.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('r_prog__c', new SObjectWrapper(finetPrograms));
        shareParentObjs.put('Program__c','Program__c');
        shareParentObjs.put('Announcement__c','Announcement__c');
        shareParentObjs.put('Application__c','Application__c');
        shareParentObjs.put('AmendmentRequest__c','AmendmentRequest__c');
        shareParentObjs.put('PreApplication__c','PreApplication__c');
        shareParentObjs.put('Closeout__c','Grant__c');
        shareParentObjs.put('RiskAssessment__c','RiskAssessment__c');
        shareParentObjs.put('ProgressReports__c','ProgressReports__c');
        shareParentObjs.put('SiteVisit__c','SiteVisit__c');
        shareParentObjs.put('Award__c', 'Grant__c');
        shareParentObjs.put('Grant__c','Grant__c');
        shareParentObjs.put('StrategicPlan__c', 'StrategicPlan__c');
        shareParentObjs.put('PaymentRequest__c', 'PaymentRequest__c');
        shareParentObjs.put('r_prog__c', 'r_prog__c');
    }

    // CheckForDuplicates will take true or false to denote before insert or update.
    public override void processBeforeInsert() {
        System.debug('before insert');
        if (skipTrigger == false) {
            checkForDuplicates();
            insertRoles('Grantor && Grantee');
            populateOrganization();
            //updateQueueName();
        }
    }

    // creatTask takes boolean where true denotes grantor side.
    public override void processAfterInsert() {
        System.debug('after insert');
        if (skipTrigger == false) {
            if (appName == 'StateasGrantor' && skipTrigger == false) {
                insertRoles('Grantor');
                createTask('Grantor');
            }else if (appName == 'StateasGrantee' && skipTrigger == false) {
                createTask('Grantee');
                insertRoles('Grantee');
            }
            else if(appName=='Recipient' && skipTrigger==false){
                new SystemContextMethodsHelper().insertAmdRequestRoles();
            }
            notifyRoleViaEmail();
            upsertGrantRR();
            handleShares();
        }
    }

    public override void processBeforeUpdate() {
        if (skipTrigger == false) {
            //updatingAccesstoUsers();
            checkForDuplicates();
            updateRoles();
        }
    }

    public override void processAfterUpdate() {
        if(skipTrigger == false){
            updateOwnerOrTaskForReviewer();
            updateRoles();
            notifyRoleViaEmail();
            upsertGrantRR();
            handleShares();
        }
    }

    public override void processBeforeDelete() {
        if (skipTrigger == false) {
            deleteRoles();
            if (appName == 'StateasGrantee') {
                deleteTask('Grantee');
            } else if (appName == 'StateasGrantor') {
                deleteTask('Grantor');
            }
        }
    }

    public override void processAfterDelete() {
        if (skipTrigger == false) {
            deleteGrantRR();
            handleShares();
        }
    }

    //When RR is deleted for award or closeout records, the same RR must be deleted from the related grant record
    private void deleteGrantRR() {
        System.debug('deleteGrantRR starts');
        List<RolesAndResponsibilities__c> eligibleRRs = new List<RolesAndResponsibilities__c>();
        Set<Id> childIds = new Set<Id>();
        for (RolesAndResponsibilities__c rr : (List<RolesAndResponsibilities__c>) Trigger.Old) {        
            if (rr.Award__c != null || rr.Closeout__c != null) {
                eligibleRRs.add(rr);
                childIds.add(rr.Id);
            }
        }
        
        Map<Id, RolesAndResponsibilities__c> rrMap = new Map<Id, RolesAndResponsibilities__c>();
        List<RolesAndResponsibilities__c> grantRRs = [Select Id, SourceRRId__c, GrantLookupId__c from RolesAndResponsibilities__c where Grant__c != null and SourceRRId__c in :childIds];
        for (RolesAndResponsibilities__c grantRR : grantRRs) {
            rrMap.put(grantRR.SourceRRId__c, grantRR);
        }

        List<RolesAndResponsibilities__c> deleteRRs = new List<RolesAndResponsibilities__c>();

        for (RolesAndResponsibilities__c childRR : eligibleRRs) {
            RolesAndResponsibilities__c grantRR = rrMap.get(childRR.Id);
            if (grantRR != null) {
                deleteRRs.add(grantRR);
            } 
        }

        delete deleteRRs;
    }

    private RolesAndResponsibilities__c cloneRR(RolesAndResponsibilities__c src) {
        RolesAndResponsibilities__c newRR = src.clone(false);
        newRR.Id = null;
        newRR.Grant__c = src.GrantLookupId__c;
        newRR.Award__c = null;
        newRR.Closeout__c = null;
        newRR.SourceRRId__c = src.Id;
        newRR.EmailNotificationStatus__c = 'Processed';
        newRR.FormsValidated__c = true;
        newRR.Notify__c = false;
        newRR.Status__c = null;
        newRR.TaskCreated__c = true;
        newRR.InternalUniqueID__c = null;
        newRR.RecordTypeId = Schema.SObjectType.RolesAndResponsibilities__c.getRecordTypeInfosByName().get('Grant').getRecordTypeId();
        return newRR;
    }

    private void copyRR(RolesAndResponsibilities__c src, RolesAndResponsibilities__c target) {
        target.QueueId__c = src.QueueId__c;
        target.Name__c = src.Name__c;
        target.BatchSharing__c = src.BatchSharing__c;
        target.BusinessRole__c = src.BusinessRole__c;
        target.Position__c = src.Position__c;
        target.Responsibility__c = src.Responsibility__c;
        target.UserType__c = src.UserType__c;
    }

    //When RR is updated for award or closeout records, the corresponding RR for grant should be updated so that both records are in sync.
    private void upsertGrantRR() {
        System.debug('upsertGrantRR starts');
        List<RolesAndResponsibilities__c> eligibleRRs = new List<RolesAndResponsibilities__c>();
        Set<Id> childIds = new Set<Id>();
        for (RolesAndResponsibilities__c rr : (List<RolesAndResponsibilities__c>) Trigger.New) {        
            if (rr.Award__c != null || rr.Closeout__c != null) {
                eligibleRRs.add(rr);
                childIds.add(rr.Id);
            }
        }
        
        Map<Id, RolesAndResponsibilities__c> rrMap = new Map<Id, RolesAndResponsibilities__c>();
        List<RolesAndResponsibilities__c> grantRRs = [Select Id, SourceRRId__c, GrantLookupId__c from RolesAndResponsibilities__c where Grant__c != null and SourceRRId__c in :childIds];
        for (RolesAndResponsibilities__c grantRR : grantRRs) {
            rrMap.put(grantRR.SourceRRId__c, grantRR);
        }

        List<RolesAndResponsibilities__c> insertRRs = new List<RolesAndResponsibilities__c>();
        List<RolesAndResponsibilities__c> updateRRs = new List<RolesAndResponsibilities__c>();

        for (RolesAndResponsibilities__c childRR : eligibleRRs) {
            RolesAndResponsibilities__c grantRR = rrMap.get(childRR.Id);
            if (grantRR != null) {
                copyRR(childRR, grantRR);
                updateRRs.add(grantRR);
            } 
            else {
                grantRR = cloneRR(childRR);
                insertRRs.add(grantRR);
            }
        }

        insert insertRRs;
        update updateRRs;
    }

    private void handleShares() {
        System.debug('handleShares starts');
        List<RolesAndResponsibilities__c> rrList = null;
        if (Trigger.isDelete) {
            rrList = Trigger.old;
        }
        else {
            rrList = Trigger.new;
        }

        Map<String, List<RolesAndResponsibilities__c>> objectMap = new Map<String, List<RolesAndResponsibilities__c>>();  //share object name
        for (RolesAndResponsibilities__c rr : rrList) {
            if (String.isNotEmpty(rr.ShareParentId__c)) {
                List<RolesAndResponsibilities__c> innerList = objectMap.get(rr.ShareObjectName__c);
                if (innerList == null) {
                    innerList = new List<RolesAndResponsibilities__c>();
                    objectMap.put(rr.ShareObjectName__c, innerList);
                }
                innerList.add(rr);
                 System.debug('SHAREOBJECTLIS=======>'+rr);
            }
        }

        for (String shareObjectName : objectMap.keySet()) {
            rrList = objectMap.get(shareObjectName);
            System.debug(shareObjectName);
            System.debug('Testing==>'+rrList);
            processShares(shareObjectName, rrList);
        }
    }

    private void processShares(String shareObjectName, List<RolesAndResponsibilities__c> rrList) {
        System.debug('processShares starts');
        System.debug('CharanTest====>'+rrList);
        List<Id> parentIds = new List<Id>();
        for (RolesAndResponsibilities__c rr : rrList) {
            parentIds.add(rr.ShareParentId__c);
        }
        System.debug('ShareSobjectName'+shareObjectName);
        System.debug(parentIds);
        deleteExistingShares(shareObjectName, parentIds);

        //Fetch all R&R records for the parents
        String soql = 'Select Id, Name__c, QueueId__c, ParentObjectId__c, ShareObjectName__c, ShareParentId__c, ShareAccessLevel__c from RolesAndResponsibilities__c where ' +
                rrList.get(0).ParentLookupFieldName__c + ' in (\'' + AppUtils.concatenate(parentIds, '\',\'') + '\') ';
        System.debug('soql: ' + soql);
        Map<Id, List<RolesAndResponsibilities__c>> parentMap = new Map<Id, List<RolesAndResponsibilities__c>>();  //key->parent record id
        for (RolesAndResponsibilities__c rr : Database.query(soql)) {
            List<RolesAndResponsibilities__c> innerList = parentMap.get(rr.ParentObjectId__c);
            if (innerList == null) {
                innerList = new List<RolesAndResponsibilities__c>();
                parentMap.put(rr.ParentObjectId__c, innerList);
            }
            innerList.add(rr);
        }
        System.debug('parentMap: ' + parentMap);

        List<SObject> newShares = new List<SObject>();
        for (Id parentId : parentMap.keySet()) {
            List<RolesAndResponsibilities__c> subRRList = parentMap.get(parentId);
            System.debug('parentId: ' + parentId + ', subRRList: ' + subRRList);
            for (RolesAndResponsibilities__c rr : subRRList) {
                newShares.add(prepareShareRecord(rr.ShareObjectName__c, rr.ShareParentId__c, String.isNotEmpty(rr.QueueId__c) ? rr.QueueId__c : rr.Name__c, rr.ShareAccessLevel__c));
            }
        }
        System.debug('newShares: ' + newShares);
        new SystemContextMethodsHelper().insertSObjectList(newShares);
    }

    private void deleteExistingShares(String shareObjectName, List<Id> parentIds) {
        String soql = 'Select Id from ' + shareObjectName + ' where ParentId in (\'' + AppUtils.concatenate(parentIds, '\',\'') + '\') ' +
                'and RowCause=\'SharingforReviewandApproval__c\'';
        System.debug('soql: ' + soql);
        List<SObject> shares = Database.query(soql);
        new SystemContextMethodsHelper().deleteSobjectList(shares);
        System.debug('shares deleted: ' + shares.size());
    }

    private SObject prepareShareRecord(String shareObjectName, Id parentId, String userOrGroupId, String accesslevel) {
        SObject share = (SObject) Type.forName(shareObjectName).newInstance();
        share.put('UserOrGroupId', userOrGroupId);
        share.put('AccessLevel', accesslevel);
        share.put('RowCause', 'SharingforReviewandApproval__c');
        share.put('ParentId', parentId);
        return share;
    }

    // Helper method to generate query string to get relationship fields in generalizing TaskCreation.
    private String getTaskQueryString(Map<String,String> taskImpSObjectAndTitle){
        String queryStart='Select Name__c, TaskCreated__c,ParentObjectId__c,Notify__c, BusinessRole__c';
        String queryBody='';
        String queryEnds=' from  RolesAndResponsibilities__c where Id in ';
        for(String sobjectName:taskImpSObjectAndTitle.keySet()){
            String sObjNameRelation=sobjectName.substring(0, sobjectName.length()-1)+'r';
            queryBody+=','+sobjectName+','+ sObjNameRelation+'.'+'OwnerId'+
                    ','+ sObjNameRelation+'.'+'Name,'+sObjNameRelation+'.Status__c,'+
                    sObjNameRelation+'.Id,'+sObjNameRelation+'.'+
                    +taskImpSObjectAndTitle.get(sobjectName);
        }
        return queryStart+queryBody+queryEnds;
    }

    // Helper method to get sObjectName for a given Roles Record.
    private String getObjectName(Id parentId){
        System.debug('PARENTID========>'+parentId);
        Schema.SObjectType sobjectType = parentId.getSObjectType();
        return sobjectType.getDescribe().getName();
    }

    // Helper Method to assign values for the SObject which takes the ObjectName,SObject,BusinessRole and Id which should be assigned
    private SObject updateSObjFields(String sObjName,SObject sObj,String businessRole,Id name){
        List<SObject> lst=new List<SObject>();
        SObjectWrapper wrapperVar=wrapMap.get(sObjName);
        List<RoleWrapper> roleWrap=wrapperVar.roles;
        for(RoleWrapper obj:roleWrap){
            if(obj.roleName==businessRole){
                sObj.put(obj.userLookupFieldName,name);
                lst.add(sObj);
            }
        }
        if(lst.isEmpty()){
            return null;
        }
        else{
            return lst[0];
        }
    }

    // Helper method to check if the object already exists in map or create a new object.
    private SObject checkOrCreateSObject(Map<Id,SObject> parentSObjs,Id parentId,Schema.SObjectType sobjectType){
        if(!parentSObjs.containsKey(parentId)){
            parentSObjs.put(parentId,sobjectType.newSObject(parentId));
        }
        return parentSObjs.get(parentId);
    }


    private void createTask(String recordType){
        System.debug('createTask starts');
        List<Id> rolesId=new List<Id>();
        Map<Id,String> objIdName=new Map<Id,String>();
        String query;
        Map<String,String> taskImpSObjectAndTitle=new Map<String,String>();
        List<RolesAndResponsibilities__c> newRecords=new List<RolesAndResponsibilities__c>();
        List<Task> newTaskList=new List<Task>();
        taskImpSObjectAndTitle.put('Announcement__c','AnnouncementName__c');
        taskImpSObjectAndTitle.put('PreApplication__c','Title__c');
        taskImpSObjectAndTitle.put('Application__c','Title__c');
        for(RolesAndResponsibilities__c record:(List<RolesAndResponsibilities__c>) Trigger.new){
            if(record.BusinessRole__c.contains('Reviewer') && record.ParentObjectId__c!=null && record.Notify__c == true){
                rolesId.add(record.Id);
                Id sObjectId=record.ParentObjectId__c;
                Schema.SObjectType sobjectType = sObjectId.getSObjectType();
                String sobjectName = sobjectType.getDescribe().getName();
                SObjectWrapper wrapperVar=wrapMap.get(sobjectName);
                if(taskImpSObjectAndTitle.keySet().contains(sobjectName)){
                    objIdName.put(sObjectId,sobjectName);
                }
            }
        }
        if(objIdName.size()>0){
            query=getTaskQueryString(taskImpSObjectAndTitle) + GNT.AppUtils.soqlList(rolesId);
            System.debug(query);
            newRecords=Database.query(query);
        }
        for(RolesAndResponsibilities__c record:newRecords){
            System.debug(record);
            String objName=objIdName.get(record.ParentObjectId__c);
            SObjectWrapper wrapperVar=wrapMap.get(objName);
            String relationTitle=wrapperVar.relationTitle;
            String sObjNameRelation=objName.substring(0, objName.length()-1)+'r';
            SObject relationObj=record.getSObject(sObjNameRelation);
            Id sObjId=(Id)relationObj.get('Id');
            String status=(String)relationObj.get('Status__c');
            String name=(String)relationObj.get('Name');
            Id parentOwnerId=(Id)relationObj.get('OwnerId');
            String title=(String)relationObj.get(relationTitle);
            if(status!= 'Approved'){
                List<Task> tsk;
                if(recordType=='Grantor'){

                    tsk=GNT.TaskCreationHandler.createTasks(record.Name__c,sObjId, wrapperVar.grantorTaskAction, name, null, false,
                            System.TODAY() + 7, 'Other', title, false);
                }
                else{
                    tsk = GNT.TaskCreationHandler.createTasks(record.Name__c,record.ParentObjectId__c,
                            wrapperVar.granteeTaskAction, name, null, false,
                            null, 'Other', title, false);
                }
                System.debug(tsk);
                if(!tsk.isEmpty()){
                    newTaskList.addAll(tsk);
                }
            }
        }
        System.debug(newTaskList);
        if(!newTaskList.isEmpty()){
            insert newTaskList;
        }
    }

    private void deleteTask(String recordType){
        Set<String> grantorSObjectList=new Set<String>{'Announcement__c'};
        Set<String> grantorTaskActnStrgs=new Set<String>{'Review Grantor Announcement'};
        Set<String> granteeSObjectList=new Set<String>{'Announcement__c','PreApplication__c','Application__c'};
        Set<String> granteeTaskActnStrgs=new Set<String>{};
        granteeTaskActnStrgs.add('Review Application (Grantee)');
        granteeTaskActnStrgs.add('Review Pre-Application (Grantee)');
        granteeTaskActnStrgs.add('Review the opportunity');
        Set<String> grantorSObjIds=new Set<String>();
        Set<String> granteeSObjIds=new Set<String>();
        List<Task> tasksToBeDeleted;
        for(RolesAndResponsibilities__c record:(List<RolesAndResponsibilities__c>) Trigger.old){
            if(record.BusinessRole__c.contains('Reviewer') && record.Notify__c == true && record.ParentObjectId__c != null){
                String sobjectName = getObjectName(record.ParentObjectId__c);
                if(recordType=='StateasGrantor'){
                    if(grantorSObjectList.contains(sobjectName)){
                        grantorSObjIds.add(record.ParentObjectId__c);
                    }
                }
                else{
                    if(grantorSObjectList.contains(sobjectName)){
                        granteeSObjIds.add(record.ParentObjectId__c);
                    }
                }
            }
        }
        // There is another condition that should be checked before deleting the task Eg:Announcement__r.Status__c!='Approved'
        // Since this is generalized it should be possible to put condition on cofiguration to allow delete where it is not approved.
        if(recordType=='Grantor'){
            tasksToBeDeleted=[select Id, GNT__TaskAction__c, Subject__c
            from task where GNT__ParentRecordId__c in:grantorSObjIds
            and GNT__TaskAction__c in: grantorTaskActnStrgs];
        }
        else{
            tasksToBeDeleted=[select Id, GNT__TaskAction__c, Subject__c
            from task where GNT__ParentRecordId__c in:granteeSObjIds
            and GNT__TaskAction__c in: granteeTaskActnStrgs];
        }
        if(tasksToBeDeleted.size()>0){
            delete tasksToBeDeleted;
        }
    }

    private void checkForDuplicates(){
        List<RolesAndResponsibilities__c> newRecords=(List<RolesAndResponsibilities__c>) Trigger.new;
        List<RolesAndResponsibilities__c> lstRoles =new List<RolesAndResponsibilities__c>();
        Set<String> newParentObjIds = new Set<String>();
        Set<String> imp=new Set<String>{'Program__c','PreApplication__c','Application__c','Announcement__c','Award__c','StrategicPlan__c','ServiceArea__c','SiteVisit__c','ProgressReports__c'};
        for(RolesAndResponsibilities__c record:newRecords){
            Id recordId=record.ParentObjectId__c;
            System.debug('Record Id====>'+record.ParentObjectId__c);
            Schema.SObjectType sobjectType = recordId.getSObjectType();
            System.debug('SOBECJT=======>'+sobjectType);
            String sobjectName = sobjectType.getDescribe().getName();
            System.debug('SOBJECTNAME======>'+sObjectName);
            if(imp.contains(sobjectName)){
                newParentObjIds.add(record.ParentObjectId__c);
            }
        }
        if(newParentObjIds.size()>0){
            lstRoles =[SELECT Id,Name__c,BusinessRole__c,ParentObjectId__c,QueueId__c
            FROM RolesAndResponsibilities__c
            WHERE ParentObjectId__c IN :newParentObjIds];
        }
        if(lstRoles.size()>0){
            for(RolesAndResponsibilities__c role:lstRoles){
                if(Trigger.isBefore && Trigger.isInsert){
                    for(RolesAndResponsibilities__c record:newRecords){
                        if((Id) role.ParentObjectId__c==record.ParentObjectId__c){
                            if(role.BusinessRole__c.equals('Informed Person') || role.QueueId__c!=null){continue;}
                            if(role.BusinessRole__c!=null && record.Name__c == role.Name__c &&
                                    record.BusinessRole__c.equals(role.BusinessRole__c)){
                                record.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-19298'));
                            }
                            else if(role.BusinessRole__c!=null && record.Name__c != role.Name__c &&
                                    record.BusinessRole__c.equals(role.BusinessRole__c) ){

                                record.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83424'));

                            }
                            else if(GNT.KeyValueStoreHelper.getBooleanValue('R&R Entry Unique',true)){
                                if(role.BusinessRole__c!=null && record.Name__c==role.Name__c){
                                    record.addError(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83424'));
                                }
                            }
                        }
                    }
                }
                if(Trigger.isBefore && Trigger.isUpdate){
                    for(RolesAndResponsibilities__c record:newRecords){
                        Integer clientRule = GNT.KeyValueStoreHelper.getIntegerValue('R&RRule', true);
                        RolesAndResponsibilities__c oldRR = (RolesAndResponsibilities__c)Trigger.oldMap.get(record.Id);
                        if(role.ParentObjectId__c==record.ParentObjectId__c
                                && (!record.Name__c.equals(oldRR.Name__c)
                                || !record.BusinessRole__c.equals(oldRR.BusinessRole__c))){
                            /*if(clientRule != null && (clientRule == 0 || clientRule == 1)){
                                if (!record.Name__c.equals(oldRR.Name__c) && record.Name__c.equals(role.Name__c)) {
                                    record.addError('Error removed');
                                    //Shah CRF: Error message should be stored in a central place. Move all such hardcoding in this class -->fixed
                                }
                            }*/
                        }
                        if (!record.BusinessRole__c.equals(oldRR.BusinessRole__c) && record.BusinessRole__c.equals(role.BusinessRole__c)) {
                            record.addError('Duplicate roles found');
                        }
                    }
                }
            }
        }
    }

    /*private void updateQueueName(){
        List<RolesAndResponsibilities__c> records=(List<RolesAndResponsibilities__c>) Trigger.new;
        Map<Id,String> groupMap=new Map<Id,String>();
        List<Id> userIds=new List<Id>();
        for(RolesAndResponsibilities__c record:records){
            if(record.Name__c!=null){
                userIds.add(record.Name__c);
            }
        }
        List<User> users=[Select Id,Name from User where id in:userIds];
        for(User user:users){
            groupMap.put(user.Id,user.Name);
        }
        for(RolesAndResponsibilities__c record:records){
            if(record.Name__c!=null){
                record.Name1__c=groupMap.get(record.Name__c);
            }
        }
    } This method is called when we implement queues and this method explicitly stores the name of a user or a queue in the rr layout in the query string call Name1__c instead of name */
    public void insertRoles(String recordType){
        System.debug('insertRoles starts: ' + recordType);
        List<RolesAndResponsibilities__c> newRecords=(List<RolesAndResponsibilities__c>) Trigger.new;
        Map<String,Set<Id>> impSObjectsIds=new Map<String,Set<Id>>();
        Map<Id,SObject> allSObjRecords=new Map<Id,SObject>();
        Set<String> sObjSetForImp=new Set<String>();
        Set<Id> sObjQueueList=new Set<Id>();
        Boolean beforeInsert=false;
        Boolean grantorRecordType=false;
        Set<String> queObjs=new Set<String>{};
        Map<String,String> queImpRoleApiNames=new Map<String,String>();
        queImpRoleApiNames.put('Program Approver', 'ProgramApproverManual__c');
        queImpRoleApiNames.put('Fiscal Approver', 'FiscalApproverManual__c');
        queImpRoleApiNames.put('Executive Approver', 'ExecutiveApproverManual__c');
        queImpRoleApiNames.put('Peer Reviewer','PeerReviewerManual__c');
        if(Trigger.isBefore && Trigger.isInsert){
            Set<String> impSetObjects=new Set<String>{'ProgressReports__c','SiteVisit__c','RiskAssessment__c','Closeout__c'};
            sObjSetForImp.addAll(impSetObjects);
            beforeInsert=true;
        }
        else if(Trigger.isAfter && Trigger.isInsert && recordType=='Grantor'){
            Set<String> impSetObjects=new Set<String>{'Program__c','Application__c','PreApplication__c','Announcement__c',
                    'AmendmentRequest__c','Award__c','ProgressReports__c','PaymentRequest__c', 'r_prog__c'};
            sObjSetForImp.addAll(impSetObjects);
            grantorRecordType=true;
        }
        else if(Trigger.isAfter && Trigger.isInsert && recordType=='Grantee'){
            Set<String> impSetObjects=new Set<String>{'Program__c','Application__c','PreApplication__c','Closeout__c',
                    'Award__c','AmendmentRequest__c','Announcement__c'};
            System.debug('Inside Grantee');
            sObjSetForImp.addAll(impSetObjects);
        }
        for(RolesAndResponsibilities__c record:newRecords){
            System.debug('inside for loop - record: ' + record);
            if(record.UserType__c=='User'){
                if(record.isActiveUser__c){
                    if(record.BusinessRole__c!=null && record.ParentObjectId__c!=null && 
                        (!record.BusinessRole__c.contains('Reviewer') || record.BusinessRole__c=='Peer Reviewer')){
                        System.debug('record before getObjectName is called: ' + record);
                        System.debug('record.ParentObjectId__c: ' + record.ParentObjectId__c);
                        String objName=getObjectName(record.ParentObjectId__c);
                        if(sObjSetForImp.contains(objName)){
                            if(!impSObjectsIds.containsKey(objName)){
                                impSObjectsIds.put(objName,new Set<Id>());
                            }
                            impSObjectsIds.get(objName).add(record.ParentObjectId__c);
                        }
                    }
                }
                else{
                    // Since the code terminates wrote this query inside to display the user name.
                    /*User usr=[Select Name from User where Id=:record.Name__c];
                    if(usr.Name!=null){
                        record.addError(usr.Name + ' is an inactive user in Roles And Responsibilities. Edit/Add with an Active User.');
                    }
                    else{
                        continue;
                    }*/
                    
                }
            }
            else if(record.UserType__c=='Queue'){
                try{
                    if(record.BusinessRole__c!=null && record.ParentObjectId__c!=null && 
                        (!record.BusinessRole__c.contains('Reviewer') || record.BusinessRole__c=='Peer Reviewer')){
                        String objName=getObjectName(record.ParentObjectId__c);
                        if(sObjSetForImp.contains(objName)){
                            if(!impSObjectsIds.containsKey(objName)){
                                impSObjectsIds.put(objName,new Set<Id>());
                            }
                            impSObjectsIds.get(objName).add(record.ParentObjectId__c);
                            sObjQueueList.add(record.ParentObjectId__c);
                        }
                    }
                }
                catch(Exception ex){
                    record.addError(ex.getMessage());
                }
            }
        }
        // The query is written intentionally inside the for loop Since we merged all the methods
        // into one method and does the same queries as before.
        for(String sObj:impSObjectsIds.keySet()){
            String parentObjName=shareParentObjs.get(sObj);
            String queryStart='Select Id';
            if(sObj!=parentObjName){
                String parentRelation=parentObjName.substring(0, parentObjName.length()-1)+'r';
                queryStart+=','+parentRelation+'.OwnerId,'+parentObjName;
            }
            else{
                queryStart+=',OwnerId';
            }
            String queryBody='';
            SObjectWrapper wrapperVar=wrapMap.get(sObj);
            List<RoleWrapper> roleWrap=wrapperVar.roles;
            
            for(RoleWrapper obj:roleWrap){
                queryBody+=','+obj.userLookupFieldName;
            }
            String queryEnds=' from  '+sObj+' where Id in ';
            String query=queryStart+queryBody+queryEnds+ GNT.AppUtils.soqlList(impSObjectsIds.get(sObj));
            System.debug('Query'+query);
            List<SObject> listRoles =Database.query(query);
            System.debug(listRoles);
            for(sObject obj: listRoles){
                Id objId=(Id) obj.get('Id');
                allSObjRecords.put(objId,obj);
            }
        }
        for(RolesAndResponsibilities__c record:(List<RolesAndResponsibilities__c>) Trigger.new){
            System.debug('record: ' + record);
            System.debug('record.ParentObjectId__c: ' + record.ParentObjectId__c);
            Id parentId=record.ParentObjectId__c;
            String sobjectName=getObjectName(parentId);
            System.debug(allSObjRecords);
            if(beforeInsert && allSObjRecords.size()>0){
                SObject getSObject=allSObjRecords.get(parentId);
                Id getOwnerId;
                String parentObjName=shareParentObjs.get(sobjectName);
                if(sobjectName!=parentObjName){
                    String parentRelation=parentObjName.substring(0, parentObjName.length()-1)+'r';
                    getOwnerId=(Id) getSObject.getSObject(parentRelation).get('OwnerId');
                    parentId= (Id) getSObject.get(parentObjName);
                }
                else{
                    getOwnerId=(Id) getSObject.get('OwnerId');
                }
                SObject updatedSObject=updateSObjFields(sobjectName,getSObject,record.BusinessRole__c,record.Name__c);
            }
            else if(allSObjRecords.size()>0){
                SObject getSObject=allSObjRecords.get(parentId);
                Id getOwnerId;
                String parentObjName=shareParentObjs.get(sobjectName);
                if(sobjectName!=parentObjName){
                    String parentRelation=parentObjName.substring(0, parentObjName.length()-1)+'r';
                    getOwnerId=(Id) getSObject.getSObject(parentRelation).get('OwnerId');
                    parentId= (Id) getSObject.get(parentObjName);
                }
                else{
                    getOwnerId=(Id) getSObject.get('OwnerId');
                }
                if(record.BusinessRole__c!='Informed Person'){
                    if(record.UserType__c.contains('Queue') && (record.BusinessRole__c.contains('Approver') || record.BusinessRole__c=='Peer Reviewer') &&
                            queObjs.contains(sobjectName)){
                        SObject updatedSObject=updateSObjFields(sobjectName,getSObject,record.BusinessRole__c,record.Name__c);
                        if(queImpRoleApiNames.keySet().contains(record.BusinessRole__c)){
                            getSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),record.QueueId__c);
                        }
                    }
                    else{
                        SObject updatedSObject=updateSObjFields(sobjectName,getSObject,record.BusinessRole__c,record.Name__c);
                        if(queObjs.contains(sobjectName)){
                            if(queImpRoleApiNames.keySet().contains(record.BusinessRole__c)){
                                getSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),record.Name__c);
                            }
                        }
                    }
                }
                else if(record.BusinessRole__c=='Informed Person' &&
                        (sobjectName=='Program__c' || sobjectName=='Announcement__c')){
                    String notify=(String) getSObject.get('NotifyAdditionalPeople__c');
                    if(notify != null){
                        String newNotify=notify+ ',' + record.Name__c;
                        getSObject.put('NotifyAdditionalPeople__c',newNotify);
                    }else{
                        getSObject.put('NotifyAdditionalPeople__c',record.Name__c);
                    }
                }
                else if(record.UserType__c.contains('Queue') && record.BusinessRole__c.contains('Approver') &&
                        queObjs.contains(sobjectName)){
                    if(queImpRoleApiNames.keySet().contains(record.BusinessRole__c)){
                        getSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),record.QueueId__c);
                    }
                }
            }
        }
        if(allSObjRecords.size()>0){
            update allSObjRecords.values();
        }
        System.debug('CharanTest===>'+allSObjRecords);
    }

    private void updateRoles(){
        Set<String> impSObjsBfrInsrt=new Set<String>{'Announcement__c','Award__c','AmendmentRequest__c','PreApplication__c','Application__c',
                'SiteVisit__c','RiskAssessment__c','Closeout__c','Program__c','PaymentRequest__c', 'r_prog__c'};
        Set<String> queObjs=new Set<String>{};
        Map<String,String> queImpRoleApiNames=new Map<String,String>();
        queImpRoleApiNames.put('Program Approver', 'ProgramApproverManual__c');
        queImpRoleApiNames.put('Fiscal Approver', 'FiscalApproverManual__c');
        queImpRoleApiNames.put('Executive Approver', 'ExecutiveApproverManual__c');
        Set<String> impSObjAfrInsrt=new Set<String>{'Announcement__c','Award__c','AmendmentRequest__c',
                'Application__c','PreApplication__c'};
        Map<Id,SObject> updatedRoles=new Map<Id,SObject>();
        for(RolesAndResponsibilities__c record:(List<RolesAndResponsibilities__c>) Trigger.new){
            Id parentId=record.ParentObjectId__c;
            Schema.SObjectType sobjectType = parentId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();
            if(Trigger.isBefore && Trigger.isUpdate && record.BusinessRole__c!=null && record.ParentObjectId__c!=null){
                if(impSObjsBfrInsrt.contains(sobjectName)){
                    SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                    SObject updatedSObject=updateSObjFields(sobjectName,assignedSObject,record.BusinessRole__c,record.Name__c);
                }
                else if(queObjs.contains(sobjectName)){
                    if(queImpRoleApiNames.keySet().contains(record.BusinessRole__c)){
                        SObjectWrapper wrapperVar=wrapMap.get(sobjectName);
                        List<RoleWrapper> roleWrap=wrapperVar.roles;
                        for(RoleWrapper obj:roleWrap){
                            SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                            if(record.UserType__c.equals('User')){
                                assignedSObject.put(obj.userLookupFieldName,record.Name__c);
                                assignedSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),(Id) record.Name__c);
                            }
                            else if(record.UserType__c.equals('Queue')){
                                assignedSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),(Id) record.QueueId__c);
                            }
                        }
                    }
                    else{
                        SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                        sObject updatedSObject=updateSObjFields(sobjectName,assignedSObject,record.BusinessRole__c,record.Name__c);
                    }
                }
            }
            else{
                if(impSObjAfrInsrt.contains(sobjectName) && sobjectName!='Application__c'){
                    if(record.BusinessRole__c!=null && record.ParentObjectId__c!=null){
                        SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                        sObject updatedSObject=updateSObjFields(sobjectName,assignedSObject,record.BusinessRole__c,record.Name__c);
                    }
                }
                else if(impSObjAfrInsrt.contains(sobjectName) && sobjectName=='Application__c'){
                    if(record.BusinessRole__c!=null && record.ParentObjectId__c!=null){
                        SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                        sObject updatedSObject=updateSObjFields(sobjectName,assignedSObject,record.BusinessRole__c,record.Name__c);
                    }
                }
            }
        }
        if(updatedRoles.size()>0){
            update(updatedRoles.values());
        }
    }

    
    private void deleteRoles(){
        Set<String> impSObj=new Set<String>{'SiteVisit__c','RiskAssessment__c','Closeout__c','Announcement__c',
                'Application__c','Program__c','AmendmentRequest__c','Award__c','PaymentRequest__c', 'r_prog__c'};
        Set<String> queObjs=new Set<String>{};
        Map<String,String> queImpRoleApiNames=new Map<String,String>();
        queImpRoleApiNames.put('Program Approver', 'ProgramApproverManual__c');
        queImpRoleApiNames.put('Fiscal Approver', 'FiscalApproverManual__c');
        queImpRoleApiNames.put('Executive Approver', 'ExecutiveApproverManual__c');
        List<RolesAndResponsibilities__c> records=(List<RolesAndResponsibilities__c>) Trigger.old;
        Map<Id,SObject> updatedRoles=new Map<Id,SObject>();
        for(RolesAndResponsibilities__c record:records){
            Id parentId=record.ParentObjectId__c;
            Schema.SObjectType sobjectType = parentId.getSObjectType();
            String sobjectName = sobjectType.getDescribe().getName();
            if(Trigger.isBefore && Trigger.isDelete){
                if(impSObj.contains(sobjectName)){
                    if(record.BusinessRole__c!=null && record.ParentObjectId__c!=null){
                        SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                        sObject updatedSObject=updateSObjFields(sobjectName,assignedSObject,record.BusinessRole__c,null);
                    }
                }
                else if(queObjs.contains(sobjectName)){
                    if(record.BusinessRole__c!=null && record.ParentObjectId__c!=null){
                        SObjectWrapper wrapperVar=wrapMap.get(sobjectName);
                        List<RoleWrapper> roleWrap=wrapperVar.roles;
                        for(RoleWrapper obj:roleWrap){
                            if(queImpRoleApiNames.keySet().contains(obj.roleName) && queImpRoleApiNames.keySet().contains(record.BusinessRole__c)){
                                SObject assignedSObject=checkOrCreateSObject(updatedRoles,parentId,sobjectType);
                                if(record.UserType__c.equals('User')){
                                    assignedSObject.put(obj.userLookupFieldName,null);
                                    assignedSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),null);
                                }
                                else if(record.UserType__c.equals('Queue')){
                                    assignedSObject.put(queImpRoleApiNames.get(record.BusinessRole__c),null);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(updatedRoles.size()>0){
            update(updatedRoles.values());
        }
    }
    private void populateOrganization() {
        List<Id> userId = new List<Id>();
        for (RolesAndResponsibilities__c role : (List<RolesAndResponsibilities__c>)Trigger.new) {
            if (role.Name__c != null) {
                userId.add(role.Name__c);
            }
        }
        List<User> lstUsers = [Select Id, GNT__OrganizationId__c from User where Id in:userId];
        Map<Id, Id> mapUserAccountId = new Map<Id, Id>();
        for (User usr : lstUsers) {
            mapUserAccountId.put(usr.Id, usr.GNT__OrganizationId__c);
        }
        for (RolesAndResponsibilities__c role : (List<RolesAndResponsibilities__c>)Trigger.new) {
            if (role.Name__c != null) {
                role.Agency__c = (Id)mapUserAccountId.get(role.Name__c);
            }
        }
    }

// Notify user with the email via email component developed by Pankaj.
// - Charan (5/27/2017)
    private void notifyRoleViaEmail() {
        for (RolesAndResponsibilities__c roles : (List<RolesAndResponsibilities__c>)Trigger.new) {
            RolesAndResponsibilities__c oldRecord = null;
            String templateName;
            if (Trigger.oldMap != null) {
                oldRecord = (RolesAndResponsibilities__c) Trigger.oldMap.get(roles.Id);
            }
            if ((roles.BusinessRole__c!=null && oldRecord == null && roles.Notify__c) ||
                    (roles.BusinessRole__c!=null && oldRecord != null && oldRecord.Notify__c == false && roles.Notify__c == true ) ) {
                String recordId = roles.ParentObjectId__c;
                templateName = 'NotifyRoles';
                if(templateName!=null){
                    new GNT.EmailFeeder().TargetObjectId(roles.Name__c).template(templateName).contextRecordId(recordId).send();
                }
            }
        }
    }

    // This method changes the owner of the record and change the owner of the task and this can be changed according to the requirement. -Charan
    private void updateOwnerOrTaskForReviewer() {
        Set<Id> parentObjIds = new Set<Id>();
        Map<Id, Id> parentOwnerIds = new Map<Id, Id>();
        Map<Id, Id> oldOwnerIds = new Map<Id, Id>();
        List<Task> updatedTasks = new List<Task>();
        List<sObject> updateOwnerList = new List<sObject>();
        SystemContextMethodsHelper sysCnt = new SystemContextMethodsHelper();
        for (RolesAndResponsibilities__c newRolesResp : (List<RolesAndResponsibilities__c>) Trigger.new) {
            RolesAndResponsibilities__c oldRecord = (RolesAndResponsibilities__c)Trigger.oldMap.get(newRolesResp.Id);
            if ((oldRecord.BusinessRole__c == 'Program Reviewer' && newRolesResp.BusinessRole__c == 'Program Reviewer') ||
                    (oldRecord.BusinessRole__c == 'Fiscal Reviewer' && newRolesResp.BusinessRole__c == 'Fiscal Reviewer')) {
                if (oldRecord.Name__c != newRolesResp.Name__c) {
                    parentObjIds.add(newRolesResp.ParentObjectId__c);
                    oldOwnerIds.put(newRolesResp.ParentObjectId__c, oldRecord.Name__c);
                    parentOwnerIds.put(newRolesResp.ParentObjectId__c, newRolesResp.Name__c);
                }
            }
            if (oldRecord.BusinessRole__c == 'Owner' && newRolesResp.BusinessRole__c == 'Owner') {
                if (oldRecord.Name__c != newRolesResp.Name__c) {
                    Id sID = oldRecord.ParentObjectId__c;
                    System.debug('LEON TEST======>'+sID);
                    sObject sObj = sID.getSobjectType().newSObject(sID);
                    sObj.put('OwnerId', newRolesResp.Name__c);
                    updateOwnerList.add(sObj);
                }
            }
        }
        if ( parentObjIds.size() > 0) {
            List<Task> tasks = sysCnt.getRelatedTasksForRoles(parentObjIds);
            for (Task tsk : tasks) {
                if (tsk.GNT__TaskAction__c.contains('Review') && tsk.OwnerId == oldOwnerIds.get(tsk.GNT__ParentRecordId__c)) {
                    tsk.OwnerId = parentOwnerIds.get(tsk.GNT__ParentRecordId__c);
                    updatedTasks.add(tsk);
                }
            }
        }
        if (updatedTasks.size() > 0) {
            sysCnt.updateTasks(updatedTasks);
        }
        if (updateOwnerList.size() > 0) {
            update updateOwnerList;
        }
    }
}