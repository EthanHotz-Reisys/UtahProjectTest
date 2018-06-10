/*
    All code for Trigger on Announcement Object
    ***********************************************************
    Audit History
    ***********************************************************
    03/06/2014      Vineeth Shetty             Created
    2015-08-25         Ramu Loke           Created insertOwnerinRolesandResp()
    2015-07-01         Ramu Loke           Created SetAnnouncementDetails();
    2015-11-30         Pankaj              Added skipTrigger
    2017-05-04         Charan              deleteQualifiedAnnouncement();
    ***********************************************************
*/
public with sharing class AnnouncementTriggerHelper extends GNT.TriggerHelper {
    public static Boolean skipTrigger = false;
    private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');

    public override void processBeforeInsert() {
        system.debug('--skipTrigger--' + skipTrigger);
        if (skipTrigger == false) {
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            system.debug('--appName--' + appName);
            if (appName == 'StateasGrantee') {
                SetAnnouncementDetails();
            }
            if (appName == null || appName == 'StateasGrantor') {
                ReviewStepTemplateHelper.beforeInsert();
                updateApplicationReviewStatus();
                validateFiscalYearObjects(Trigger.new);
             }
            GNT.NameTemplateTriggerHelper.beforeInsert();
            shareWithInternalUsers(Trigger.New);
        }
    }
    public override void processAfterInsert() {
        if (skipTrigger == false) {
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            UpdateOrgNoofAnnouncements(trigger.new);
            shareToInternalUsers(trigger.new);
            copyProjectAreas();
            insertOwnerinRolesandResp();
            if (appName == 'StateasGrantee') {
                //copyGranteeBudgetCategories();

            }
            if (appName == null || appName == 'StateasGrantor') {
                system.debug('--processAfterInsert--');
                updateApprover(Trigger.New);
                ReviewStepTemplateHelper.afterInsert();
                //updateAttachments1();
                updateProgramAttachments();
                copyBudgetPeriods();
                //copyProjectAreas();
                copyPackageFieldsFromProgram();
                copyAnnouncementBudgetPeriods();
                copyBudgetCategories();
                copyFundingAccounts();
                copyProgramFields();
                updateRFAReleaseDate();
                copyReportingRequirements(Trigger.New);
                //copyReviewers(Trigger.New);
                //createAnnouncementGoalsAndObjectives((List<Announcement__c>)Trigger.New);
            }
        }
    }

    public override void processAfterUpdate() {
        if (skipTrigger == false) {
            UpdateOrgNoofAnnouncements(trigger.new);
            shareToInternalUsers(trigger.new);
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            if (appName == 'StateasGrantee') {
                insertDummyPackage(Trigger.new);
                InsertBudgetPerioddates();
            }
            if (appName == 'StateasGrantor') {
                //createTaskOnSendBack(Trigger.new);

                shareToExternalUsers();
            }
            deleteTasksForReviewers((List<Announcement__c>)Trigger.new);
        }
    }

    public override void processBeforeUpdate() {
        if (skipTrigger == false) {
            if (UserInfo.getUserType() == 'Standard') {
                deleteShareIfProgramChanged();
            }
            updateShareWithInternalUsers();
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            if (appName == null || appName == 'StateasGrantor') {
                updateStatus();
            }
        }
    }

    public override void processBeforeDelete() {
        if (skipTrigger == false) {
            UpdateOrgNoofAnnouncements(Trigger.old);
            if (appName == 'StateasGrantor') {
                deleteQualifiedAnnouncement();
            }
            if (appName == 'StateasGrantee') changeLeadStatus((List<Announcement__c>)Trigger.old);
        }
    }


    // Pankaj : Copy package config fields from program to announcements.
    private void copyPackageFieldsFromProgram() {
        Map<String, String> prgmByAnnoucement = new Map<String, String>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            prgmByAnnoucement.put( announcement.Id, announcement.Program__c);
        }
        System.debug('prgmByAnnoucement=======' + prgmByAnnoucement);
        List<BusinessPackage__c> businessPackages = [select id, name, FundingOpportunity__c, IsMandatory__c, PackageConfig__c, PackageType__c, Program__c from BusinessPackage__c where
                Program__c in: prgmByAnnoucement.values() ];
        Map<String, List<BusinessPackage__c>> businessPackageByProgram  = new Map<String, List<BusinessPackage__c>>();
        for (BusinessPackage__c businessPackage : businessPackages) {
            if (!businessPackageByProgram.containsKey(businessPackage.Program__c)) {
                businessPackageByProgram.put(businessPackage.Program__c, new List<BusinessPackage__c>() );
            }
            businessPackageByProgram.get(businessPackage.Program__c).add( businessPackage );
        }
        System.debug('businessPackageByProgram=======' + businessPackageByProgram);
        List<BusinessPackage__c> businessPackageToInsert = new List<BusinessPackage__c>();
        for (String annoucementId : prgmByAnnoucement.keySet() ) {
            System.debug('prgmByAnnoucement.keySet()=======' + prgmByAnnoucement.keySet());
            if (prgmByAnnoucement.get(annoucementId) != null) {
                List<BusinessPackage__c> annBusinessPackages = businessPackageByProgram.get(prgmByAnnoucement.get(annoucementId));
                if (annBusinessPackages != null && annBusinessPackages.size() > 0) {
                    for (BusinessPackage__c businessPkg : annBusinessPackages) {
                        businessPackageToInsert.add(new BusinessPackage__c(FundingOpportunity__c = annoucementId, IsMandatory__c = businessPkg.IsMandatory__c, PackageConfig__c = businessPkg.PackageConfig__c,
                                                    PackageType__c = businessPkg.PackageType__c) );
                    }
                }
            }
        }
        System.debug('businessPackageToInsert=======' + businessPackageToInsert);
        if (businessPackageToInsert.size() > 0) {
            insert businessPackageToInsert;
        }
        /*Map<String, Map<String, AppConfigSObject__c>> packageMap = getPackageConfigInfo();
        String namespace = AppUtils.getNamespacePrefix();
        if( packageMap.get(namespace+'Program__c').size() > 0 ){
            String query = 'select id,name,';
            for(String packageType : packageMap.get(namespace+'Program__c').keySet()) {
                query = query + packageMap.get(namespace+'Program__c').get(packageType).PackageFieldAPIName__c+', ';
                if(packageMap.get(namespace+'Program__c').get(packageType).RequiredFieldAPIName__c != null ){
                    query = query + packageMap.get(namespace+'Program__c').get(packageType).RequiredFieldAPIName__c+', ';
                }
            }
            query = query.subString(0, query.length() - 2);
            List<String> pgmAnnouncemtLst = prgmByAnnoucement.values();
            query = query + ' from Program__c where Id in :pgmAnnouncemtLst';
            Map<String, Program__c> prgmMap = new Map<String, Program__c>((List<Program__c>)Database.query(query));

            for(Announcement__c announcement : (List<Announcement__c>) Trigger.New){
                for(String apiType : packageMap.get(namespace+'Announcement__c').keySet()){
                    if(packageMap.get(namespace+'Program__c').containsKey(apiType)){
                        if( prgmMap.get(prgmByAnnoucement.get(announcement.Id)) != null ) {
                            if(packageMap.get(namespace+'Program__c').get(apiType).RequiredFieldAPIName__c != null &&
                                prgmMap.get(prgmByAnnoucement.get(announcement.Id)).get( packageMap.get(namespace+'Program__c').get(apiType).RequiredFieldAPIName__c) == true ){
                                    announcement.put( packageMap.get(namespace+'Announcement__c').get(apiType).PackageFieldAPIName__c, prgmMap.get(prgmByAnnoucement.get(announcement.Id)).get( packageMap.get(namespace+'Program__c').get(apiType).PackageFieldAPIName__c ) );
                                }
                        }
                    }
                }
            }
        }*/
    }

    /*private Map<String, Map<String, AppConfigSObject__c>> getPackageConfigInfo() {
        String namespace = AppUtils.getNamespacePrefix();
        Map<String, Map<String, AppConfigSObject__c>> returnMap = new Map<String, Map<String, AppConfigSObject__c>>();
        List<String> sObjList = new List<String>{namespace+'Announcement__c', namespace+'Program__c'};
        List<AppConfigSObject__c> appConfiSObjList = [select id,name,ParentSObjectName__c,PackageFieldAPIName__c,RequiredFieldAPIName__c,PackageType__c from AppConfigSObject__c where ParentSObjectName__c in :sObjList];
        for( AppConfigSObject__c appConfigSObject : appConfiSObjList ) {
            if( !returnMap.containskey(appConfigSObject.ParentSObjectName__c) ){
                returnMap.put( appConfigSObject.ParentSObjectName__c, new Map<String, AppConfigSObject__c>() );
            }
            returnMap.get(appConfigSObject.ParentSObjectName__c).put(appConfigSObject.PackageType__c, appConfigSObject );
        }
        return returnMap;
    }*/

    /*Insert RecordType as 'Grantee'*/
    private void SetAnnouncementDetails() {
        System.debug('>>>>>>>>>>>>>>><<<<<<<<<<<');

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'Announcement__c' and Name = 'Grantee'];
        if (appName != null && appName == 'StateasGrantee') {
            for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
                if (!recordTypeList.isEmpty()) {
                    announcement.recordTypeId = recordTypeList[0].Id;
                    announcement.Status__c = 'Created';
                }
            }
        }
    }

    /* Insert owner of Opportunity in Roles and Responsibility*/

    private void insertOwnerinRolesandResp() {
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        String OppRecordtype = 'GrantorAnnouncement';
        if (appName == 'StateasGrantee') {
            OppRecordtype = 'Opportunity';
        }
        List<RolesAndResponsibilities__c> listrolesandresp = new List<RolesAndResponsibilities__c>();
        List<RecordType> recordTypeList = [select Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'RolesAndResponsibilities__c' and DeveloperName = :OppRecordtype];
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            RolesAndResponsibilities__c rresp = new RolesAndResponsibilities__c();
            rresp.Announcement__c = announcement.id;
            rresp.Name__c = announcement.ownerid;
            //rresp.Role__c = 'Other';
            rresp.BusinessRole__c = 'Owner';
            rresp.recordTypeId = recordTypeList[0].Id;
            listrolesandresp.add(rresp);
        }
        if (!listrolesandresp.isempty()) insert listrolesandresp;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = false;
    }

    private void updateApplicationReviewStatus() {
        for (Announcement__c ann : (List<Announcement__c>)trigger.new) {
            ann.ApplicationsReviewStatus__c = 'Not Started';
        }
    }

    /* Shivankar: Updating attachment templates on Announcement from Program */
    //private void updateAttachments() {
    //    Map<Id,List<GNT__AttachmentExtension__c>> ProgAttachments=new Map<Id,List<GNT__AttachmentExtension__c>>();
    //    GNT__AttachmentExtension__c annAttachment=new GNT__AttachmentExtension__c();
    //    System.debug('updateAttachments1');

    //    List<Id> ProgramAttachmentIDs=new List<Id>();
    //    for (Announcement__c ann : (List<Announcement__c>)trigger.new) {
    //        ProgramAttachmentIDs.add(ann.Program__c);
    //    }
    //    for (GNT__AttachmentExtension__c attch: [Select Id,GNT__ParentId__c,GNT__AttachmentName__c,GNT__AttachmentURL__c,
    //        GNT__Attachment__c,GNT__Classification__c,GNT__DigitalSignature__c,GNT__HistoryReason__c,GNT__IsCloned__c
    //        ,GNT__signedDocument__c from GNT__AttachmentExtension__c where GNT__ParentId__c in :ProgramAttachmentIDs])
    //    {
    //        System.debug('updateAttachments2');
    //        List<GNT__AttachmentExtension__c> list1=new List<GNT__AttachmentExtension__c>();
    //        if (!ProgAttachments.containsKey(attch.GNT__ParentId__c))
    //        {
    //            list1.add(attch);
    //            ProgAttachments.put(attch.GNT__ParentId__c,list1);
    //        }
    //        else{
    //            list1=ProgAttachments.get(attch.GNT__ParentId__c);
    //            list1.add(attch);
    //            ProgAttachments.put(attch.GNT__ParentId__c,list1);
    //        }
    //    }

    //    GNT__AttachmentExtension__c AnnAttch=new GNT__AttachmentExtension__c();
    //    List<GNT__AttachmentExtension__c> ListAnnAttch=new List<GNT__AttachmentExtension__c>();
    //    List<GNT__AttachmentExtension__c> ListAnnAttch1=new List<GNT__AttachmentExtension__c>();      
    //    for (Announcement__c ann : (List<Announcement__c>)trigger.new) {
    //        System.debug('updateAttachments3 '+ann.AnnouncementName__c+' '+ann.Program__c);
    //          Id progid=ann.program__c;
    //          ListAnnAttch=new List<GNT__AttachmentExtension__c>();
    //          if (ProgAttachments.containsKey(progid)){
    //            ListAnnAttch=ProgAttachments.get(progid);
    //            System.debug('updateAttachments3 '+ListAnnAttch);
    //            for (GNT__AttachmentExtension__c attch1: ListAnnAttch){
    //                AnnAttch=new GNT__AttachmentExtension__c();
    //                AnnAttch.GNT__ParentId__c=ann.Id;
    //                AnnAttch.GNT__AttachmentName__c=attch1.GNT__AttachmentName__c;
    //                AnnAttch.GNT__Attachment__c=attch1.GNT__Attachment__c;
    //                //AnnAttch.GNT__AttachmentURL__c=attch1.GNT__AttachmentURL__c;
    //                AnnAttch.GNT__Classification__c=attch1.GNT__Classification__c;
    //                AnnAttch.GNT__HistoryReason__c=attch1.GNT__HistoryReason__c;
    //                AnnAttch.GNT__DigitalSignature__c=attch1.GNT__DigitalSignature__c;
    //                AnnAttch.GNT__signedDocument__c=attch1.GNT__signedDocument__c;
    //                ListAnnAttch1.add(AnnAttch);
    //            }
    //        }
    //     }
    //     insert ListAnnAttch1;
    //}
    //private void updateAttachments1() {
    //    Map<Id,List<GNT__AttachmentExtension__c>> ProgAttachments=new Map<Id,List<GNT__AttachmentExtension__c>>();
    //    GNT__AttachmentExtension__c annAttachment=new GNT__AttachmentExtension__c();
    //    System.debug('updateAttachments1');

    //    List<Id> ProgramAttachmentIDs=new List<Id>();
    //    for (Announcement__c ann : (List<Announcement__c>)trigger.new) {
    //        ProgramAttachmentIDs.add(ann.Program__c);
    //    }
    //    List<Attachment> newAttachments=new List<Attachment>();
    //    Map<Id,Attachment> mapAttachments=new Map<Id,Attachment>();
    //    for (Attachment attachmnt:[SELECT Id,Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,IsDeleted,IsPrivate,
    //        LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment where ParentId in :ProgramAttachmentIDs])
    //    {
    //        Attachment newAttach=new Attachment();
    //        newAttach.Body=attachmnt.Body;
    //        newAttach.ContentType=attachmnt.ContentType;
    //        newAttach.Description=attachmnt.Description;
    //        newAttach.IsPrivate=attachmnt.IsPrivate;
    //        newAttach.Name=attachmnt.Name;
    //        newAttach.OwnerId=attachmnt.OwnerId;
    //        mapAttachments.put(attachmnt.id,newAttach);
    //        //newAttachments.add(newAttach);
    //    }

    //    for (GNT__AttachmentExtension__c attch: [Select Id,GNT__ParentId__c,GNT__AttachmentName__c,GNT__AttachmentURL__c,
    //        GNT__Attachment__c,GNT__Classification__c,GNT__DigitalSignature__c,GNT__HistoryReason__c,GNT__IsCloned__c
    //        ,GNT__signedDocument__c from GNT__AttachmentExtension__c where GNT__ParentId__c in :ProgramAttachmentIDs])
    //    {
    //        System.debug('updateAttachments2');
    //        List<GNT__AttachmentExtension__c> list1=new List<GNT__AttachmentExtension__c>();
    //        if (!ProgAttachments.containsKey(attch.GNT__ParentId__c))
    //        {
    //            list1.add(attch);
    //            ProgAttachments.put(attch.GNT__ParentId__c,list1);
    //        }
    //        else{
    //            list1=ProgAttachments.get(attch.GNT__ParentId__c);
    //            list1.add(attch);
    //            ProgAttachments.put(attch.GNT__ParentId__c,list1);
    //        }
    //    }

    //    GNT__AttachmentExtension__c AnnAttch=new GNT__AttachmentExtension__c();
    //    List<GNT__AttachmentExtension__c> ListAnnAttch=new List<GNT__AttachmentExtension__c>();
    //    List<GNT__AttachmentExtension__c> ListAnnAttch1=new List<GNT__AttachmentExtension__c>(); 
    //    Map<ID,Attachment> AnnAttachMap=new Map<ID,Attachment>();     
    //    for (Announcement__c ann : (List<Announcement__c>)trigger.new) {
    //        System.debug('updateAttachments3 '+ann.AnnouncementName__c+' '+ann.Program__c);
    //          Id progid=ann.program__c;
    //          ListAnnAttch=new List<GNT__AttachmentExtension__c>();
    //          if (ProgAttachments.containsKey(progid)){
    //            ListAnnAttch=ProgAttachments.get(progid);
    //            System.debug('updateAttachments3 '+ListAnnAttch);
    //            for (GNT__AttachmentExtension__c attch1: ListAnnAttch){
    //                Attachment updatedAttachment=mapAttachments.get(attch1.GNT__Attachment__c);
    //                updatedAttachment.ParentId=ann.Id;
    //                AnnAttachMap.put(ann.Id,updatedAttachment);
    //                newAttachments.add(updatedAttachment);
    //            }
    //        }
    //     }
    //      System.debug('****');
    //     System.debug('newAttachments:'+newAttachments);
    //     System.debug('newAttachmentsMap:'+AnnAttachMap);
    //     insert newAttachments;

    //     for (Announcement__c ann : (List<Announcement__c>)trigger.new) {
    //        System.debug('updateAttachments3 '+ann.AnnouncementName__c+' '+ann.Program__c);
    //          Id progid=ann.program__c;
    //          ListAnnAttch=new List<GNT__AttachmentExtension__c>();
    //          if (ProgAttachments.containsKey(progid)){
    //            ListAnnAttch=ProgAttachments.get(progid);
    //            System.debug('updateAttachments3 '+ListAnnAttch);
    //            for (GNT__AttachmentExtension__c attch1: ListAnnAttch){
    //                Attachment updatedAttachment1=AnnAttachMap.get(ann.Id);
    //                AnnAttch=new GNT__AttachmentExtension__c();
    //                AnnAttch.GNT__Attachment__c=updatedAttachment1.Id;
    //                AnnAttch.GNT__ParentId__c=ann.Id;
    //                AnnAttch.GNT__AttachmentName__c=attch1.GNT__AttachmentName__c;
    //                AnnAttch.GNT__Classification__c=attch1.GNT__Classification__c;
    //                AnnAttch.GNT__HistoryReason__c=attch1.GNT__HistoryReason__c;
    //                AnnAttch.GNT__DigitalSignature__c=attch1.GNT__DigitalSignature__c;
    //                AnnAttch.GNT__signedDocument__c=attch1.GNT__signedDocument__c;
    //                ListAnnAttch1.add(AnnAttch);
    //                //newAttachments.add(updatedAttachment);

    //            }
    //        }
    //     }
         
    //     insert ListAnnAttch1;
    //}

    public void updateProgramAttachments()
    {
        
        List<Id> ProgramAttachmentIDs=new List<Id>();
        List<ID> Announcements = new List<ID>();
        List<Attachment> newAttachments=new List<Attachment>();
        List<Attachment> OldAttachments=new List<Attachment>();
       for (Announcement__c ann: (List<Announcement__c>)trigger.new)
       {
        Announcements.add(ann.id);
        ProgramAttachmentIDs.add(ann.program__c);
       }

       Map<Id,List<Attachment>> ProgAttachments=new Map<Id,List<Attachment>>();
        
       for (Attachment attachment:[SELECT Id,Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,IsDeleted,IsPrivate,
            LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId,SystemModstamp FROM Attachment where ParentId in :ProgramAttachmentIDs])
        {
            System.debug('updateAttachments2');
            List<Attachment> list1=new List<Attachment>();
            if (!ProgAttachments.containsKey(attachment.parentid))
            {
                list1.add(attachment);
                ProgAttachments.put(attachment.parentid,list1);
            }
            else{
                list1=ProgAttachments.get(attachment.parentid);
                list1.add(attachment);
                ProgAttachments.put(attachment.parentid,list1);
            }
        }
        Map<Id,Id> mapAttachments=new Map<Id,Id>();
        for (Integer i=0;i<ProgramAttachmentIDs.size();i++)
        {
            Id programId=ProgramAttachmentIDs.get(i);
            Id AnnId=Announcements.get(i);
            if (ProgAttachments.containsKey(programId))
            {
                List<Attachment> AttachmentList=ProgAttachments.get(programId);
                for (Attachment attachmnt:AttachmentList) {
                Attachment newAttach=new Attachment();
                newAttach.Body=attachmnt.Body;
                newAttach.ContentType=attachmnt.ContentType;
                newAttach.Description=attachmnt.Description;
                newAttach.IsPrivate=attachmnt.IsPrivate;
                newAttach.Name=attachmnt.Name;
                newAttach.OwnerId=attachmnt.OwnerId;
                newAttach.parentId=AnnId;
                newAttachments.add(newAttach);
                OldAttachments.add(attachmnt);
                }
            }
        }
        //insert newAttachments;

        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.insertAttachments(newAttachments);

        for (Integer i=0;i<OldAttachments.size();i++)
        mapAttachments.put(OldAttachments.get(i).id,newAttachments.get(i).id);
                

      Map<Id,List<GNT__AttachmentExtension__c>>  ProgAttachmentExtensions=new Map<Id,List<GNT__AttachmentExtension__c>>();
      for (GNT__AttachmentExtension__c attch: [Select Id,GNT__ParentId__c,GNT__AttachmentName__c,GNT__AttachmentURL__c,
            GNT__Attachment__c,GNT__Classification__c,GNT__DigitalSignature__c,GNT__HistoryReason__c,GNT__IsCloned__c
            ,GNT__signedDocument__c from GNT__AttachmentExtension__c where GNT__ParentId__c in :ProgramAttachmentIDs])
        {
            System.debug('updateAttachments2');
            List<GNT__AttachmentExtension__c> list2=new List<GNT__AttachmentExtension__c>();
            if (!ProgAttachmentExtensions.containsKey(attch.GNT__ParentId__c))
            {
                list2.add(attch);
                ProgAttachmentExtensions.put(attch.GNT__ParentId__c,list2);
            }
            else{
                list2=ProgAttachmentExtensions.get(attch.GNT__ParentId__c);
                list2.add(attch);
                ProgAttachmentExtensions.put(attch.GNT__ParentId__c,list2);
            }
        }

        List<GNT__AttachmentExtension__c> ListAnnAttch1 = new List<GNT__AttachmentExtension__c>(); 
        for (Integer i=0;i<ProgramAttachmentIDs.size();i++)
        {
            Id programId=ProgramAttachmentIDs.get(i);
            Id AnnId=Announcements.get(i);
            if (ProgAttachmentExtensions.containsKey(programId))
            {
                List<GNT__AttachmentExtension__c> AttachmentExtensionList=ProgAttachmentExtensions.get(ProgramAttachmentIDs.get(i));
                for (GNT__AttachmentExtension__c attachmnt:AttachmentExtensionList) {
                    GNT__AttachmentExtension__c AnnAttch=new GNT__AttachmentExtension__c();
                    AnnAttch.GNT__Attachment__c=mapAttachments.get(attachmnt.GNT__Attachment__c);
                    AnnAttch.GNT__ParentId__c=AnnId;
                    AnnAttch.GNT__AttachmentName__c=attachmnt.GNT__AttachmentName__c;
                    AnnAttch.GNT__Classification__c=attachmnt.GNT__Classification__c;
                    AnnAttch.GNT__HistoryReason__c=attachmnt.GNT__HistoryReason__c;
                    AnnAttch.GNT__DigitalSignature__c=attachmnt.GNT__DigitalSignature__c;
                    AnnAttch.GNT__signedDocument__c=attachmnt.GNT__signedDocument__c;
                    ListAnnAttch1.add(AnnAttch);
                }
            }
        }
        insert ListAnnAttch1;


    }

    /*Delete previous share records if Program is changed*/

    private void deleteShareIfProgramChanged() {
        Map<Id, Announcement__c> oldAnnouncements = (Map<Id, Announcement__c>)trigger.oldMap;
        List<Announcement__c> newAnnouncements = trigger.new;
        Set<Id> accountIds = new Set<Id>();
        Set<Id> announcementIds = new Set<Id>();
        for (Announcement__c announcement : newAnnouncements) {
            if (announcement.program__c != oldAnnouncements.get(announcement.id).program__c) {
                accountIds.add(oldAnnouncements.get(announcement.id).AccountId__c);
                announcementIds.add(announcement.Id);
            }
        }
        if (announcementIds != null && announcementIds.size() > 0) {
            List<Account> accounts = [select name from Account where id in :accountIds];
            Set<String> acctNames = new Set<String>();
            for (Account account : accounts) {
                acctNames.add(account.Name);
            }
            Map<Id, UserRole> roleMap = new Map<Id, UserRole>([Select Id, Name from UserRole where Name in :acctNames]);
            Map<String, UserRole> acctRoleMap = new Map<String, UserRole>();
            List<Group> groups = [select id, Name, RelatedId from Group where type = 'Role' and RelatedId in :roleMap.keySet()];
            Set<Id> grpId = new Set<Id>();
            for (Group gp : groups) {
                grpId.add(gp.id);
            }


            /* Delete Old Announcement Share */
            List<Announcement__Share> oldAnnouncementShare = [select id from Announcement__Share where UserOrGroupId in :grpId and parentId in :announcementIds AND RowCause IN ('SharetoExternalUsers__c', 'SharetoInternalUsers__c', 'SharingforReviewandApproval__c')];
            if (!oldAnnouncementShare.isEmpty()) {
                Database.Delete(oldAnnouncementShare, false);
            }
            /*End*/
        }
    }

    /* Method to fetch only alphanumeric content */
    // private static string getName(String roleName){
    /*Pattern isAlphaNumericPattern = Pattern.compile('[a-zA-Z0-9]+');
    Matcher isAlphaNumericMatcher = isAlphaNumericPattern.matcher(roleName);
    String newRoleName;
    while (isAlphaNumericMatcher.find()){
         if(String.isEmpty(newRoleName)) {
          newRoleName =  isAlphaNumericMatcher.group();
         }else{
          newRoleName+= isAlphaNumericMatcher.group();
         }
    }
    if(String.isEmpty(newRoleName))
    return roleName;
    return newRoleName;*/
    //return null;
    //}

    public void shareToInternalUsers(List<Announcement__c> announcements) {
        Set<Id> ownerIds = new Set<Id>();
        for (Announcement__c ann : announcements) {
            ownerIds.add(ann.OwnerId);
        }

        Map<Id, Id> userRoleMap = new Map<Id, Id>();  //key->user id, value->role id
        for (User u : [Select Id, UserRoleId from User where Id in :ownerIds and UserRoleId != null]) {
            userRoleMap.put(u.Id, u.UserRoleId);
        }

        Map<Id, Group> roleGroupMap = new Map<Id, Group>(); //key->role id, value->group
        for (Group gp : [Select Id, RelatedId from Group where RelatedId in :userRoleMap.values() and Type = 'RoleAndSubordinatesInternal']) {
            roleGroupMap.put(gp.RelatedId, gp);
        }

        List<Announcement__Share> announcementShares = new List<Announcement__Share>();
        for (Announcement__c ann : announcements) {
            Id roleId = userRoleMap.get(ann.OwnerId);
            if (roleId != null) {
                Group gp = roleGroupMap.get(roleId);
                Announcement__Share share = new Announcement__Share();
                share.ParentId = ann.Id;
                share.UserOrGroupId = gp.Id;
                share.AccessLevel = 'edit';
                share.RowCause = Schema.Announcement__Share.rowCause.SharetoInternalUsers__c;
                announcementShares.add(share);
            }
        }
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.upsertAnnouncementShare(announcementShares);


        /*
        List<Id> announcementIds = new List<Id>();
        List<Id> programIds = new List<Id>();
        Set<String> acctNames = new Set<String>();

        for(Announcement__c announcement : announcements){
          announcementIds.add(announcement.id);
          acctNames.add(announcement.AccountName__c);
        }


        Map<Id, UserRole> roleMap = new Map<Id, UserRole>([Select Id, Name from UserRole where Name in :acctNames]);
        Map<String, UserRole> acctRoleMap = new Map<String, UserRole>();
        for (UserRole role : roleMap.values()) {
        acctRoleMap.put(role.Name, role);
        }

        List<Group> groups= [select id,Name,RelatedId from Group where type='Role' and RelatedId in :roleMap.keySet()];
        Map<Id, Group> groupMap = new Map<Id, Group>(); //key->role id
        Set<Id> grpId = new Set<Id>();
        for (Group gp : groups) {
            groupMap.put(gp.RelatedId, gp);
            grpId.add(gp.id);
        }

        List<Announcement__Share> announcementShares = new List<Announcement__Share>();
        for (Announcement__c ann : announcements) {
            UserRole role = acctRoleMap.get(ann.AccountName__c);

            if(groupMap != null && role != null){
                Group gp = groupMap.get(role.Id);
                if(gp != null){
                    Announcement__Share share = new Announcement__Share();
                    share.ParentId = ann.Id;
                    share.UserOrGroupId = gp.Id;
                    share.AccessLevel = 'edit';
                    announcementShares.add(share);
                }
           }
        }
        insert announcementShares;
        */
    }
    /* Announcement are to be shared  based on Account Name for Internal users and to all
       External users
    */
    private void shareToExternalUsers() {
        List<Id> announcementIds = new List<Id>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            Announcement__c oldAnn = (Announcement__c) Trigger.OldMap.get(announcement.Id);
            if (announcement.status__c == 'Active' && oldAnn.status__c != 'Active') {
                announcementIds.add(announcement.id);
            }
        }

        if (announcementIds == null) return;

        Id extGroupId = getExternalCommunityGroupId();
        List<Announcement__Share> announcementShares = new List<Announcement__Share>();
        for (Id idVal : announcementIds) {
            Announcement__c announcement = (Announcement__c) Trigger.NewMap.get(idVal);
            Announcement__Share share = new Announcement__Share();
            share.ParentId = idVal;
            if (!String.isEmpty(announcement.Program__c)) {
                String acctId = announcement.AccountId__c;
                String accountName =  announcement.AccountName__c;
                System.debug('accountName: ' + accountName + ', acctId: ' + acctId);
                share.UserOrGroupId = extGroupId;
                share.AccessLevel = 'read';
                share.RowCause = Schema.Announcement__Share.rowCause.SharetoExternalUsers__c;
                announcementShares.add(share);
                system.debug('share--' + share);
            }

        }
        // Insert all of the newly created Share records and capture save result
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.upsertAnnouncementShare(announcementShares);
    }
    private Id getExternalCommunityGroupId() {
        String ExternalUserGroupName = GNT.KeyValueStoreHelper.getTextValue('ExternalUserPublicGroup', true);
        List<Group> groups = [select id, Name, type, developerName from Group where developerName = :ExternalUserGroupName ];
        if (groups.size() == 0) {
            throw new GNT.AppUtils.ValidationException('Public group by name ' + ExternalUserGroupName + ' is not defined');
        }
        Id extGroupId = groups.get(0).Id;
        System.debug('group id: ' + extGroupId);
        return extGroupId;
    }

    /*
    public List<Id> createApprovedAnnouncementList(List<Id> announcementIds){

        List<ProcessInstance> announcemetApprovedList = [Select Id,TargetObjectId  From ProcessInstance WHERE TargetObjectId in :announcementIds AND Status = 'Approved'];
        if(announcemetApprovedList != null && announcemetApprovedList.size() > 0){
            List<Id> approvedAnnouncementIds = new List<Id>();
            for(ProcessInstance psInstacne : announcemetApprovedList){
                    approvedAnnouncementIds.add(psInstacne.TargetObjectId);
            }
            if(approvedAnnouncementIds != null && approvedAnnouncementIds.size() > 0)
            return approvedAnnouncementIds ;
        }
        return null;
    }*/

    /* METHOD TO UPDATE THE STATUS OF THE ANNOUNCEMENT IF AN ACTIVE ANNOUNCEMENT IS UPDATED*/
    private static void updateStatus() {
        for (Integer i = 0; i < Trigger.New.size(); i++) {
            Announcement__c oldAnnouncement = (Announcement__c) Trigger.Old[i];
            Announcement__c newAnnouncement = (Announcement__c) Trigger.New[i];

            if (oldAnnouncement.Status__c == 'Active' && newAnnouncement.Status__c != 'Active' && (newAnnouncement.Status__c != 'Expired' || newAnnouncement.Status__c != 'Closed'  )) {
                newAnnouncement.Status__c = 'In Progress';
            } else if (newAnnouncement.Status__c == 'Expired') {

            }
        }
    }

    // Update Program Approver in Announcement
    private static void updateApprover(List<Announcement__c> listAnnouncements) {
        RolesandResponsibilitiesTriggerHelper.skipTrigger = false;
        List<Id> lstID = new List<Id>();
        for (Announcement__c announcement : listAnnouncements) {
            lstId.add(announcement.Program__c);
        }

        // Fetch name of program approvers from R&R object
        List<RolesAndResponsibilities__c> lstPrograms = [Select Id, Name__c, Program__c, BusinessRole__c, Responsibility__c from RolesAndResponsibilities__c where Program__c IN: lstId and BusinessRole__c IN ('Fiscal Approver','Program Approver','Key POC','Executive Approver')] ;
        System.debug('--lstPrograms--' + lstPrograms);
        List<RolesAndResponsibilities__c> newlist = new List<RolesAndResponsibilities__c>();
        RolesAndResponsibilities__c obj1 ;
        for (Announcement__c announcement : listAnnouncements) {
            System.debug('--announcement--' + announcement);
            for (RolesAndResponsibilities__c obj : lstPrograms) {

                if (announcement.Program__c == obj.Program__c ) {
                    system.debug('--obj--' + obj);
                    obj1 = new RolesAndResponsibilities__c();
                    obj1.Announcement__c = announcement.Id;
                    obj1.Name__c = obj.Name__c;
                    //obj1.Role__c=obj.Role__c;
                    obj1.BusinessRole__c = obj.BusinessRole__c;
                    obj1.Responsibility__c = obj.Responsibility__c;
                    newlist.add(obj1);
                    system.debug('--obj1--' + obj1);
                }
            }
        }
        if (newlist.size() > 0) {
            system.debug('--newlist--' + newlist);
            try {
                insert newlist;

                system.debug('--newlist-111-' + newlist);

            } catch (Exception e) {
                system.debug('error---' + e);
            }

        }
    }


    //Weike 5/4/2017
    /*
    private void createAnnouncementGoalsAndObjectives(List<Announcement__c> anns) {

        List<Id> ProgramIds = new List<Id>();
        for (Announcement__c ann : anns) {
            ProgramIds.add(ann.Program__c);
        }

        List<GoalObjective__c> programParentGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Program__c, Award__c from GoalObjective__c where Program__c in :ProgramIds and IsParent__c = true];
        List<GoalObjective__c> programChildGoalList = [Select Type__c, IsParent__c, ParentGoal__c, Title__c, Description__c, Allocated__c, AllocatedAmount__c, ExpenditureAmount__c, Status__c, DueDate__c, Program__c, Award__c from GoalObjective__c where Program__c in :ProgramIds and IsParent__c = false];
        List<GoalObjective__c> annGoalParentList = new List<GoalObjective__c>();
        List<GoalObjective__c> annGaolChildList = new List<GoalObjective__c>();
        RecordType recordType = [select Id FROM RecordType where SobjectType = 'GoalObjective__c' and DeveloperName = 'Announcement'];

        for (Announcement__c ann : anns) {
            for (Integer i = 0; i < programParentGoalList.size(); i++) {
                GoalObjective__c goal = programParentGoalList.get(i);
                if (goal.Program__c == ann.Program__c) {
                    GoalObjective__c temp = new GoalObjective__c(
                        IsParent__c = goal.IsParent__c,
                        ParentGoal__c = goal.ParentGoal__c,
                        Title__c = goal.Title__c,
                        Description__c = goal.Description__c,
                        Allocated__c = goal.Allocated__c,
                        AllocatedAmount__c = goal.AllocatedAmount__c,
                        ExpenditureAmount__c = goal.ExpenditureAmount__c,
                        Status__c = goal.Status__c,
                        DueDate__c = goal.DueDate__c,
                        Announcement__c = ann.Id,
                        RecordTypeId = recordType.Id
                    );
                    annGoalParentList.add(temp);
                }
            }
        }
        insert annGoalParentList;

        Map<Id, Id> programAnnParent = new Map<id, Id>();
        for (Integer i = 0; i < annGoalParentList.size(); i++) {
            programAnnParent.put(programParentGoalList.get(i).Id, annGoalParentList.get(i).Id);
        }


        for (Announcement__c ann : anns) {
            for (Integer i = 0; i < programChildGoalList.size(); i++) {
                GoalObjective__c goal = programChildGoalList.get(i);
                if (goal.Program__c == ann.Program__c) {
                    GoalObjective__c temp = new GoalObjective__c(
                        IsParent__c = goal.IsParent__c,
                        ParentGoal__c = programAnnParent.get(goal.ParentGoal__c),
                        Title__c = goal.Title__c,
                        Description__c = goal.Description__c,
                        Allocated__c = goal.Allocated__c,
                        AllocatedAmount__c = goal.AllocatedAmount__c,
                        ExpenditureAmount__c = goal.ExpenditureAmount__c,
                        Status__c = goal.Status__c,
                        DueDate__c = goal.DueDate__c,
                        Announcement__c = ann.Id,
                        RecordTypeId = recordType.Id
                    );
                    annGaolChildList.add(temp);
                }
            }
        }
        insert annGaolChildList;
    }
    */


