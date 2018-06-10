/*
    All trigger logic on Grant Object
    **********************************************************
    Audit History

    **********************************************************
    06/27/2014         Vinayak Sharma            Created
    08/08/2014          Nakul Kadam         Added shareGrantToRelatedExternalUsers method
    **********************************************************
*/

global with sharing class GrantTriggerHelper extends GNT.TriggerHelper {
    global static boolean skipTrigger = false;
    public override void processBeforeInsert() {
    
        PopulateGranteePOC();
        SetGrantDetails();
        GNT.NameTemplateTriggerHelper.beforeInsert();
    }
    public override void processBeforeUpdate() {
    }

    public override void processAfterInsert() {
        system.debug('SkipTrigger Value is:' + skipTrigger);
        if (skipTrigger == false) {
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            if (appName == null || appName == 'StateasGrantee') {
                updateApplication(Trigger.new);
            }
            //PopulatePackages(Trigger.new);
            //Award Enhancement
            copyPackagesfromAnn(Trigger.new);
            //BOD
            //createProjectInformation((List<Grant__c>)Trigger.New);
            InsertBudgetPerioddates();
            if (appName == null || appName == 'StateasGrantor') {
                //shareGrantToGranteePOC(trigger.new);
                shareGrantToAllUsersInOrg(Trigger.new);
                createAward(trigger.new);
            }
            //copyTnCFromProgramToGrant();
            //addRoles((List<Grant__c>) Trigger.New);
            //syncRolesAndRespWithProgram((List<Grant__c>) Trigger.New);
            shareToRolesAndUSBE((List<Grant__c>) Trigger.New);
        }
    }
    public override void processAfterUpdate() {
        //shareGrantToGranteePOC(trigger.new);
        shareGrantToAllUsersInOrg(Trigger.new);
    }

    public override void processBeforeDelete() {
        if (skipTrigger == false) {

        }
    }

    /*
       This methods will create an award for the grant from New button
    */
    private void createAward(List<Grant__c> grantList) {
        Set<string> setZip = new Set<string>();
        for (Grant__c grant : grantList) {
            if (grant.application__c == null) {
                if (grant.zipcode__c != null) {
                    setZip.add(grant.zipcode__c);
                }
                system.debug('>>>>>setZip' + setZip);
            }
        }

        /*
        List<USDemographicInfo__c> ListUSDemographicInfo = [select id, name, StateName__c, PrimaryCity__c, County__c, CongressionalDistrict__c
                from USDemographicInfo__c where Id in:setZip
                                                           ];
        */
        List<Grant__c> updateGrant = [select id , name , zipcode__c, zipcode__r.name, zipcode__r.StateCode__c, zipcode__r.PrimaryCity__c, zipcode__r.County__c, zipcode__r.CongressionalDistrict__c,
                                      zipcode__r.Location__Latitude__s , zipcode__r.Location__Longitude__s, ProjectPeriodStartDate__c, ProjectPeriodEndDate__c, application__c  from Grant__c where Id IN :grantList];
        List<Award__c> awardList = new List<Award__c>();
        for (Grant__c grant : updateGrant) {
            if (grant.application__c == null) {
                //Copies fields from the announcement object to the new award

                Award__c award = new Award__c(
                    ProjectPeriodStartDate__c = grant.ProjectPeriodStartDate__c,
                    ProjectPeriodEndDate__c = grant.ProjectPeriodEndDate__c,
                    /* Application__c = grant.Application__c,
                     ProgramManager__c = grant.ProgramManager__c,
                     ProjectOfficer__c = grant.ProjectOfficer__c,
                     DataEvaluator__c = grant.DataEvaluator__c,
                     GrantMonitor__c = grant.GrantMonitor__c,
                     ProgramCode__c = grant.Program__c,
                     AwardedAmountthisAction__c=grant.Application__r.AmountThisAction__c,
                     GrantAwardName__c = grant.Application__r.Title__c,
                     TotalObligateAmount__c=grant.Application__r.ObligatedAmount__c,
                     IsStateMatchRequired__c=grant.Application__r.Announcement__r.MatchRequired__c,
                     ActiveBudgetYear__c = 1, */
                    Zip4__c = grant.zipcode__r.name,
                    county__c = grant.zipcode__r.County__c,
                    city__c = grant.zipcode__r.PrimaryCity__c,
                    state__c = grant.zipcode__r.StateCode__c,
                    CongressionalDistrictName__c = grant.zipcode__r.CongressionalDistrict__c,
                    Longitude__c = grant.zipcode__r.Location__Longitude__s,
                    Latitude__c =  grant.zipcode__r.Location__Latitude__s,
                    Grant__c = grant.Id

                );

                award.AwardType__c = 'New';

                // insert award;
                System.debug('--award--' + award);
                awardList.add(award);
            }
        }
        if (awardList.size() > 0) {
            insert awardList;
        }

    }


    /*
        This methods shares all the newly created Grants with
         the Grantee POC belong to External Orgazation.
    */
    private void shareGrantToGranteePOC(List<Grant__c> grantList) {
        
        List<Grant__Share> shareList = new List<Grant__Share>();
        for (Grant__c grant : grantList) {
            if (grant.GranteePOC__c  != null && grant.ExternalOrgName__c == 'UOVC') {
                Grant__Share share = new Grant__Share();
                share.UserOrGroupId = grant.GranteePOC__c;
                share.AccessLevel = 'Edit';
                share.ParentId = grant.Id;
                share.RowCause = Schema.Grant__Share.RowCause.SharetoExternalPOC__c;
                shareList.add(share);
            }

        }
        if (shareList.size() > 0) {
            if (Schema.sObjectType.Grant__Share.isCreateable()) {
                SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                SystemContextMethodsHelper.upsertGrantShare(shareList);
            }
        }
        
        //MSPGrantTriggerHelper helper = new MSPGrantTriggerHelper();
        //helper.shareToLea((List<Grant__c>)Trigger.new);
    }

    private void shareGrantToAllUsersInOrg(List<Grant__c> grantList) {
        if(!Test.isRunningTest()){
        
            List<Grant__Share> shareList = new List<Grant__Share>();
            Set<Id> accoundIds = new Set<Id>();
            for(Grant__c grant : grantList){
                accoundIds.add(grant.InternalOrganization__c);
            }
            List<User> usersList = [SELECT Id, AccountId FROM User WHERE AccountId IN :accoundIds AND IsActive = true];
            Map<String, List<User>> userMap = new Map<String, List<User>>();
            for(User userIterator : usersList){
                if(userMap.get(userIterator.AccountId) == null){
                    List<User> ul = new List<User>();
                    ul.add(userIterator);
                    userMap.put(userIterator.AccountId, ul);
                }
                else{
                    userMap.get(userIterator.AccountId).add(userIterator);
                }
            }
            for(Grant__c grant : grantList){
                for(User userIterator: userMap.get(grant.InternalOrganization__c)){
                    Grant__Share share = new Grant__Share();
                    share.UserOrGroupId = userIterator.Id;
                    //if (grant.ExternalOrgName__c == 'UOVC'){
                    share.AccessLevel = 'Edit';
                    //}  
                    //if (grant.ExternalOrgName__c == 'USBE'){
                    //share.AccessLevel = 'Edit';
                    //}  
                    share.ParentId = grant.Id;
                    share.RowCause = Schema.Grant__Share.RowCause.SharetoExternalPOC__c;
                    shareList.add(share);
                }
            }
            if (shareList.size() > 0 && Schema.sObjectType.Grant__Share.isCreateable()) {
                    SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                    SystemContextMethodsHelper.upsertGrantShare(shareList);
            }
        }
        //MSPGrantTriggerHelper helper = new MSPGrantTriggerHelper();
        //helper.shareToLea((List<Grant__c>)Trigger.new);
    }

    /*Insert BudgetPayment Records Based on Project Period Start Date and Project period End date*/
    private void InsertBudgetPerioddates() {
        List<BudgetPeriod__c> lstbp = new List<BudgetPeriod__c>();
        for (Grant__c grant : (List<Grant__c>) Trigger.New) {       
            if (grant.ExternalOrgName__c == 'USBE') {
                BudgetPeriod__c budgetPeriod = new BudgetPeriod__c();
                budgetPeriod.SupportYear__c = 'BP01';
                budgetPeriod.Grant__c = grant.id;
                budgetPeriod.SequenceNumber__c = 1;
                budgetPeriod.BudgetStartDate__c = grant.ProjectPeriodStartDate__c;
                budgetPeriod.BudgetEndDate__c = grant.ProjectPeriodEndDate__c;       
                budgetPeriod.Status__c='Active';    
                lstbp.add(budgetPeriod);
            }
            else {
                Date a = grant.ProjectPeriodStartDate__c;
                Date b = grant.ProjectPeriodEndDate__c;
                Date dtStart = a;
                Date dtEnd = dtStart.adddays(365);
                Integer i = 0;
                
                while (dtEnd < = b) {
                    BudgetPeriod__c bperiod = new  BudgetPeriod__c();
                    i = i + 1;
                    if (i <= 9) {
                        bperiod.SupportYear__c = 'BP0' + i;
                    } else {
                        bperiod.SupportYear__c = 'BP' + i;
                    }
                    bperiod.Grant__c = grant.id;
                    //bperiod.Name = 'BP-' + dtEnd.Year();
                    bperiod.SequenceNumber__c = i;
                    if(i==1){
                        bperiod.Status__c='Active';
                    }
                    bperiod.BudgetStartDate__c = dtStart;
                    bperiod.BudgetEndDate__c = dtEnd;
                    lstbp.add(bperiod);
                    dtStart = dtEnd.addDays(1);
                    dtEnd = dtStart.adddays(365);
    
                }    
                if (dtStart <= b) {
                    i = i + 1;
                    BudgetPeriod__c bperiod = new BudgetPeriod__c();
                    if (i <= 9) {
                        bperiod.SupportYear__c = 'BP0' + i;
                    } else {
                        bperiod.SupportYear__c = 'BP' + i;
                    }
                    bperiod.Grant__c = grant.id;
                   // bperiod.Name = 'BP-' + dtEnd.Year();
                    bperiod.SequenceNumber__c = i;
                    if(i==1){
                        bperiod.Status__c='Active';
                    }
                    bperiod.BudgetStartDate__c = dtStart;
                    bperiod.BudgetEndDate__c = b;
                    lstbp.add(bperiod);
                }
            }           
        }

        if (!lstbp.isempty()) insert lstbp;
    }

    /* Creating Project Areas based on Service Areas in Program */
 /*   private void CreateProjectInformation(List<Grant__c> grants) {
        Set <Id> appIdSet = new Set < Id > ();
        Map<Id, Id> grantIdToAppIdMap = new Map<Id, Id>();
        Map<Id, Id> grantToProgramMap = new Map<Id, Id>();
        List <GrantServiceArea__c> grantSAList = new List < GrantServiceArea__c > ();
        for (Grant__c grant : grants) {
            appIdSet.add(grant.Application__c);
            grantIdToAppIdMap.put(grant.Id, grant.Application__c);
            if (grant.Application__c == null) {
                grantToProgramMap.put(grant.Id, grant.Program__c);
            }
        }

        if (grantToProgramMap.size() > 0) {
            List<ProgramServiceArea__c> programServiceAreasList = [select Id, Name, Program__c, ServiceArea__c
                    FROM ProgramServiceArea__c
                    where Program__c IN :grantToProgramMap.values()];

            Map<Id, List<ProgramServiceArea__c>> programToProgramServiceAreasMap = new Map<Id, List<ProgramServiceArea__c>>();

            for (ProgramServiceArea__c programServiceArea : programServiceAreasList) {
                if (!programToProgramServiceAreasMap.containsKey(programServiceArea.Program__c)) {
                    programToProgramServiceAreasMap.put(programServiceArea.Program__c, new List<ProgramServiceArea__c>());
                }
                programToProgramServiceAreasMap.get(programServiceArea.Program__c).add(programServiceArea);
            }

            List<GrantServiceArea__c> grantServiceAreas = new List<GrantServiceArea__c>();

            for (Grant__c grant : grants) {
                Id programId = grantToProgramMap.get(grant.Id);
                List<ProgramServiceArea__c> programServiceAreas = programToProgramServiceAreasMap.get(programId);
                if(programServiceAreas != null){
                    for (ProgramServiceArea__c programServiceArea : programServiceAreas) {
                        GrantServiceArea__c grantServiceArea = new GrantServiceArea__c();
                        grantServiceArea.ServiceArea__c = programServiceArea.ServiceArea__c;
                        grantServiceArea.Grant__c = grant.Id;
                        grantServiceArea.Code__c = grant.GrantAbbreviation__c;

                        grantServiceAreas.add(grantServiceArea);
                    }
                }
            }

            insert grantServiceAreas;
        }

        List <ApplicationServiceArea__c> appSAList = [Select Id, Name, ServiceArea__r.ServiceArea__c, Application__c
                from ApplicationServiceArea__c
                where Application__c IN: appIdSet];
        if (appSAList.size() > 0) {
            Map<Id, List<ApplicationServiceArea__c>> appIdToSAList = new Map<Id, List<ApplicationServiceArea__c>>();
            for (ApplicationServiceArea__c asa : appSAList) {
                List < ApplicationServiceArea__c > asaList = appIdToSAList.get(asa.Application__c);
                if (asaList == null) {
                    asaList = new List<ApplicationServiceArea__c>();
                }
                asaList.add(asa);
                appIdToSAList.put(asa.Application__c, asaList);
            }
            for (Grant__c grant : grants) {
                Id appId = grantIdToAppIdMap.get(grant.Id);
                List<ApplicationServiceArea__c> asaList = appIdToSAList.get(appId);
                for (ApplicationServiceArea__c obj : asaList) {
                    GrantServiceArea__c pinfo = new GrantServiceArea__c();
                    pinfo.ServiceArea__c = obj.ServiceArea__r.ServiceArea__c;
                    pinfo.Grant__c = grant.id;
                    pinfo.Code__c = grant.GrantAbbreviation__c;
                    grantSAList.add(pinfo);
                }
            }
        } 

        if(grantToProgramMap.size() == 0 && appSAList.size() == 0) {
            List <ServiceArea__c> lstservicearea = [Select id, name, Title__c, Default__c
                                                    from ServiceArea__c
                                                    where Default__c = true];
            for (Grant__c grant : grants) {
                //for (ApplicationServiceArea__c obj : appSAList) {
                GrantServiceArea__c defaultservicearea = new GrantServiceArea__c();
                system.debug('***Testing service Areas' + lstservicearea[0].id);
                defaultservicearea.ServiceArea__c = lstservicearea[0].id;
                defaultservicearea.Grant__c = grant.id;
                defaultservicearea.Code__c = grant.GrantAbbreviation__c;
                grantSAList.add(defaultservicearea);
                //}
            }
        }
        if (!grantSAList.isEmpty()) {
            insert grantSAList;
        }

    }
    */
    /*Insert RecordType as 'Grantee'*/
    private void SetGrantDetails() {

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        Id recordTypeId = Schema.SObjectType.Grant__c.getRecordTypeInfosByName().get('Grantee').getRecordTypeId();
        Id recordTypeId1 = Schema.SObjectType.Grant__c.getRecordTypeInfosByName().get('Grantor').getRecordTypeId();
        
        if(appName != null && appName == 'StateasGrantor' && recordTypeId != null){
            
            List<Id> programIds=new List<Id>();
            
            for(Grant__c grant:(List<Grant__c>)Trigger.New){
                programIds.add(grant.Program__c);
            }
            
            Program__c prog=[Select id,ProgramSubType__c from Program__c where Id IN:programIds LIMIT 1];
        
            for(Grant__c grant: (List<Grant__c>) Trigger.New){
                grant.recordTypeId = recordTypeId1;
                grant.Status__c = 'Draft';
                grant.GrantType1__c=prog.ProgramSubType__c;
            }
        }
       
        
        if (appName != null && appName == 'StateasGrantee' && recordTypeId != null) {
           
            for (Grant__c grant : (List < Grant__c > ) Trigger.New) {
                grant.recordTypeId = recordTypeId;
                grant.Status__c = 'Draft';
            
            }
        }
    }

    /*Method to copy Term and Condition from Program to Grant.*/
    // Commented out because the method is not used - Charan (6/21/2017)
    /*private void copyTnCFromProgramToGrant() {
        //Get the id's set of all associated programs
        Set < Id > relatedProgramsSet = new Set < Id > ();
        for (Grant__c grant : (List < Grant__c > ) Trigger.New) {
            relatedProgramsSet.add(grant.Program__c);
        }

        //Get term and condition of all associated programs
        List < TermCondition__c > tncList = [SELECT Id, Name, RecordTypeId, Program__c, GranteePOC__c, Frequency__c, DueDateDays__c,
                                             Grant__c, FixedEndDate__c, FixedStartDate__c, IsPaymentRequest__c, SubmissionRequired__c,
                                             InstructionsToGrantee__c, Status__c, ReportEndDate__c, ReportStartDate__c, Title__c, TaskAvailability__c, PaymentRequestPackage__c
                                             FROM TermCondition__c WHERE Program__c IN: relatedProgramsSet
                                            ];
        Map<Id, List<TermCondition__c>> programIdToTnCList = new Map<Id, List<TermCondition__c>>();
        for (TermCondition__c termCond : tncList) {
            List < TermCondition__c > tcList = programIdToTnCList.get(termCond.Program__c);
            if (tcList == null) {
                tcList = new List<TermCondition__c>();
            }
            tcList.add(termCond);
            programIdToTnCList.put(termCond.Program__c, tcList);
        }

        List < TermCondition__c > newTnCList = new List < TermCondition__c > ();
        Map<String, Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName();
        Id TnCTermRecTypeId = rtMapByName.get('Term').getRecordTypeId();
        Id TnCConditionRecTypeId = rtMapByName.get('Condition').getRecordTypeId();
        Id TnCReportRecTypeId = rtMapByName.get('Reporting Requirement').getRecordTypeId();
        Id TnCPaymentRecTypeId = rtMapByName.get('Payment Request').getRecordTypeId();

        for (Grant__c grant : (List < Grant__c > ) Trigger.newMap.values()) {
            List < TermCondition__c > tcList = programIdToTnCList.get(grant.Program__c);
            if (tcList != null) {
                for (TermCondition__c termCond : tcList) {
                    TermCondition__c tnc = termCond.clone(false, true, false, false);
                    tnc.Grant__c = grant.id;
                    tnc.Program__c = null;

                    if (termCond.RecordTypeId == TnCTermRecTypeId) {
                        tnc.RecordTypeId = TnCTermRecTypeId;
                    } else if (termCond.RecordTypeId == TnCConditionRecTypeId) {
                        tnc.RecordTypeId = TnCConditionRecTypeId;
                    } else if (termCond.RecordTypeId == TnCReportRecTypeId) {
                        tnc.RecordTypeId = TnCReportRecTypeId;
                    } else if (termCond.RecordTypeId == TnCPaymentRecTypeId) {
                        tnc.RecordTypeId = TnCPaymentRecTypeId;
                    }
                    newTnCList.add(tnc);
                }
            }
        }
        if (newTnCList.size() > 0) {
            insert newTnCList;
        }
    }*/

    private void updateApplication(List<Grant__c> grantList) {

        /*Map<Id,Id> appgrantMap = new Map<Id,Id>();
        for(Grant__c grant: grantList){
            if(grant.Application__c!=null){
            appgrantMap.put(grant.Id,grant.Application__c);
            }
        }
        if(appgrantMap.size()!=null){

        List<Application__c> lstApplications = [Select Id,Status__c from Application__c where Id in : appgrantMap.values() ];

        for(Application__c application : lstApplications){
            application.Status__c = 'Converted to Grant';
         }
           update lstApplications;
        }*/
        Set<Id> appIdSet = new Set<Id>();
        for (Grant__c grant : grantList) {
            if (grant.Application__c != null) {
                appIdSet.add(grant.Application__c);
            }
        }
        if (appIdSet.size() > 0) {
            List<Application__c> updateList = new List<Application__c>();
            for (Id appId : appIdSet) {
                Application__c app = new Application__c(Id = appId, Status__c = 'Converted to Grant');
                updateList.add(app);
            }
            if (updateList.size() > 0) {
                update updateList;
            }
        }
    }

    //Sai Teja - This is new functionality for all agencies to define packages and announcement level and copy them to the awards.
    private void copyPackagesfromAnn(List<Grant__c> grantList){
        system.debug('Inside Copypackages method');
        Map<Id,Id> GranttoAnn = new Map<Id,Id>();
        for(Grant__c grant : grantList){
            if(grant.Announcement__c!=null){
                GranttoAnn.put(grant.Id, grant.Announcement__c);
            }
        }
        List<BusinessPackage__c> businessPackages = [SELECT id, name, FundingOpportunity__c, IsMandatory__c, PackageConfig__c, PackageType__c from BusinessPackage__c where FundingOpportunity__c in :GranttoAnn.values() AND PackageType__c NOT IN ('Application','App-Review')];
        system.debug('BusinessPAckages size '+businessPackages.size());
        Map<Id, List<BusinessPackage__c>> packagesOfAnn = new Map<Id,List<BusinessPackage__c>>();
        for(BusinessPackage__c bp : businessPackages){
            if(!packagesOfAnn.containsKey(bp.FundingOpportunity__c)){
                packagesOfAnn.put(bp.FundingOpportunity__c, new List<BusinessPackage__c>());
            }
            packagesOfAnn.get(bp.FundingOpportunity__c).add(bp);
        }
        List<BusinessPackage__c> businessPackageToInsert = new List<BusinessPackage__c>();
        for (String grantId : GranttoAnn.keySet() ) {
            if (GranttoAnn.get(grantId) != null) {
                List<BusinessPackage__c> grantBusinessPackages = packagesOfAnn.get(GranttoAnn.get(grantId));
                if (grantBusinessPackages != null && grantBusinessPackages.size() > 0) {
                    for (BusinessPackage__c businessPkg : grantBusinessPackages) {
                        businessPackageToInsert.add(new BusinessPackage__c(Grant__c = grantId, IsMandatory__c = businessPkg.IsMandatory__c, PackageConfig__c = businessPkg.PackageConfig__c,
                                                    PackageType__c = businessPkg.PackageType__c) );
                    }
                }
            }
        }
        if (businessPackageToInsert.size() > 0) {
            insert businessPackageToInsert;
        }
    }

    private void PopulatePackages(List<Grant__c> grantList) {
        /*set<id> programids = new set<id>();
        BusinessPackage__c newpackage;
        List<BusinessPackage__c> newpackagelist = new List<BusinessPackage__c>();
        for(Grant__c grant: grantList){
            if(grant.Program__c!=null){
            programids.add(grant.Program__c);
            }
        }
        List<BusinessPackage__c> lstpackages = [Select Id,Name from BusinessPackage__c where Id in : programids ];
        for(Grant__c grant: grantList){
            for(BusinessPackage__c buspackage:lstpackages){
                newpackage = new BusinessPackage__c();
                newpackage.Grant__c = grant.id;
                newpackage.PackageType__c = buspackage.PackageType__c;
                newpackage.PackageConfig__c = buspackage.PackageConfig__c;
                newpackagelist.add(newpackage);
            }
         }
           if(!newpackagelist.isempty()) insert newpackagelist;
        set < id > programids = new set < id > ();
        Map<Id, Id> grantIdToProgramIdMap = new Map<Id, Id>();
        Map<Id, List<BusinessPackage__c>> programIdToBPList = new Map<Id, List<BusinessPackage__c>>();
        for (Grant__c grant : grantList) {
            if (grant.Program__c != null) {
                grantIdToProgramIdMap.put(grant.Id, grant.Program__c);
            }
        }
        if (grantIdToProgramIdMap.size() > 0) {
            List < BusinessPackage__c > newpackagelist = new List < BusinessPackage__c > ();
            List < BusinessPackage__c > lstpackages = [Select Id, Name, Program__c, PackageType__c, PackageConfig__c from BusinessPackage__c where Program__c in: grantIdToProgramIdMap.values()];
            for (BusinessPackage__c bp : lstpackages) {
                List < BusinessPackage__c > lstBP = programIdToBPList.get(bp.Program__c);
                if (lstBP == null) {
                    lstBP = new List<BusinessPackage__c>();
                }
                lstBP.add(bp);
                programIdToBPList.put(bp.Program__c, lstBP);
            }
            for (Id grantId : grantIdToProgramIdMap.keySet()) {
                List < BusinessPackage__c > lstBP = programIdToBPList.get(grantId);
                if (lstBP != null) {
                    for (BusinessPackage__c buspackage : lstBP) {
                        BusinessPackage__c newpackage = new BusinessPackage__c();
                        newpackage.Grant__c = grantId;
                        newpackage.PackageType__c = buspackage.PackageType__c;
                        newpackage.PackageConfig__c = buspackage.PackageConfig__c;
                        newpackagelist.add(newpackage);
                    }
                }
            }
            if (!newpackagelist.isempty()) insert newpackagelist;
        }*/
    }

    /* METHOD to Update the Grantee POC/Sub-Awardee based on Grantee/Recipient Organization*/
    private static void PopulateGranteePOC() {
        /* Set<Id> intorgids = new Set<Id>();
         List<Contact> contactlist = new List<Contact>();
         List<User> userlist = new List<User>();
         for(Grant__c grant: (list<Grant__c>)Trigger.new){
             if(grant.InternalOrganization__c != null){
              intorgids.add(grant.InternalOrganization__c);
             }
           }

          contactlist = [select id,Name,UserRole__c from Contact where UserRole__c='Primary'and accountid IN :intorgids];

          if(!contactlist.isEmpty()){
             userlist = [select id,Name,Contactid from User where Contactid = :contactlist[0].id];

            }



         // SOQL the parent records
          Map<Id, Account> accts = new Map<Id, Account>();
          if(!intorgids.isEmpty()){
                 accts = new Map<Id, Account>([select id, Name from Account where id in: intorgids]);
          }


         system.debug('User List is:'+userlist.isEmpty());
          for(Grant__c grant: (list<Grant__c>)Trigger.new){
          system.debug('Internal Organization is:'+grant.InternalOrganization__c);
             if(grant.InternalOrganization__c != null && !userlist.isEmpty()){
               Account accnt = accts.get(grant.InternalOrganization__c);
               grant.GranteePOC__c = userlist[0].id;
               }

        }*/
        Set < Id > intorgids = new Set < Id > ();
        for (Grant__c grant : (List <Grant__c> ) Trigger.new) {
            if (grant.InternalOrganization__c != null) {
                intorgids.add(grant.InternalOrganization__c);
            }
        }
        if (!intorgids.isEmpty()) {
            Map<Id, Id> accIdToUserId = new Map<Id, Id>();
            List < User > userlist = [select id, Name, AccountId from User where AccountId IN : intorgids AND Contact.KeyContact__c = true];
            for (User usr : userlist) {
                Id userId = accIdToUserId.get(usr.AccountId);
                if (userId == null) {
                    accIdToUserId.put(usr.AccountId, usr.Id);
                }
            }
            for (Grant__c grant : (List <Grant__c> ) Trigger.new) {
                system.debug('Internal Organization is:' + grant.InternalOrganization__c);
                if (grant.InternalOrganization__c != null && !userlist.isEmpty()) {
                    grant.GranteePOC__c = accIdToUserId.get(grant.InternalOrganization__c);
                }
            }
        }


    }
    
    
    private void addRoles(List<Grant__c> grantList) {
        Set<Id> appIdSet = new Set<Id>();
        for (Grant__c grantIterator : grantList) {
            if (grantIterator.ExternalOrgName__c == 'USBE') { appIdSet.add(grantIterator.Application__c); }
        }
        System.debug('MANUALDEBUG >>> appIdSet: ' + appIdSet);
        if (!appIdSet.isEmpty()) {
            // Fetch roles from Application
            List<RolesAndResponsibilities__c> appRolesAndRespList = [
                SELECT Id, Name__c, Application__c, BusinessRole__c, Responsibility__c, Agency__c, RecordTypeId, UserType__c 
                FROM RolesAndResponsibilities__c 
                WHERE Application__c IN: appIdSet];
            System.debug('MANUALDEBUG >>> appRolesAndRespList : ' + appRolesAndRespList);

            List<RolesAndResponsibilities__c> grantRRList = new List<RolesAndResponsibilities__c>();
            for (Grant__c grantIterator : grantList) {
                for (RolesAndResponsibilities__c rolesIterator : appRolesAndRespList ) {
                    if (rolesIterator.Application__c.equals(grantIterator.Application__c)) {
                        RolesAndResponsibilities__c addRole = new RolesAndResponsibilities__c();
                        addRole.Agency__c = rolesIterator.Agency__c;
                        addRole.RecordTypeId = rolesIterator.RecordTypeId;
                        addRole.UserType__c = rolesIterator.UserType__c;
                        addRole.Name__c = rolesIterator.Name__c;
                        addRole.BusinessRole__c = rolesIterator.BusinessRole__c;
                        addRole.Grant__c = grantIterator.Id;
                        addRole.Program__c = grantIterator.Program__c;
                        grantRRList.add(addRole);
                        System.debug('MANUALDEBUG >>> addRole: ' + addRole);
                    }
                }
            }
            try {
                System.debug('MANUALDEBUG >>> grantRRList: ' + grantRRList);
                insert grantRRList;
            }
            catch (Exception e) {
                System.debug('MANUALDEBUG >>> error: ' + e);
            }
        }      
    }
    /*
    private void syncRolesAndRespWithProgram(List<Grant__c> grantList) {
        Map<Id, Id> programIdMapGrantId = new Map<Id, Id>();
        for (Grant__c grantIterator : grantList) {
            programIdMapGrantId.put(grantIterator.Program__c, grantIterator.Id);
        }
        // Fetch name of program approvers from R&R object
        List<RolesAndResponsibilities__c> grantRolesAndRespList = [
            SELECT Id, Name__c, Announcement__c, BusinessRole__c, Responsibility__c,Program__c
            FROM RolesAndResponsibilities__c 
            WHERE Program__c IN: programIdMapGrantId.keySet()];
        System.debug('MANUALDEBUG >>> grantRolesAndRespList: ' + grantRolesAndRespList);
        if (grantRolesAndRespList != null && grantRolesAndRespList.size() > 0) {
            for (RolesAndResponsibilities__c rolesAndRespIterator : grantRolesAndRespList) {
                rolesAndRespIterator.Grant__c = programIdMapGrantId.get(rolesAndRespIterator.Program__c);
            }
        }
        try {
            System.debug('MANUALDEBUG >>> grantRolesAndRespList: ' + grantRolesAndRespList);
            update grantRolesAndRespList;
        }
        catch (Exception e) {
            System.debug('MANUALDEBUG >>> error: ' + e);
        }
        List<Grant__Share> shareList = new List<Grant__Share>();
        for (Grant__c grant : grantList) {
            if (grant.GrantsManager__c != null ) {
                Grant__Share share = new Grant__Share();
                share.UserOrGroupId = grant.GrantsManager__c;
                share.AccessLevel = 'Edit';
                share.ParentId = grant.Id;
                share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantsManager__c;
                shareList.add(share);
            }
        }
        //System.debug(shareList);
        if (shareList.size() > 0) {
            if (Schema.sObjectType.Grant__Share.isCreateable()) {
                SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                SystemContextMethodsHelper.upsertGrantShare(shareList); 
                System.debug(shareList);
            }
        }    
    }
    */

    private void shareToRolesAndUSBE(List<Grant__c> grantList) {
        //If in USBE, given Read access. If in USBE AND are in the associated Announcement's R&R table, then Read/Write
        Set<Id> appIdSet = new Set<Id>();
        for (Grant__c grantIterator : grantList) {
            if (grantIterator.ExternalOrgName__c == 'USBE') { appIdSet.add(grantIterator.Application__c); }
        }
        if (!appIdSet.isEmpty()) {
            // Fetch roles from Application
            List<Application__c> appList = [
                SELECT Id, Announcement__c
                FROM Application__c
                WHERE Id IN: appIdSet];
            List<Id> announcementIdList = new List<Id>();
            Map<Id, Id> appIdMapAnnId = new Map<Id, Id>();
            for (Application__c appIterator : appList) {
                announcementIdList.add(appIterator.Announcement__c);
                appIdMapAnnId.put(appIterator.Id, appIterator.Announcement__c);
            }
            List<RolesAndResponsibilities__c> annRolesAndRespList = [
                SELECT Id, Name__c, Application__c, BusinessRole__c, Responsibility__c, Agency__c, RecordTypeId, UserType__c, RolesAndResponsibilities__c.Announcement__c
                FROM RolesAndResponsibilities__c 
                WHERE Announcement__c IN: announcementIdList AND Name__c != null];
            System.debug('MANUALDEBUG >>> annRolesAndRespList : ' + annRolesAndRespList);

            List<User> userList = [SELECT Id, GNT__OrganizationId__c FROM User WHERE AccountNameFormulaField__c = 'USBE'];
            List<Id> userIdList = new List<Id>();
            for (User userIterator : userList) {
                userIdList.add(userIterator.Id);
            }
            List<Grant__Share> shareList = new List<Grant__Share>();
            for (Grant__c grant : grantList) {
                Set<Id> currentGrantUsersIds = new Set<Id>();
                for (RolesAndResponsibilities__c rrIterator : annRolesAndRespList) { //Add edit sharing if they are in the Announcement's role table
                    if (rrIterator.Announcement__c == appIdMapAnnId.get(grant.Application__c)) {
                        Grant__Share share = new Grant__Share();
                        share.UserOrGroupId = rrIterator.Name__c;
                        share.AccessLevel = 'Edit';
                        share.ParentId = grant.Id;
                        share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantsManager__c;
                        shareList.add(share);
                        currentGrantUsersIds.add(rrIterator.Name__c);
                    }
                    
                }
                for (User userIterator : userList) {
                    if (!currentGrantUsersIds.contains(userIterator.Id)) { //Add only read sharing if they are USBE people BUT are not in the Announcement's role table
                        Grant__Share share = new Grant__Share();
                        share.UserOrGroupId = userIterator.Id;
                        share.AccessLevel = 'Read';
                        share.ParentId = grant.Id;
                        share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantsManager__c;
                        shareList.add(share);
                        //currentGrantUsersIds.add(userIterator.Id);
                    }
                }
            }
            if (shareList.size() > 0) {
                if (Schema.sObjectType.Grant__Share.isCreateable()) {
                    SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                    SystemContextMethodsHelper.upsertGrantShare(shareList); 
                    System.debug(shareList);
                }
            }
        }      
    }

}