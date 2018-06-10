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

public with sharing class RolesAndRespTriggerHelperUSBE extends GNT.TriggerHelper {

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
    public static boolean skipMassUpdateTrigger = false;
    public static boolean skipInsertRoleQueue = false;
    public static Map<String,String> shareParentObjs=new Map<String,String>();

    // All the API Field name are initialized in the static block which is common for a given
    //     R&R r
    // 'Review Application (Grantee)','Review Pre-Application (Grantee)','Review the opportunity'
    static{
    
        List<RoleWrapper> appRoles=new List<RoleWrapper>();
        appRoles.add(new RoleWrapper('Executive Approver','ExecutiveApprover__c'));
        appRoles.add(new RoleWrapper('Grants Manager','GrantsManager__c'));
        appRoles.add(new RoleWrapper('Payment Approver 1','PaymentApprover1__c'));
        appRoles.add(new RoleWrapper('Payment Approver 2','PaymentApprover2__c'));
        appRoles.add(new RoleWrapper('Payment Approver 3','PaymentApprover3__c'));
        appRoles.add(new RoleWrapper('Payment Approver 4','PaymentApprover4__c'));
        appRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        appRoles.add(new RoleWrapper('Award Approver 1','AwardApprover1__c'));
        appRoles.add(new RoleWrapper('Award Approver 2','AwardApprover2__c'));
        wrapMap.put('Application__c',new SObjectWrapper(appRoles,'Review Application (Grantee)','Title__c','Review Application'));
        /*
        List<RoleWrapper> appRoles=new List<RoleWrapper>();
        appRoles.add(new RoleWrapper('Fiscal Approver','FiscalApproval__c'));
        appRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('Application__c',new SObjectWrapper(appRoles,'Review Application (Grantee)','Title__c','Review Application'));
        */
        
        List<RoleWrapper> amdRoles=new List<RoleWrapper>();
        amdRoles.add(new RoleWrapper('Executive Approver','ExecutiveApprover__c')); //Already existed on the object since Dec 2017
        amdRoles.add(new RoleWrapper('Grants Manager','GrantsManager__c'));
        amdRoles.add(new RoleWrapper('Payment Approver 1','PaymentApprover1__c'));
        amdRoles.add(new RoleWrapper('Payment Approver 2','PaymentApprover2__c'));
        amdRoles.add(new RoleWrapper('Payment Approver 3','PaymentApprover3__c'));
        amdRoles.add(new RoleWrapper('Payment Approver 4','PaymentApprover4__c'));
        wrapMap.put('AmendmentRequest__c',new SObjectWrapper(amdRoles));
        /*
        List<RoleWrapper> amdRoles=new List<RoleWrapper>();
        amdRoles.add(new RoleWrapper('Fiscal Approver','FiscalApprover__c'));
        amdRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        wrapMap.put('AmendmentRequest__c',new SObjectWrapper(amdRoles));
        */
        
        List<RoleWrapper> annRoles=new List<RoleWrapper>();
        annRoles.add(new RoleWrapper('Executive Approver','Executive__c')); //Preexisting, just reuse
        annRoles.add(new RoleWrapper('Grants Manager','GrantsManager__c'));
        annRoles.add(new RoleWrapper('Payment Approver 1','PaymentApprover1__c'));
        annRoles.add(new RoleWrapper('Payment Approver 2','PaymentApprover2__c'));
        annRoles.add(new RoleWrapper('Payment Approver 3','PaymentApprover3__c'));
        annRoles.add(new RoleWrapper('Payment Approver 4','PaymentApprover4__c'));
        annRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        annRoles.add(new RoleWrapper('Award Approver 1','AwardApprover1__c'));
        annRoles.add(new RoleWrapper('Award Approver 2','AwardApprover2__c'));
        wrapMap.put('Announcement__c',new SObjectWrapper(annRoles,'Review Grantor Announcement','Review the opportunity',true,'AnnouncementName__c','Other'));
                
        List<RoleWrapper> preAppRoles=new List<RoleWrapper>();
        preAppRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        preAppRoles.add(new RoleWrapper('Fiscal Approver','Fiscal_Approver__c'));
        wrapMap.put('PreApplication__c',new SObjectWrapper(preAppRoles,'Review Pre-Application (Grantee)','Title__c','Review Pre-Application'));
        
        List<RoleWrapper> grantRoles=new List<RoleWrapper>();
        grantRoles.add(new RoleWrapper('Executive Approver','ExecutiveApprover__c'));
        grantRoles.add(new RoleWrapper('Grants Manager','GrantsManager__c'));
        grantRoles.add(new RoleWrapper('Payment Approver 1','PaymentApprover1__c'));
        grantRoles.add(new RoleWrapper('Payment Approver 2','PaymentApprover2__c'));
        grantRoles.add(new RoleWrapper('Payment Approver 3','PaymentApprover3__c'));
        grantRoles.add(new RoleWrapper('Payment Approver 4','PaymentApprover4__c'));
        grantRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        grantRoles.add(new RoleWrapper('Award Approver 1','AwardApprover1__c'));
        grantRoles.add(new RoleWrapper('Award Approver 2','AwardApprover2__c'));
        wrapMap.put('Grant__c', new SObjectWrapper(grantRoles));

        List<RoleWrapper> awdRoles=new List<RoleWrapper>();
        awdRoles.add(new RoleWrapper('Executive Approver','ExecutiveApprover__c'));
        awdRoles.add(new RoleWrapper('Grants Manager','GrantsManager__c'));
        awdRoles.add(new RoleWrapper('Payment Approver 1','PaymentApprover1__c'));
        awdRoles.add(new RoleWrapper('Payment Approver 2','PaymentApprover2__c'));
        awdRoles.add(new RoleWrapper('Payment Approver 3','PaymentApprover3__c'));
        awdRoles.add(new RoleWrapper('Payment Approver 4','PaymentApprover4__c'));
        awdRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        awdRoles.add(new RoleWrapper('Award Approver 1','AwardApprover1__c'));
        awdRoles.add(new RoleWrapper('Award Approver 2','AwardApprover2__c'));
        wrapMap.put('Award__c',new SObjectWrapper(awdRoles));
        /*
        List<RoleWrapper> awdRoles=new List<RoleWrapper>();
        awdRoles.add(new RoleWrapper('Fiscal Approver','FOUser__c'));
        awdRoles.add(new RoleWrapper('Program Approver','POUser__c'));
        awdRoles.add(new RoleWrapper('Executive Approver','Comptroller__c'));
        awdRoles.add(new RoleWrapper('Grants Administrator','GrantAdministrator__c'));
        wrapMap.put('Award__c',new SObjectWrapper(awdRoles));
        */
        
        List<RoleWrapper> clsOutRoles=new List<RoleWrapper>();
        clsOutRoles.add(new RoleWrapper('Program Approver','POApprover__c'));
        clsOutRoles.add(new RoleWrapper('Fiscal Approver','FOApprover__c'));
        wrapMap.put('Closeout__c', new SObjectWrapper(clsOutRoles));
        
        List<RoleWrapper> rskAssRoles=new List<RoleWrapper>();
        rskAssRoles.add(new RoleWrapper('Program Approver','Approver__c'));
        wrapMap.put('RiskAssessment__c', new SObjectWrapper(rskAssRoles));

        List<RoleWrapper> prgmRoles=new List<RoleWrapper>();
        prgmRoles.add(new RoleWrapper('Executive Approver','ExecutiveApprover__c'));
        prgmRoles.add(new RoleWrapper('Grants Manager','GrantsManager__c'));
        prgmRoles.add(new RoleWrapper('Payment Approver 1','PaymentApprover1__c'));
        prgmRoles.add(new RoleWrapper('Payment Approver 2','PaymentApprover2__c'));
        prgmRoles.add(new RoleWrapper('Payment Approver 3','PaymentApprover3__c'));
        prgmRoles.add(new RoleWrapper('Payment Approver 4','PaymentApprover4__c'));
        prgmRoles.add(new RoleWrapper('Program Approver','ProgramApprover__c'));
        prgmRoles.add(new RoleWrapper('Award Approver 1','AwardApprover1__c'));
        prgmRoles.add(new RoleWrapper('Award Approver 2','AwardApprover2__c'));
        wrapMap.put('Program__c', new SObjectWrapper(prgmRoles));

        List<RoleWrapper> proRprtRoles=new List<RoleWrapper>();
        proRprtRoles.add(new RoleWrapper('POC','EmailPOC__c'));
        proRprtRoles.add(new RoleWrapper('Fiscal Approver','FiscalApprover__c'));
        proRprtRoles.add(new RoleWrapper('Program Approver','ProgramApproverManual__c'));
        wrapMap.put('ProgressReports__c', new SObjectWrapper(proRprtRoles));
        
        List<RoleWrapper> pmtReqRoles=new List<RoleWrapper>();
        pmtReqRoles.add(new RoleWrapper('Program Approver','ProgramApproverManual__c'));
        pmtReqRoles.add(new RoleWrapper('Fiscal Approver','FiscalApproverManual__c'));
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
            if (appName == 'StateasGrantor' && skipTrigger == false && skipInsertRoleQueue == false) {
                insertRoles('Grantor');
                createTask('Grantor');
            }else if (appName == 'StateasGrantee' && skipTrigger == false && skipInsertRoleQueue == false) {
                createTask('Grantee');
                insertRoles('Grantee');
            }
            else if(appName=='Recipient' && skipTrigger==false && skipInsertRoleQueue == false){
                insertRoles('Grantor');
            }
            notifyRoleViaEmail();
            //upsertGrantRR();
            //updateAwardRolesUSBE((List<RolesAndResponsibilities__c>)Trigger.Old, (List<RolesAndResponsibilities__c>)Trigger.New);
            handleShares();
            /*if (skipMassUpdateTrigger == false) {
                fullOverrideUpsertRoles((List<RolesAndResponsibilities__c>) Trigger.New);
            }*/
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
            //upsertGrantRR();
            handleShares();
            //updateAwardRolesUSBE((List<RolesAndResponsibilities__c>)Trigger.Old, (List<RolesAndResponsibilities__c>)Trigger.New);
            if (skipMassUpdateTrigger == false) {
                fullOverrideUpdateRoles(mapNewOldTrigger((List<RolesAndResponsibilities__c>) Trigger.New, (List<RolesAndResponsibilities__c>) Trigger.Old));
            }
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
        /*
        String soql = 'Select Id, Name__c, QueueId__c, ParentObjectId__c, ShareObjectName__c, ShareParentId__c, ShareAccessLevel__c from RolesAndResponsibilities__c where ' +
                rrList.get(0).ParentLookupFieldName__c + ' in (\'' + AppUtils.concatenate(parentIds, '\',\'') + '\') ';
                */
        String soql = 'Select Id, Name__c, QueueId__c, ParentObjectId__c, ShareObjectName__c, ShareParentId__c, ShareAccessLevel__c from RolesAndResponsibilities__c where Name__c != null AND ' +
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
        newShares.sort();
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
        Set<String> imp=new Set<String>{'Program__c','PreApplication__c','Application__c','Announcement__c','Award__c','StrategicPlan__c','ServiceArea__c'};
        
        Map<String, String> errorMapMessage = new Map<String, String>{
            'GEN-GRNTR-19298' => GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-19298'), 
            'GEN-GRNTR-83424' => GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83424'),
            'GEN-GRNTR-83424' => GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-83424')
            };
        
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
                                record.addError(errorMapMessage.get('GEN-GRNTR-19298'));
                            }
                            else if(role.BusinessRole__c!=null && record.Name__c != role.Name__c &&
                                    record.BusinessRole__c.equals(role.BusinessRole__c) ){

                                record.addError(errorMapMessage.get('GEN-GRNTR-83424'));

                            }
                            else if(GNT.KeyValueStoreHelper.getBooleanValue('R&R Entry Unique',true)){
                                if(role.BusinessRole__c!=null && record.Name__c==role.Name__c){
                                    record.addError(errorMapMessage.get('GEN-GRNTR-83424'));
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
    private void insertRoles(String recordType){
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
        Set<String> impSObjsBfrInsrt=new Set<String>{'Announcement__c', 'Grant__c', 'Award__c','AmendmentRequest__c','PreApplication__c','Application__c',
                'SiteVisit__c','RiskAssessment__c','Closeout__c','Program__c','PaymentRequest__c', 'r_prog__c'};
        Set<String> queObjs=new Set<String>{};
        Map<String,String> queImpRoleApiNames=new Map<String,String>();
        queImpRoleApiNames.put('Program Approver', 'ProgramApproverManual__c');
        queImpRoleApiNames.put('Fiscal Approver', 'FiscalApproverManual__c');
        queImpRoleApiNames.put('Executive Approver', 'ExecutiveApproverManual__c');
        Set<String> impSObjAfrInsrt=new Set<String>{'Announcement__c', 'Grant__c', 'Award__c','AmendmentRequest__c',
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
    
    
    //(Placeholder) Method to update the new roles implementation in USBE Awards
    private void updateAwardRolesUSBE(List<RolesAndResponsibilities__c> oldRolesAndRespList, List<RolesAndResponsibilities__c> rolesAndRespList) {
        Set<Id> grantIdList = new Set<Id>();
        Map<Id, RolesAndResponsibilities__c> grantIdMapRolesAndRespObj = new Map<Id, RolesAndResponsibilities__c>();
        for (RolesAndResponsibilities__c rolesAndRespIterator : rolesAndRespList) {
            for (RolesAndResponsibilities__c oldRolesAndRespIterator : oldRolesAndRespList) {
                if ((rolesAndRespIterator.Grant__c != null && oldRolesAndRespIterator.Grant__c != null) && (oldRolesAndRespIterator.Id == rolesAndRespIterator.Id)) {
                    if (rolesAndRespIterator.Name__c != oldRolesAndRespIterator.Name__c) {
                        grantIdMapRolesAndRespObj.put(rolesAndRespIterator.Grant__c, rolesAndRespIterator);
                    }   
                }
            }
        }
        List<Award__c> awardList = [SELECT Id, Grant__c, GrantorOrganization__c FROM Award__c WHERE Grant__c IN: grantIdMapRolesAndRespObj.keySet() AND GrantorOrganization__c = 'USBE'];
        String businessRole;
        if (awardList != null && awardList.size() > 0) {
            for (Award__c awardIterator : awardList) {
                businessRole = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).BusinessRole__c;
                if (businessRole.equals('Executive Approver')) {
                    awardIterator.ExecutiveApprover__c = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).Name__c;
                }
                else if (businessRole.equals('Grants Manager')) {
                    awardIterator.GrantsManager__c = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).Name__c;
                }
                else if (businessRole.equals('Payment Approver 1')) {
                    awardIterator.PaymentApprover1__c = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).Name__c;
                }
                else if (businessRole.equals('Payment Approver 2')) {
                    awardIterator.PaymentApprover2__c = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).Name__c;
                }
                else if (businessRole.equals('Payment Approver 3')) {
                    awardIterator.PaymentApprover3__c = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).Name__c;
                }
                else if (businessRole.equals('Payment Approver 4')) {
                    awardIterator.PaymentApprover4__c = (grantIdMapRolesAndRespObj.get(awardIterator.Grant__c)).Name__c;
                }
            }
            USBEAwardTriggerHelper.skipTriggers = true;
            USBEAwardTriggerHelper.skipTrigger = true;
            USBEAwardTriggerHelper.skipfromAmendment = true;
            update awardList; 
            USBEAwardTriggerHelper.skipTriggers = false;
            USBEAwardTriggerHelper.skipTrigger = false;
            USBEAwardTriggerHelper.skipfromAmendment = false;
        }
    }
    
    
     private Map<RolesAndResponsibilities__c, RolesAndResponsibilities__c> mapNewOldTrigger(List<RolesAndResponsibilities__c> triggerList, List<RolesAndResponsibilities__c> oldTriggerList) {
          Map<RolesAndResponsibilities__c, RolesAndResponsibilities__c> newTriggerMapOldTrigger = new Map<RolesAndResponsibilities__c, RolesAndResponsibilities__c>();
          for (RolesAndResponsibilities__c RolesIterator : triggerList) {
               for (RolesAndResponsibilities__c oldRolesIterator : oldTriggerList) {
                    if (oldRolesIterator.Id == rolesIterator.Id) {
                         newTriggerMapOldTrigger.put(rolesIterator, oldRolesIterator);
                    }
               } 
          } 
          return newTriggerMapOldTrigger; 
     }

     private Id getLookupObjectId(RolesAndResponsibilities__c rrObject) {
          Id objectId;
          if (rrObject.Announcement__c != null) {
               objectId = rrObject.Announcement__c;
          }
          else if (rrObject.Application__c != null) {
               objectId = rrObject.Application__c;
          }
          else if (rrObject.Grant__c != null) {
               objectId = rrObject.Grant__c;
          }
          else if (rrObject.Award__c != null) {
               objectId = rrObject.Award__c;
          }
          else if (rrObject.Announcement__c == null && rrObject.Application__c == null && rrObject.Grant__c == null && rrObject.Award__c == null) {
               objectId = rrObject.Program__c;
          }
          return objectId;
     }

    public class RecordLockedViaApprovalProcessException extends Exception {}
    //Given a parent object, we intend to update the R&Rs of all the Child Objects for the specific role
    private void fullOverrideUpdateRoles(Map<RolesAndResponsibilities__c, RolesAndResponsibilities__c> newTriggerMapOldTrigger) { //Pass it ???
        Set<Id> parentObjectIdSet = new Set<Id>(); //The parent object Id(s) of which we want to find the child objects for    
        //Only execute the full override on the modified R&R(s) object whose Name__c was changed AND is flagged as wanting the full override
        for (RolesAndResponsibilities__c rolesIterator : newTriggerMapOldTrigger.keySet()) {
            if(newTriggerMapOldTrigger.get(rolesIterator).Name__c != rolesIterator.Name__c && (rolesIterator.ChangeChildObjects__c != null && rolesIterator.ChangeChildObjects__c.equals('Update All Derivative Records'))) {               
                Id parentObjectId = getLookupObjectId(rolesIterator); //Only a single non-program object lookup will exist on an R&R object at a time
                if (parentObjectId != null) { parentObjectIdSet.add(parentObjectId); }
            }
        }
       
        if (parentObjectIdSet.size() > 0) {
            AppUtils.EntityHierarchyResolver resolver = new AppUtils.EntityHierarchyResolver();          
            Set<Id> allChildIds = new Set<Id>();
            Map<Id, Set<String>> parentIdMapchildObjectNameSet = new Map<Id, Set<String>>();
            Map<Id, Set<Id>> parentObjectIdMapChildObjectIdSet = new Map<Id, Set<Id>>();
            for (Id idIterator : parentObjectIdSet) {
                 Set<Id> childObjectIdSet = new Set<Id>();
                Set<String> childObjectNameSet = new Set<String>();
                 childObjectNameSet.addAll((resolver.entityNames).get(String.valueOf(idIterator.getSObjectType())));              
                for (String childObjectName : childObjectNameSet) {
                    //To get the child Ids, pass it ('[next child object type]', new Set<Id>{'[parentObjectIdSet]'}) as per the map describes
                    //E.g. resolver.getIds('Program__c', new Set<Id>{'PARENT PROGRAM'S ID}; E.g. resolver.getIds('Grant__c', new Set<Id>{'PARENT APPLICATION's ID'}
                    childObjectIdSet.addAll(resolver.getIds(childObjectName, parentObjectIdSet)); 
                    allChildIds.addAll(childObjectIdSet);
                }
                parentObjectIdMapChildObjectIdSet.put(idIterator, childObjectIdSet);
            }         
            for (Id iter : allChildIds) { System.debug('Sobject: ' + String.valueOf(iter.getSObjectType()) + ' Id: ' + iter); } //Debug
            List<Id> lockedObjectIds = new List<Id>();
    
            for (Id idIterator : allChildIds) {
                if(Approval.isLocked(idIterator)) { //Record is locked via an approval process
                    lockedObjectIds.add(idIterator);
                }
            }
            try {   
                Set<Id> lockedObjectIdsSet = new Set<Id>(lockedObjectIds);
                SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
                if (lockedObjectIdsSet.size() > 0) {
                    //helper.unlockObjectsInApprovalProcess(lockedObjectIds);
                    Approval.UnlockResult[] unlockResultList = Approval.unlock(lockedObjectIds, false);
                }
                Map<Id, Map<Id, Id>> objectIdMapOldUserIdMapNewUserId = new Map<Id, Map<Id, Id>>(); //Map the Object id to Map<Id, Id> oldUserIdMapNewUserId = new Map<Id, Id>();
    
                //Parse the list of child object Ids to find which ones are suitable for mass update and which need direct object update
                Set<String> objectsNeedManualRoleUpdate = new Set<String>{'AmendmentRequest__c', 'PaymentRequest__c'};
                List<Id> objectIdsForManualUpdateRR = new List<Id>();
                List<Id> objectIdsForMassUpdateRR = new List<Id>();
                for (Id idIterator : allChildIds) { //
                    //AmendmentRequests (well, budget revisions to be precise) and PaymentRequests need to have their User lookup fields updated directly on the object. They don't actually use R&R objects.
                    if (objectsNeedManualRoleUpdate.contains(String.valueOf(idIterator.getSObjectType()))) {
                        objectIdsForManualUpdateRR.add(idIterator);
                    }
                    else {
                        objectIdsForMassUpdateRR.add(idIterator);
                    }
                }
                System.debug('Size: ' + objectIdsForManualUpdateRR.size() + ' , objectIdsForManualUpdateRR: ' + objectIdsForManualUpdateRR);
                System.debug('Size: ' + objectIdsForMassUpdateRR.size() + ' , objectIdsForMassUpdateRR ' + objectIdsForMassUpdateRR);
    
                if (objectIdsForMassUpdateRR.size() > 0) {
                    //Retrieve the relevant R&R objects for applicable objects. Each R&R object will only contain a non-null lookup reference to one non-program object at a time
                    List<RolesAndResponsibilities__c> rrList = [
                        SELECT Id, Name__c, BusinessRole__c, Program__c, Announcement__c, Application__c, Grant__c, Award__c 
                        FROM RolesAndResponsibilities__c
                        WHERE Announcement__c IN: objectIdsForMassUpdateRR OR Application__c IN: objectIdsForMassUpdateRR OR Grant__c IN: objectIdsForMassUpdateRR OR Award__c IN: objectIdsForMassUpdateRR];
                    System.debug('rrList size: ' + rrList.size() + ' , rrList: ' + rrList);
                    List<RolesAndResponsibilities__c> rrUpdateBucket = new List<RolesAndResponsibilities__c>();
                    for (RolesAndResponsibilities__c triggerIterator : newTriggerMapOldTrigger.keySet()) {  
                        Set<Id> childObjectSet = parentObjectIdMapChildObjectIdSet.get(getLookupObjectId(triggerIterator)); //Need to go through all childrenObjectIds for each parentObjectId
                        for (RolesAndResponsibilities__c rrIterator : rrList) {
                            System.debug('rrIterator before edit: ' + rrIterator);
                            Id objectId = getLookupObjectId(rrIterator);
                            if (childObjectSet.contains(objectId) && !objectsNeedManualRoleUpdate.contains(String.valueOf(objectId.getSObjectType()))) { //The current R&R object is linked to a child object of the parent object, we only use the R&R objects whose object lookup is amongst the current Parent's children
                                if (rrIterator.BusinessRole__c.equals(triggerIterator.BusinessRole__c)) {                                   
                                    if (lockedObjectIdsSet.contains(objectId)) { //Only have to handle changing the tasks & approval process if this was in one of those
                                        Map<Id, Id> oldUserMapNewUser = objectIdMapOldUserIdMapNewUserId.get(objectId);
                                        if (oldUserMapNewUser == null) {
                                            oldUserMapNewUser = new Map<Id, Id>();
                                            objectIdMapOldUserIdMapNewUserId.put(objectId, oldUserMapNewUser);
                                        }
                                        System.debug('MANUALDEBUG >>> objectId: ' + objectId + ', oldUserMapNewUser: ' + oldUserMapNewUser.get(objectId));
                                        oldUserMapNewUser.put(rrIterator.Name__c, triggerIterator.Name__c); 
                                    }
                                    rrIterator.Name__c = triggerIterator.Name__c; //Modify the User lookup for the specified business role
                                    rrUpdateBucket.add(rrIterator); //This R&R object will be subject to update
                                    System.debug('rrIterator after edit: ' + rrIterator);
                                }
                            }    
                        }
                    }
                    //Skip this method call for the child R&R updates as we already have modified the data and thus don't need to use the method again
                    if (rrUpdateBucket.size() > 0) {
                        skipMassUpdateTrigger = true;
                        GrantTriggerHelper.skipTrigger = true;
                        USBEAwardTriggerHelper.skipTrigger = true;
                        USBEAwardTriggerHelper.skipTriggers = true;
                        USBEAwardTriggerHelper.skipfromAmendment = true;
                        AwardBudgetCategoryTriggerHelper.skipTrigger = true;
                        USBEAnnouncementTriggerHelper.skipTrigger = true;
                        ProgramTriggerHelperUSBE.skipTrigger = true;
                        update rrUpdateBucket;
                        GrantTriggerHelper.skipTrigger = false;
                        USBEAwardTriggerHelper.skipTrigger = false;
                        USBEAwardTriggerHelper.skipTriggers = false;
                        USBEAwardTriggerHelper.skipfromAmendment = false;
                        AwardBudgetCategoryTriggerHelper.skipTrigger = false;
                        USBEAnnouncementTriggerHelper.skipTrigger = false;
                        ProgramTriggerHelperUSBE.skipTrigger = false;
                        skipMassUpdateTrigger = false;     
                    }
                }
                if (objectIdsForManualUpdateRR.size() > 0) {
                    Set<Id> amendmentRequestIds = new Set<Id>();
                    Set<Id> paymentRequestIds = new Set<Id>();
                    for (Id idIterator : objectIdsForManualUpdateRR){
                        if (String.valueOf(idIterator.getSObjectType()) == 'AmendmentRequest__c') {
                            amendmentRequestIds.add(idIterator);
                        }
                        else if (String.valueOf(idIterator.getSObjectType()) == 'PaymentRequest__c') {
                            paymentRequestIds.add(idIterator);
                        }
                    }
                    List<AmendmentRequest__c> amendmentRequestList;
                    List<PaymentRequest__c> paymentRequestList;
                    if (amendmentRequestIds.size() > 0) {
                        amendmentRequestList = [
                            SELECT Id, ExecutiveApprover__c, GrantsManager__c, PaymentApprover1__c, PaymentApprover2__c, PaymentApprover3__c, PaymentApprover4__c 
                            FROM AmendmentRequest__c 
                            WHERE Id IN: amendmentRequestIds];
                    }
                    if (paymentRequestIds.size() > 0) {
                        paymentRequestList = [
                            SELECT Id, Approver1__c, Approver2__c, Approver3__c, Approver4__c 
                                FROM PaymentRequest__c 
                            WHERE Id IN: paymentRequestIds];
                    }
                    List<AmendmentRequest__c> amendmentRequestUpdateBucket = new List<AmendmentRequest__c>();
                    List<PaymentRequest__c> paymentRequestUpdateBucket = new List<PaymentRequest__c>();
                    for (RolesAndResponsibilities__c triggerIterator : newTriggerMapOldTrigger.keySet()) {
                        String businessRole = triggerIterator.BusinessRole__c;
                        Set<Id> childObjectSet = parentObjectIdMapChildObjectIdSet.get(getLookupObjectId(triggerIterator));
                        if (amendmentRequestList != null && amendmentRequestList.size() > 0) {
                            for (AmendmentRequest__c amendmentRequestIterator : amendmentRequestList) {
                                if (childObjectSet.contains(amendmentRequestIterator.Id)) { //If this amendmentrequest is a child object of the trigger R&R's parent object
                                    Boolean applicableRoleChange = false;        
                                    Id oldUserId;                       
                                    if (businessRole.equals('Executive Approver')) { //Check if the business role user lookup field on the amendment request corresponds to the R&R object's. If so, change the field and tag it for update
                                        oldUserId = amendmentRequestIterator.ExecutiveApprover__c;
                                        amendmentRequestIterator.ExecutiveApprover__c = triggerIterator.Name__c;
                                        amendmentRequestUpdateBucket.add(amendmentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Grants Manager')) {
                                        oldUserId = amendmentRequestIterator.GrantsManager__c;
                                        amendmentRequestIterator.GrantsManager__c = triggerIterator.Name__c;
                                        amendmentRequestUpdateBucket.add(amendmentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 1')) {
                                        oldUserId = amendmentRequestIterator.PaymentApprover1__c;
                                        amendmentRequestIterator.PaymentApprover1__c = triggerIterator.Name__c;
                                        amendmentRequestUpdateBucket.add(amendmentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 2')) {
                                        oldUserId = amendmentRequestIterator.PaymentApprover2__c;
                                        amendmentRequestIterator.PaymentApprover2__c = triggerIterator.Name__c;
                                        amendmentRequestUpdateBucket.add(amendmentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 3')) {
                                        oldUserId = amendmentRequestIterator.PaymentApprover3__c;
                                        amendmentRequestIterator.PaymentApprover3__c = triggerIterator.Name__c;
                                        amendmentRequestUpdateBucket.add(amendmentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 4')) {
                                        oldUserId = amendmentRequestIterator.PaymentApprover4__c;
                                        amendmentRequestIterator.PaymentApprover4__c = triggerIterator.Name__c;
                                        amendmentRequestUpdateBucket.add(amendmentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    if (applicableRoleChange == true && lockedObjectIdsSet.contains(amendmentRequestIterator.Id)) { //Only have to handle changing the tasks & approval process if this was in one of those
                                        Map<Id, Id> oldUserMapNewUser = objectIdMapOldUserIdMapNewUserId.get(amendmentRequestIterator.Id);
                                        if (oldUserMapNewUser == null) {
                                            oldUserMapNewUser = new Map<Id, Id>();
                                            objectIdMapOldUserIdMapNewUserId.put(amendmentRequestIterator.Id, oldUserMapNewUser);
                                        }
                                        oldUserMapNewUser.put(oldUserId, triggerIterator.Name__c);  
                                    }
                                }
                            } 
                        }
                        if (paymentRequestList != null && paymentRequestList.size() > 0) {
                            for (PaymentRequest__c paymentRequestIterator : paymentRequestList) {
                                if (childObjectSet.contains(paymentRequestIterator.Id)) { //If this amendmentrequest is a child object of the trigger R&R's parent object
                                    Boolean applicableRoleChange = false;        
                                    Id oldUserId;  
                                    if (businessRole.equals('Payment Approver 1')) {
                                        oldUserId = paymentRequestIterator.Approver1__c;
                                        paymentRequestIterator.Approver1__c = triggerIterator.Name__c;
                                        paymentRequestUpdateBucket.add(paymentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 2')) {
                                        oldUserId = paymentRequestIterator.Approver2__c;
                                        paymentRequestIterator.Approver2__c = triggerIterator.Name__c;
                                        paymentRequestUpdateBucket.add(paymentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 3')) {
                                        oldUserId = paymentRequestIterator.Approver3__c;
                                        paymentRequestIterator.Approver3__c = triggerIterator.Name__c;
                                        paymentRequestUpdateBucket.add(paymentRequestIterator);
                                        applicableRoleChange = true;
                                    }
                                    else if (businessRole.equals('Payment Approver 4')) {
                                        oldUserId = paymentRequestIterator.Approver4__c;
                                        paymentRequestIterator.Approver4__c = triggerIterator.Name__c;
                                        paymentRequestUpdateBucket.add(paymentRequestIterator);
                                        applicableRoleChange = true;
                                    }  
                                    if (applicableRoleChange == true && lockedObjectIdsSet.contains(paymentRequestIterator.Id)) { //Only have to handle changing the tasks & approval process if this was in one of those
                                        Map<Id, Id> oldUserMapNewUser = objectIdMapOldUserIdMapNewUserId.get(paymentRequestIterator.Id);
                                        if (oldUserMapNewUser == null) {
                                            oldUserMapNewUser = new Map<Id, Id>();
                                            objectIdMapOldUserIdMapNewUserId.put(paymentRequestIterator.Id, oldUserMapNewUser);
                                        }
                                        oldUserMapNewUser.put(oldUserId, triggerIterator.Name__c);  
                                    }
                                }
                            }
                        }
                    }
                    if (amendmentRequestUpdateBucket.size() > 0) { AmendmentRequestTriggerHelper.skipTrigger = true; update amendmentRequestUpdateBucket; AmendmentRequestTriggerHelper.skipTrigger = false; }   
                    if (paymentRequestUpdateBucket.size() > 0) { USBEPaymentRequestTriggerHelper.skipTrigger = true; update paymentRequestUpdateBucket; USBEPaymentRequestTriggerHelper.skipTrigger = false; }
                }
                if (lockedObjectIdsSet.size() > 0) {
                    Approval.LockResult[] lockResultList = Approval.lock(lockedObjectIds, false);
                    helper.tasksApprovalUserUpdate(lockedObjectIds, objectIdMapOldUserIdMapNewUserId);
                }
            }
            catch (Exception e) {
                for(RolesAndResponsibilities__c rrIterator : (List<RolesAndResponsibilities__c>)Trigger.New) {
                    rrIterator.addError(e);
                }
            }
        }    
    }
     
     
     private void fullOverrideUpsertRoles(List<RolesAndResponsibilities__c> newTrigger) {

          Set<Id> parentObjectIdSet = new Set<Id>(); //The parent object Id(s) of which we want to find the child objects for    
           //Only execute the full override child update/insert for the inserted R&R(s) object who are flagged as wanting the full override
          for (RolesAndResponsibilities__c rolesIterator : newTrigger) {
               if(rolesIterator.ChangeChildObjects__c != null && rolesIterator.ChangeChildObjects__c.equals('Update All Derivative Records')) {               
                    Id parentObjectId = getLookupObjectId(rolesIterator); //Only a single non-program object lookup will exist on an R&R object at a time
                    if (parentObjectId != null) { parentObjectIdSet.add(parentObjectId); }
               }  
          }
         
          if (parentObjectIdSet.size() > 0) {
               AppUtils.EntityHierarchyResolver resolver = new AppUtils.EntityHierarchyResolver();          
               Set<Id> allChildIds = new Set<Id>();
               Map<Id, Set<String>> parentIdMapchildObjectNameSet = new Map<Id, Set<String>>();
               Map<Id, Set<Id>> parentObjectIdMapChildObjectIdSet = new Map<Id, Set<Id>>();
               for (Id idIterator : parentObjectIdSet) {
                    Set<Id> childObjectIdSet = new Set<Id>();
                    Set<String> childObjectNameSet = new Set<String>();
                    childObjectNameSet.addAll((resolver.entityNames).get(String.valueOf(idIterator.getSObjectType())));              
                    for (String childObjectName : childObjectNameSet) {
                         //To get the child Ids, pass it ('[next child object type]', new Set<Id>{'[parentObjectIdSet]'}) as per the map describes
                         //E.g. resolver.getIds('Program__c', new Set<Id>{'PARENT PROGRAM'S ID}; E.g. resolver.getIds('Grant__c', new Set<Id>{'PARENT APPLICATION's ID'}
                         childObjectIdSet.addAll(resolver.getIds(childObjectName, parentObjectIdSet)); 
                         allChildIds.addAll(childObjectIdSet);
                    }
                    parentObjectIdMapChildObjectIdSet.put(idIterator, childObjectIdSet);
               }         
               for (Id iter : allChildIds) { System.debug('Sobject: ' + String.valueOf(iter.getSObjectType()) + ' Id: ' + iter); } //Debug
               List<Id> lockedObjectIds = new List<Id>();
               for (Id idIterator : allChildIds) {
                   if(Approval.isLocked(idIterator)) { //Record is locked via an approval process
                       lockedObjectIds.add(idIterator);
                   }
               }
               try {
                   if (lockedObjectIds.size() > 0) {
                       System.debug('MANUALDEBUG >>> locked records: ' + lockedObjectIds);
                       for(RolesAndResponsibilities__c rrIterator : (List<RolesAndResponsibilities__c>)Trigger.New) {
                           //rrIterator.addError('Error: Updating roles on all derivative records has failed due to derivative records being locked via approval processes. Please wait for the approval processes to complete or contact an Administrator');
                           rrIterator.addError(new RecordLockedViaApprovalProcessException('Updating roles on all derivative records has failed due to derivative records being locked via approval processes. Please wait for the approval processes to complete or contact an Administrator'));
                       }
                       //Query through sObjectTypeMapObjectIds and get the name of each locked object. Then use those names in the error output for greater accuracy
                   }
                   else {
                       //Parse the list of child object Ids to find which ones are suitable for mass update and which need direct object update
                       Set<String> objectsNeedManualRoleUpsert = new Set<String>{'AmendmentRequest__c', 'PaymentRequest__c'};
                       List<Id> objectIdsForManualUpsertRR = new List<Id>();
                       List<Id> objectIdsForMassUpsertRR = new List<Id>();
                       for (Id idIterator : allChildIds) { //
                            //AmendmentRequests (well, budget revisions to be precise) and PaymentRequests need to have their User lookup fields updated directly on the object. They don't actually use R&R objects.
                            if (objectsNeedManualRoleUpsert.contains(String.valueOf(idIterator.getSObjectType()))) {
                                 objectIdsForManualUpsertRR.add(idIterator);
                            }
                            else {
                                 objectIdsForMassUpsertRR.add(idIterator);
                            }
                       }
                       System.debug('Size: ' + objectIdsForManualUpsertRR.size() + ' , objectIdsForManualUpsertRR: ' + objectIdsForManualUpsertRR);
                       System.debug('Size: ' + objectIdsForMassUpsertRR.size() + ' , objectIdsForMassUpsertRR ' + objectIdsForMassUpsertRR);
        
                       if (objectIdsForMassUpsertRR.size() > 0) {
                            //Retrieve the relevant R&R objects for applicable objects. Each R&R object will only contain a non-null lookup reference to one non-program object at a time
                            List<RolesAndResponsibilities__c> rrList = [
                                 SELECT Id, Name__c, BusinessRole__c, Program__c, Announcement__c, Application__c, Grant__c, Award__c 
                                 FROM RolesAndResponsibilities__c
                                 WHERE Announcement__c IN: objectIdsForMassUpsertRR OR Application__c IN: objectIdsForMassUpsertRR OR Grant__c IN: objectIdsForMassUpsertRR OR Award__c IN: objectIdsForMassUpsertRR];
                            System.debug('rrList size: ' + rrList.size() + ' , rrList: ' + rrList);
                            List<RolesAndResponsibilities__c> rrUpsertBucket = new List<RolesAndResponsibilities__c>();               
                            for (RolesAndResponsibilities__c triggerIterator : newTrigger) {  
                                 Set<Id> childObjectSet = parentObjectIdMapChildObjectIdSet.get(getLookupObjectId(triggerIterator)); //Need to go through all childrenObjectIds for each parentObjectId
                                 Boolean childObjectHasTriggerRR = false;
                                 for (Id idIterator : childObjectSet) { //Iterate through all the children object Ids of the current trigger RR's object Id
                                      //List<RolesAndResponsibilities__c> associatedListRR = new List<RolesAndResponsibilities__c>();
                                      if (!objectsNeedManualRoleUpsert.contains(String.valueOf(idIterator.getSObjectType()))) {
                                          RolesAndResponsibilities__c associatedRR;
                                          for (RolesAndResponsibilities__c rrIterator : rrList) {
                                               System.debug('rrIterator: ' + rrIterator);
                                               Id objectId = getLookupObjectId(rrIterator);
                                               if (idIterator.equals(objectId) && rrIterator.BusinessRole__c.equals(triggerIterator.BusinessRole__c)) { //There exists an R&R that corresponds to that objectId and business role
                                                    //associatedListRR.add(rrIterator);
                                                    associatedRR = rrIterator; //Only one RR will exist on an object for one specific business role
                                               }
                                          }
                                          if (associatedRR != null) { //If child object has a R&R object for the trigger's business role)
                                               associatedRR.Name__c = triggerIterator.Name__c; //Modify the User lookup for the specified business role
                                               rrUpsertBucket.add(associatedRR); //This R&R object will be subject to update
                                               System.debug('associatedRR after edit: ' + associatedRR);
                                          }
                                          else { //That child object Id DOES NOT contain an R&R object for that business role
                                               associatedRR = new RolesAndResponsibilities__c(); //create a new R&R object based on the trigger object's for that child object
                                               associatedRR.Agency__c = triggerIterator.Agency__c;
                                               associatedRR.RecordTypeId = triggerIterator.RecordTypeId;
                                               associatedRR.UserType__c = triggerIterator.UserType__c;
                                               associatedRR.Name__c = triggerIterator.Name__c;
                                               associatedRR.BusinessRole__c = triggerIterator.BusinessRole__c;
                                               associatedRR.put(String.valueOf(idIterator.getSObjectType()), idIterator); //e.g. if announcement object, fill RR's announcement field. if award object fill RR's award field
                                               associatedRR.Program__c = triggerIterator.Program__c;
                                               rrUpsertBucket.add(associatedRR); //Insert new R&R object with relevant fields copying from the trigger R&R's
                                               System.debug('associatedRR inserted: ' + associatedRR);
                                          }
                                      }  
                                 }
                            }
                            //Skip this method call for the child R&R updates as we already have modified the data and thus don't need to use the method again
                            if (rrUpsertBucket.size() > 0) {
                                 //for (RolesAndResponsibilities__c rrIt : rrUpsertBucket) { System.debug('Upsert RR: objectId=' + getLookupObjectId(rrIt) + ' rrId=' + rrIt); }
                                 skipMassUpdateTrigger = true;
                                 skipInsertRoleQueue = true;
                                 upsert rrUpsertBucket;
                                 skipMassUpdateTrigger = false;
                                 skipInsertRoleQueue = false;
                            }
                       }
                       if (objectIdsForManualUpsertRR.size() > 0) {
                            Set<Id> amendmentRequestIds = new Set<Id>();
                            Set<Id> paymentRequestIds = new Set<Id>();
                            for (Id idIterator : objectIdsForManualUpsertRR){
                                 if (String.valueOf(idIterator.getSObjectType()) == 'AmendmentRequest__c') {
                                      amendmentRequestIds.add(idIterator);
                                 }
                                 else if (String.valueOf(idIterator.getSObjectType()) == 'PaymentRequest__c') {
                                      paymentRequestIds.add(idIterator);
                                 }
                            }
                            List<AmendmentRequest__c> amendmentRequestList;
                            List<PaymentRequest__c> paymentRequestList;
                            if (amendmentRequestIds.size() > 0) {
                                 amendmentRequestList = [
                                      SELECT Id, ExecutiveApprover__c, GrantsManager__c, PaymentApprover1__c, PaymentApprover2__c, PaymentApprover3__c, PaymentApprover4__c 
                                      FROM AmendmentRequest__c 
                                      WHERE Id IN: amendmentRequestIds];
                            }
                            Map<String, String> amendmentRequestRoleMapUserField = new Map<String, String>{
                                 'Executive Approver' => 'ExecutiveApprover__c',
                                 'Grants Manager' => 'GrantsManager__c',
                                 'Payment Approver 1' => 'PaymentApprover1__c',
                                 'Payment Approver 2' => 'PaymentApprover2__c',
                                 'Payment Approver 3' => 'PaymentApprover3__c',
                                 'Payment Approver 4' => 'PaymentApprover4__c'
                            };
                            if (paymentRequestIds.size() > 0) {
                                 paymentRequestList = [
                                      SELECT Id, Approver1__c, Approver2__c, Approver3__c, Approver4__c 
                                      FROM PaymentRequest__c 
                                      WHERE Id IN: paymentRequestIds];
                            }
                             Map<String, String> paymentRequestRoleMapUserField = new Map<String, String>{
                                 'Payment Approver 1' => 'Approver1__c',
                                 'Payment Approver 2' => 'Approver2__c',
                                 'Payment Approver 3' => 'Approver3__c',
                                 'Payment Approver 4' => 'Approver4__c'
                            };
                            List<AmendmentRequest__c> amendmentRequestUpsertBucket = new List<AmendmentRequest__c>();
                            List<PaymentRequest__c> paymentRequestUpsertBucket = new List<PaymentRequest__c>();
                            for (RolesAndResponsibilities__c triggerIterator : newTrigger) {
                                 String businessRole = triggerIterator.BusinessRole__c;
                                 Set<Id> childObjectSet = parentObjectIdMapChildObjectIdSet.get(getLookupObjectId(triggerIterator));
                                 if (amendmentRequestList != null && amendmentRequestList.size() > 0) {
                                     for (AmendmentRequest__c amendmentRequestIterator : amendmentRequestList) {
                                          if (childObjectSet.contains(amendmentRequestIterator.Id) && (amendmentRequestRoleMapUserField.keySet()).contains(businessRole)) { //If this amendmentrequest is a child object of the trigger R&R's parent object
                                               for (String roleIterator : amendmentRequestRoleMapUserField.keySet()) {
                                                    if (businessRole.equals(roleIterator)) { //Check if the business role user lookup field on the amendment request corresponds to the R&R object's. If so, change the field and tag it for update
                                                         //If the business role field's user lookup isn't null, then we just update the reference. If it isn't we need to add in the reference
                                                         if (amendmentRequestIterator.get(amendmentRequestRoleMapUserField.get(roleIterator)) == null || amendmentRequestIterator.get(amendmentRequestRoleMapUserField.get(roleIterator)) != triggerIterator.Name__c) {
                                                              amendmentRequestIterator.put(amendmentRequestRoleMapUserField.get(roleIterator), triggerIterator.Name__c); //Set the object's BusinessRoleField to the User Id
                                                              amendmentRequestUpsertBucket.add(amendmentRequestIterator); 
                                                         }
                                                    }
                                               }
                                          }
                                     }
                                 }
                                 if (paymentRequestList != null && paymentRequestList.size() > 0) {
                                     for (PaymentRequest__c paymentRequestIterator : paymentRequestList) {
                                          if (childObjectSet.contains(paymentRequestIterator.Id) && (paymentRequestRoleMapUserField.keySet()).contains(businessRole)) { //If this amendmentrequest is a child object of the trigger R&R's parent object
                                               for (String roleIterator : paymentRequestRoleMapUserField.keySet()) {
                                                    if (businessRole.equals(roleIterator)) { //Check if the business role user lookup field on the amendment request corresponds to the R&R object's. If so, change the field and tag it for update
                                                         if (paymentRequestIterator.get(paymentRequestRoleMapUserField.get(roleIterator)) == null || paymentRequestIterator.get(paymentRequestRoleMapUserField.get(roleIterator)) != triggerIterator.Name__c) {
                                                              paymentRequestIterator.put(paymentRequestRoleMapUserField.get(roleIterator), triggerIterator.Name__c); //Set the object's BusinessRoleField to the User Id
                                                              paymentRequestUpsertBucket.add(paymentRequestIterator);     
                                                         }
                                                    }
                                               }
                                          }
                                     }
                                 }
                            }
                            System.debug('amendmentRequestUpsertBucket: ' + amendmentRequestUpsertBucket);
                            System.debug('paymentRequestUpsertBucket: ' + paymentRequestUpsertBucket);
                            if (amendmentRequestUpsertBucket.size() > 0) { upsert amendmentRequestUpsertBucket; }   
                            if (paymentRequestUpsertBucket.size() > 0) { USBEPaymentRequestTriggerHelper.skipTrigger = true; upsert paymentRequestUpsertBucket; USBEPaymentRequestTriggerHelper.skipTrigger = false; }
                       }
                   }    
               }
               catch (RecordLockedViaApprovalProcessException  e) {
                   for(RolesAndResponsibilities__c rrIterator : (List<RolesAndResponsibilities__c>)Trigger.New) {
                       rrIterator.addError(e);
                   }    
               }
               catch (Exception e) {
                   for(RolesAndResponsibilities__c rrIterator : (List<RolesAndResponsibilities__c>)Trigger.New) {
                       rrIterator.addError(e);
                   }
               }
          }    
     }
    
}