// Copy Budget Period in Announcement from Program
    private static void copyBudgetPeriods() {
        List<Id> prgLstID = new List<Id>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            prgLstID.add(announcement.Program__c);
        }

        List<BudgetPeriod__c> lstBudgetPeriods = [Select Id, Name, Status__c, BudgetStartDate__c, BudgetEndDate__c, SequenceNumber__c,
                              SupportYear__c, Notes__c, Program__c
                              from BudgetPeriod__c
                              where Program__c IN: prgLstID ] ;
        System.debug('lstBudgetPeriods 419---->' + lstBudgetPeriods);
        List<BudgetPeriod__c> annBudgetPeriodlist = new List<BudgetPeriod__c>();
        BudgetPeriod__c obj1 ;
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            for (BudgetPeriod__c obj : lstBudgetPeriods) {
                if (announcement.Program__c == obj.Program__c ) {

                    obj1 = new BudgetPeriod__c();
                    obj1.FundingOpportunity__c = announcement.Id;
                    obj1.Status__c = obj.Status__c;
                    obj1.BudgetStartDate__c = obj.BudgetStartDate__c;
                    obj1.BudgetEndDate__c = obj.BudgetEndDate__c;
                    obj1.SupportYear__c = obj.SupportYear__c;
                    obj1.Notes__c = obj.Notes__c;
                    // obj1.Name=obj.Name;
                    obj1.SequenceNumber__c = obj.SequenceNumber__c;
                    annBudgetPeriodlist.add(obj1);
                }
            }
        }
        if (annBudgetPeriodlist.size() > 0) {
            insert annBudgetPeriodlist;
        }

        //Create budget categories also

    }


    //  private static void copyGranteeBudgetCategories() {
    //      FundingOpportunityBudgetCategory__c obj1 ;
    //      List<Id> annID = new List<Id>();
    //      List<FundingOpportunityBudgetCategory__c> annBudgetCatlist = new List<FundingOpportunityBudgetCategory__c>();
    //      Map<Id,List<BudgetCategory__c>> budCategoriesMap = new Map<Id,List<BudgetCategory__c>>();


    //      for(Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
    //          annID.add(announcement.Id);
    //      }

    //      List<FundingOpportunityBudgetPeriod__c> lstAnnBudgetPeriods = [Select Id,Name, FundingOpportunity__c,BudgetPeriod__c,FundingOpportunityProjectArea__c from FundingOpportunityBudgetPeriod__c where FundingOpportunity__c IN: annID ];
    //      List<RecordType> recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType=:AppUtils.getNamespacePrefix()+'BudgetCategory__c' and Name='External'];

    //      for(Announcement__c announcement : (List<Announcement__c>) Trigger.New){
    //          List<BudgetCategory__c> lstBudgetCat = [Select Id,Name from BudgetCategory__c where Status__c='Active' AND recordTypeId =:recordTypeList[0].Id AND Class__c =: announcement.ConstructionPackageValue__c];
    //          budCategoriesMap.put(announcement.Id,lstBudgetCat);
    //          System.debug('lstBudgetCat ---->'+lstBudgetCat);
    //      }


    //      for(Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
    //          List<BudgetCategory__c> budCats = budCategoriesMap.get(announcement.Id);
    //          for(BudgetCategory__c objBC : budCats) {
    //              obj1= new FundingOpportunityBudgetCategory__c();
    //              obj1.BudgetCategory__c=objBC.Id;
    //              obj1.FundingOpportunity__c=announcement.Id;
    //              annBudgetCatlist.add(obj1);
    //          }
    //      }

    //      if(annBudgetCatlist.size()>0) {
    //          insert annBudgetCatlist;
    //          System.debug('annBudgetCatlist 123---->'+annBudgetCatlist);
    //        }
    //}



// Copy Service Area in Announcement from Program
    private static void copyProjectAreas() {
        List<Id> prgLstID = new List<Id>();
        AnnouncementServiceArea__c defaultservicearea;
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            prgLstID.add(announcement.Program__c);
        }

        List<Program__c> lstPrograms = [Select Id, Name,   IsProjectServiceAreaneeded__c from Program__c where Id IN:prgLstID];
        String multipleServiceArea = lstPrograms.size() > 0 ? lstPrograms[0].IsProjectServiceAreaneeded__c : 'No';

        List<ProgramServiceArea__c> lstpgmServiceAreas = [Select Id, Name, ServiceArea__c, Program__c from ProgramServiceArea__c where Program__c IN: prgLstID ];
        System.debug('lstpgmServiceAreas ---->' + lstpgmServiceAreas);
        List<ServiceArea__c> lstservicearea = [Select id, name, Title__c from ServiceArea__c where Default__c = true];

        List<AnnouncementServiceArea__c> annServiceArealist = new List<AnnouncementServiceArea__c>();
        AnnouncementServiceArea__c obj1 ;

        // If Multiple Service Areas are required by the Program/Announcement
        if (multipleServiceArea == 'Yes') {
            for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
                for (ProgramServiceArea__c obj : lstpgmServiceAreas) {
                    if (announcement.Program__c == obj.Program__c ) {
                        obj1 = new AnnouncementServiceArea__c();
                        obj1.Announcement__c = announcement.Id;
                        obj1.ProgramServiceArea__c = obj.Id;
                        obj1.ServiceArea__c = obj.ServiceArea__c;
                        annServiceArealist.add(obj1);
                    }
                }
            }
        } else {
            for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
                if (lstservicearea != null && lstservicearea.size() > 0) {
                    defaultservicearea = new AnnouncementServiceArea__c();
                    defaultservicearea.ServiceArea__c = lstservicearea[0].id;
                    defaultservicearea.Announcement__c = announcement.Id;
                    annServiceArealist.add(defaultservicearea);
                }
            }
        }
        if (annServiceArealist.size() > 0) {
            insert annServiceArealist;
        }
    }

    // Copy Funding Accounts in Announcement from Program
    private static void copyFundingAccounts() {
        List<Id> prgLstID = new List<Id>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            prgLstID.add(announcement.Program__c);
        }

        List<ProgramFundingAccount__c> lstpgmFA = [Select Id, Name, Program__c, FundingAccount__c from ProgramFundingAccount__c where Program__c IN: prgLstID ];
        List<AnnouncementFundingAccount__c> annFAlist = new List<AnnouncementFundingAccount__c>();
        AnnouncementFundingAccount__c obj1 ;
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            for (ProgramFundingAccount__c obj : lstpgmFA) {
                if (announcement.Program__c == obj.Program__c ) {
                    obj1 = new AnnouncementFundingAccount__c();
                    obj1.Announcement__c = announcement.Id;
                    obj1.FundingAccount__c = obj.FundingAccount__c;
                    annFAlist.add(obj1);
                    system.debug('--obj1--' + obj1);
                }
            }
        }
        if (annFAlist.size() > 0) {
            insert annFAlist;
        }
    }

// Copy Budget Periods in Announcement from Program
    private static void copyAnnouncementBudgetPeriods() {
        List<Id> annID = new List<Id>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            annID.add(announcement.Id);
        }

        List<BudgetPeriod__c> lstBudgetPeriods = [Select Id, Name, FundingOpportunity__c from BudgetPeriod__c where FundingOpportunity__c IN: annID ];
        System.debug('lstBudgetPeriods ---->' + lstBudgetPeriods);

        List<AnnouncementServiceArea__c> lstannServiceAreas = [Select Id, Name, Announcement__c from AnnouncementServiceArea__c where Announcement__c IN: annID ];
        System.debug('lstannServiceAreas ---->' + lstannServiceAreas);


        List<FundingOpportunityBudgetPeriod__c> annBudgetPeriodlist = new List<FundingOpportunityBudgetPeriod__c>();
        FundingOpportunityBudgetPeriod__c obj1 ;
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            for (AnnouncementServiceArea__c objSA : lstannServiceAreas) {
                for (BudgetPeriod__c objBP : lstBudgetPeriods) {
                    if (announcement.Id == objSA.Announcement__c && announcement.Id == objBP.FundingOpportunity__c) {
                        obj1 = new FundingOpportunityBudgetPeriod__c();
                        obj1.BudgetPeriod__c = objBP.Id;
                        obj1.FundingOpportunity__c = announcement.Id;
                        obj1.FundingOpportunityProjectArea__c = objSA.Id;
                        annBudgetPeriodlist.add(obj1);
                    }
                }
            }
        }
        if (annBudgetPeriodlist.size() > 0) {
            insert annBudgetPeriodlist;
            System.debug('annBudgetPeriodlist -0123--->' + annBudgetPeriodlist);
        }
    }



// Copy Budget Category in Announcement from master list
    private static void copyBudgetCategories() {
        List<Id> prgLstID = new List<Id>();
        List<Id> annID = new List<Id>();
        List<RecordType> recordTypeList  = new  List<RecordType>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            prgLstID.add(announcement.Program__c);
            annID.add(announcement.Id);
        }

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        System.debug('appName ---->' + appName);

        List<FundingOpportunityBudgetPeriod__c> lstAnnBudgetPeriods = [Select Id, Name, FundingOpportunity__c, BudgetPeriod__c, FundingOpportunityProjectArea__c from FundingOpportunityBudgetPeriod__c where FundingOpportunity__c IN: annID ];
        System.debug('lstAnnBudgetPeriods ---->' + lstAnnBudgetPeriods);

        if (appName == 'StateasGrantor') {
            recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'BudgetCategory__c' and Name = 'Internal'];
        }
        if (appName == 'StateasGrantee') {
            recordTypeList = [select Id, Name, SobjectType FROM RecordType where SobjectType = :AppUtils.getNamespacePrefix() + 'BudgetCategory__c' and Name = 'External'];
        }
        List<ProgramBudgetCategory__c> lstBudgetCat = [Select Id, Name, BudgetCategory__c, Program__c from ProgramBudgetCategory__c where Program__c IN :prgLstID];
        System.debug('lstBudgetCat ---->' + lstBudgetCat);

        List<FundingOpportunityBudgetCategory__c> annBudgetCatlist = new List<FundingOpportunityBudgetCategory__c>();
        FundingOpportunityBudgetCategory__c obj1 ;
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {

            for (FundingOpportunityBudgetPeriod__c objBP : lstAnnBudgetPeriods) {
                for (ProgramBudgetCategory__c objBC : lstBudgetCat) {
                    if (announcement.Id == objBP.FundingOpportunity__c  && announcement.Program__c == objBC.Program__c) {
                        obj1 = new FundingOpportunityBudgetCategory__c();
                        obj1.BudgetCategory__c = objBC.BudgetCategory__c;
                        obj1.BudgetPeriod__c = objBP.BudgetPeriod__c;
                        obj1.FundingOpportunity__c = announcement.Id;
                        obj1.FundingOpportunityProjectArea__c  = objBP.FundingOpportunityProjectArea__c;
                        obj1.FundingOpportunityBudgetPeriod__c = objBP.Id;
                        annBudgetCatlist.add(obj1);
                    }
                }
            }
        }
        if (annBudgetCatlist.size() > 0) {
            insert annBudgetCatlist;
            System.debug('annBudgetCatlist 123---->' + annBudgetCatlist);
        }
    }


    /*Insert BudgetPayment Records Based on Project Period Start Date and Project period End date*/
    private void InsertBudgetPerioddates() {

        List<BudgetPeriod__c> existingBPlist = [Select Id from BudgetPeriod__c where FundingOpportunity__c IN:Trigger.New ];
        List<BudgetPeriod__c> lstbp  = new List<BudgetPeriod__c>();
        Date dtEnd = null;
        if (existingBPlist.isEmpty()) {
            for (Announcement__c ann : (List<Announcement__c>) Trigger.New) {
                Date a = ann.EstimatedProjectPeriodStartDate__c;
                Date b = ann.EstimatedProjectPeriodEndDate__c;
                Date dtStart = a;
                if (dtStart != null) {
                    dtEnd = dtStart.adddays(365);
                }
                Integer i = 0;

                if (b != null) {
                    while (dtEnd < = b) {
                        BudgetPeriod__c bperiod = new  BudgetPeriod__c();
                        i = i + 1;
                        if (i <= 9) {
                            bperiod.SupportYear__c = 'BP0' + i;
                        } else {
                            bperiod.SupportYear__c = 'BP' + i;
                        }
                        bperiod.FundingOpportunity__c = ann.id;
                        // bperiod.Name = 'BP-'+ dtEnd.Year();
                        bperiod.BudgetStartDate__c = dtStart;
                        bperiod.BudgetEndDate__c = dtEnd;
                        bperiod.SequenceNumber__c = i;
                        lstbp.add(bperiod);
                        dtStart = dtEnd.addDays(1);
                        dtEnd = dtStart.adddays(365);
                    }
                }

                if (dtStart != null) {
                    if (dtStart <= b) {
                        i = i + 1;
                        BudgetPeriod__c bperiod = new BudgetPeriod__c();
                        if (i <= 9) {
                            bperiod.SupportYear__c = 'BP0' + i;
                        } else {
                            bperiod.SupportYear__c = 'BP' + i;
                        }
                        bperiod.FundingOpportunity__c = ann.id;
                        // bperiod.Name = 'BP-'+ dtEnd.Year();
                        bperiod.BudgetStartDate__c = dtStart;
                        bperiod.BudgetEndDate__c = b;
                        bperiod.SequenceNumber__c = i;
                        lstbp.add(bperiod);
                    }
                }
            }
        }
        if (!lstbp.isempty()) {
            insert lstbp;
        }
    }

    /* Insert the Business package entry in the the package related list when the Application is created outside
     *  of the System Requirement from Shiva on 03/08/2016
     */

    private static void insertDummyPackage(List<Announcement__c> oppList) {
        List<Id> lstId = new List<Id>();
        Map<Id, Id> oppPackId = new Map<Id, Id>();
        for (Announcement__c ann : oppList) {
            if (ann.ApplicationCreatedOutside__c == 'Yes') {
                lstId.add(ann.Id);
            }
        }

        if (!lstId.isEmpty()) {
            List<GNT__Package__c> lstPackages = [Select Id from GNT__Package__c where ApplicationOutsideSystem__c = true and GNT__CustomAppConfig__r.Name = :'StateasGrantee'];
            //    List<BusinessPackage__c> lstBusinessPacakges = [Select Id,FundingOpportunity__c from  BusinessPackage__c where FundingOpportunity__c in :GNT.AppUtils.soqlList(lstId)];
            String strQuery = 'Select Id,FundingOpportunity__c from  BusinessPackage__c where FundingOpportunity__c in ' + GNT.AppUtils.soqlList(lstId);
            List<BusinessPackage__c> lstBusinessPacakges  = Database.query(strQuery);

            for (BusinessPackage__c busPack : lstBusinessPacakges) {
                oppPackId.put(busPack.FundingOpportunity__c, busPack.Id);
            }

            List<BusinessPackage__c> lstBusinessPack = new List<BusinessPackage__c>();

            if (lstBusinessPack.size() == 0) {
                for (Announcement__c opp : oppList) {
                    Id packId = oppPackId.get(opp.Id);
                    if (packId == null) {
                        BusinessPackage__c pack = new BusinessPackage__c();
                        pack.FundingOpportunity__c = opp.Id;
                        pack.PackageType__c = 'Application';
                        pack.PackageConfig__c = lstPackages[0].Id;
                        lstBusinessPack.add(pack);
                    }
                }
                insert lstBusinessPack;
            }
        }
    }

    private void updateRFAReleaseDate() {
        List<Id> annID = new List<Id>();
        List<RecordType> recordTypeList  = new  List<RecordType>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            annID.add(announcement.Id);
        }

        List<Announcement__c> annList = [Select Id, Name, RFAReleaseDate__c, RFARequired__c from Announcement__c where id IN :annID];

        for (Announcement__c ann : annList) {
            if (ann.RFARequired__c != null && !ann.RFARequired__c) {
                ann.RFAReleaseDate__c = null;
            }
        }
        update annList;
    }
    
    public void copyReportingRequirements(List<Announcement__c> announcements){
        Set<Id> programids = new Set<Id>();
        
        for (Announcement__c announcement : announcements){
            programids.add(announcement.Program__c);
        }
        
        String uniqueIdAPIName = 'InternalUniqueID__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String SobjectApiName = 'TermCondition__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(!fieldName.equalsIgnorecase(uniqueIdAPIName)){
                if(commaSeparatedFields == null || commaSeparatedFields == ''){
                    commaSeparatedFields = fieldName;
                }else{
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        String idstring = '';
        for(Id recordId : programids){
            if (idstring == ''){
                idstring = 'Program__c = \'' + recordId + '\'';
            }else{
                idstring = idstring + ' OR Program__c = \'' + recordId + '\'';
            }
        }
        String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where ' + idstring;
        List<TermCondition__c> reqlist = Database.query(query);
        
        Map<Id,List<TermCondition__c>> reqmap = new Map<Id,List<TermCondition__c>>();
        for (TermCondition__c req : reqlist){
            List<TermCondition__c> tmp = reqmap.get(req.Program__c);
            if (tmp == null){
                tmp = new List<TermCondition__c>();
            }
            tmp.add(req);
            reqmap.put(req.Program__c,tmp);
        }
        
        List<TermCondition__c> newreqlist = new List<TermCondition__c>();
        for (Announcement__c announcement : announcements){
            List<TermCondition__c> reqs = reqmap.get(announcement.Program__c);
            if (reqs != null){
                for (TermCondition__c req : reqs){
                    TermCondition__c newreq = req.clone(false);
                    newreq.Announcement__c = announcement.Id;
                    newreq.Program__c = null;
                    newreqlist.add(newreq);
                }
            }
        }
        insert newreqlist;
    }
    
    private void copyReviewers(List<Announcement__c> announcements){
        Set<Id> announcementIds = new Set<Id>();
        Set<Id> programIds = new Set<Id>();
        for (Announcement__c announcement : announcements){
            announcementIds.add(announcement.Id);
            programIds.add(announcement.Program__c);
        }
        
        List<PanelUserTemplate__c> reviewerList = [SELECT Id,Reviewer__c,ReviewPanelTemplate__r.ReviewStepTemplate__r.Name,ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c FROM PanelUserTemplate__c WHERE ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c IN: programIds];
        if (reviewerList.size() > 0){
            List<ReviewPanelTemplate__c> panelList = [SELECT Id,ReviewStepTemplate__r.Announcement__c,ReviewStepTemplate__r.Announcement__r.Program__c,ReviewStepTemplate__r.Name FROM ReviewPanelTemplate__c WHERE ReviewStepTemplate__r.Announcement__c IN: announcementIds];
            
            Map<Id,List<PanelUserTemplate__c>> reviewerMap = new Map<Id,List<PanelUserTemplate__c>>();
            Map<Id,Id> panelMap = new Map<Id,Id>();
            for (PanelUserTemplate__c reviewer : reviewerList){
                List<PanelUserTemplate__c> tmp = reviewerMap.get(reviewer.ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c);
                if (tmp == null){
                    tmp = new List<PanelUserTemplate__c>();
                    reviewerMap.put(reviewer.ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c, tmp);
                }
                tmp.add(reviewer);
                
                for (ReviewPanelTemplate__c panel : panelList){
                    if (reviewer.ReviewPanelTemplate__r.ReviewStepTemplate__r.Program__c == panel.ReviewStepTemplate__r.Announcement__r.Program__c && reviewer.ReviewPanelTemplate__r.ReviewStepTemplate__r.Name == panel.ReviewStepTemplate__r.Name){
                        panelMap.put(reviewer.Id,panel.Id);
                    }
                }
            }
            
            List<PanelUserTemplate__c> newReviewers = new List<PanelUserTemplate__c>();
            for (Announcement__c announcement : announcements){
                List<PanelUserTemplate__c> reviewers = reviewerMap.get(announcement.Program__c);
                
                if (reviewers != null){
                    for (PanelUserTemplate__c reviewer : reviewers){
                        Id panelId = panelMap.get(reviewer.Id);
                        PanelUserTemplate__c newReviewer = new PanelUserTemplate__c();
                        newReviewer.Reviewer__c = reviewer.Reviewer__c;
                        newReviewer.ReviewPanelTemplate__c = panelId;
                        newReviewers.add(newReviewer);
                    }
                }
            }
            insert newReviewers;
        }
    }

    private void shareWithInternalUsers(List<Announcement__c> lstAnnouncements) {
        for (Announcement__c ann : lstAnnouncements) {
            ann.AnnGroupCode__c = ann.AnnoucementGroupCodeFormula__c;
        }
    }

    private void updateShareWithInternalUsers() {
        for (Announcement__c ann : (List<Announcement__c>) Trigger.new) {
            Announcement__c oldAnn = (Announcement__c) Trigger.oldMap.get(ann.Id);
            if (ann.AnnoucementGroupCodeFormula__c != oldAnn.AnnoucementGroupCodeFormula__c) {
                ann.AnnGroupCode__c = ann.AnnoucementGroupCodeFormula__c;
            }
        }
    }

    /*update  No of Announcements on Organization*/
    private void UpdateOrgNoofAnnouncements(List<Announcement__c> lstann) {
        Set<Id> orgIds = new Set<Id>();
        for (Announcement__c ann : lstann) {
            if (ann.Organization__c != null) {
                orgIds.add(ann.Organization__c);
            }
        }
        List<Account> acctsToRollup = new List<Account>();
        for (AggregateResult ar : [SELECT Organization__c orgId, Count(id) annCount
                                   FROM Announcement__c
                                   WHERE Organization__c in: orgIds
                                   GROUP BY Organization__c]) {
            Account a = new Account();
            a.Id = (Id) ar.get('orgId');
            a.NumberofAnnouncements__c = (Integer) ar.get('annCount');
            if (Trigger.isbefore && Trigger.isdelete && (ar.get('annCount') == 1)) {
                a.NumberofAnnouncements__c = 0;
            }
            acctsToRollup.add(a);
        }
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getLimitQueries());
        SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        SystemContextMethodsHelper.updateAccounts(acctsToRollup);
    }

    // Method causing SOQL 101 Error - Charan
    // Will be updating when changes are made

    // Pranjali - This method is used to delete all Reviewers task when the Status of Announcement is changed to Reviewed
    private void deleteTasksForReviewers(List<Announcement__c> anns) {
        List<String> annsName = new List<String>();
        for (Announcement__c ann : anns) {
            if (ann.Status__c == 'Reviewed') {
                annsName.add(ann.Name);
            }
        }

        //List<Announcement__c> listOfAnnouncements = [SELECT Id,Status__c FROM Announcement__c WHERE ID in :Trigger.New];
        List<Task> tsk = new List<Task>();
        tsk = [SELECT Id FROM Task WHERE TrackingNumberLink1__c in:annsName and GNT__TaskAction__c in ('Review the opportunity', 'Review Grantor Announcement') AND Status in ( 'Not Started', 'In Progress')];
        delete tsk;
    }
    // This method deletes the qualified announcement in portal site and announcemnet in grantor side - Charan
    private void deleteQualifiedAnnouncement() {
        List<OpportunityQualification__c> annList = [Select id from OpportunityQualification__c where FundingOpportunity__c IN :Trigger.oldMap.keySet()];
        delete annList;
    }

    //Change lead status to Qualified Lead -- Weike
    private void changeLeadStatus(List<Announcement__c> anns) {
        Map<Id, Announcement__c> annOrg = new Map<Id, Announcement__c>([Select CreatedBy.AccountNameFormulaField__c from Announcement__c where Id IN :anns]);
        System.debug('*************' + annOrg);
        Set<Id> leadId = new Set<Id>();
        Map<Id, String> annLead = new Map<Id, String>();
        for (Announcement__c ann : anns) {
            if (ann.FOALead__c != null) {
                leadId.add(ann.FOALead__c);
                annLead.put(ann.FOALead__c, annOrg.get(ann.Id).CreatedBy.AccountNameFormulaField__c);
            }
        }
        System.debug('*************' + annLead);
        List<FOALead__c> leads = [Select Status__c, (Select Id, Agency__c, EvaluationStatus__c from Reviews__r) from FOALead__c where Id in :leadId];
        List<ApplicationReview__c> ars = new List<ApplicationReview__c>();
        for (FOALead__c lead : leads) {
            Boolean flag = true;
            System.debug('*************' + lead.Reviews__r);
            for (ApplicationReview__c ar : lead.Reviews__r) {
                if (ar.Agency__c == annLead.get(lead.Id)) {
                    System.debug('****************exe');
                    ar.EvaluationStatus__c = 'Evaluated';
                    ars.add(ar);
                }
                if (ar.EvaluationStatus__c == 'Converted to Opportunity') {
                    flag = false;
                }
            }
            if (flag) {
                lead.Status__c = 'Qualified Lead';
            }
        }
        update leads;
        update ars;
    }

    private void copyProgramFields() {
        List<Id> prgLstID = new List<Id>();
        List<Id> annLstId = new List<Id>();
        for (Announcement__c announcement : (List<Announcement__c>) Trigger.New) {
            prgLstID.add(announcement.Program__c);
            annLstId.add(announcement.Id);
        }

        List<Program__c> programList = [SELECT ApplicationDeadline__c,EndDate__c,StartDate__c, OrganizationName__c,AttachmentsRequired__c,
            AdditionalInformation__c, EligibleApplicantTypes__c, OtherEligibleApplicantTypes__c,Objectives__c,ProgramName__c,Account__r.Id,FiscalYear__c FROM Program__c
            WHERE Id IN :prgLstID];
        List<Announcement__c> annList = [SELECT Program__c,AttachmentsRequired__c,EstimatedProjectPeriodStartDate__c,EstimatedProjectPeriodEndDate__c, ApplicationDeadlineWithDateTime__c, AdditionalInformation__c,
            EligibleApplicantTypes__c, OtherEligibleApplicantTypes__c, FiscalYearLookup__c FROM Announcement__c
            WHERE Id IN :annLstId];
        for (Announcement__c announcement : annList) {
            for (Program__c program : programList) {
                if (program.Id == announcement.Program__c){
                    announcement.AdditionalInformation__c = program.AdditionalInformation__c;
                    announcement.ApplicationDeadlineWithDateTime__c = program.ApplicationDeadline__c;
                    announcement.EligibleApplicantTypes__c = program.EligibleApplicantTypes__c;
                    announcement.AttachmentsRequired__c = program.AttachmentsRequired__c;
                    announcement.OtherEligibleApplicantTypes__c = program.OtherEligibleApplicantTypes__c;
                    //announcement.Organization__c=program.Account__r.Id;
                    announcement.FiscalYearLookup__c = program.FiscalYear__c;
                    announcement.EstimatedProjectPeriodStartDate__c = program.StartDate__c;
                    announcement.EstimatedProjectPeriodEndDate__c = program.EndDate__c;
                }
            }
        }

        update annList;
    }

    private void validateFiscalYearObjects(List<Announcement__c> annList) {
        try {
        List<Announcement__c> announcements = new List<Announcement__c>();
        Map<ID, List<USBELEACostRate__c>> costrateMap = new Map<ID, List<USBELEACostRate__c>>();
        for (Announcement__c announcement : annList) {
            if (announcement.Program__r.ProgramPathway__c != 'State-Competitive' || announcement.Program__r.ProgramPathway__c != 'Fed-Competitive' 
                || announcement.OrganizationName__c != 'USBE') {
                    continue;
            }
            announcements.add(announcement);
            costrateMap.put(announcement.Organization__r.Id, new List<USBELEACostRate__c>());
        }
        if (announcements.size() == 0) return;
        
        
        List<USBELEACostRate__c> costList = [SELECT Year__c, Account__c from USBELEACostRate__c where Account__r.Id IN :costrateMap.keySet()];
        for (USBELEACostRate__c cost : costList) {
            List<USBELEACostRate__c> tempList = costrateMap.get(cost.Account__r.Id);
            tempList.add(cost);
            costrateMap.put(cost.Account__r.Id, tempList);
        }

        for (Announcement__c announcement : annList) {
            List<USBELEACostRate__c> tempList = costrateMap.get(announcement.Organization__r.Id);
            boolean objExists = false;
            for (USBELEACostRate__c cost : tempList) {
                if (cost.Year__c == announcement.Program__r.FiscalYear__c) {
                    objExists = true;
                }
            }
            if (!objExists) {
                announcement.addError('Please add indirect costs for fiscal year ' + announcement.Program__r.FiscalYear__c);
            }
        }
        } catch (Exception e) {
            System.debug('ValidationException: ' +e);
        }
    }

    private void createTaskOnSendBack(List<Announcement__c> announcementList){
        for(Announcement__c announcement : announcementList){
            if(announcement.Status__c == 'Change Requested'){
                GNT.TaskCreationHandler.createTasks(announcement.OwnerId, announcement.Id, 'ChangeRequested Announcement', announcement.Name, null, false, System.TODAY() + 7, 'ChangeRequested Announcement', true);
            }
        }
    }
    
}