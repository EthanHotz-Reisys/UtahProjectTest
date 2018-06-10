global with sharing class InitiateAwardHelper extends GNT.DynamicLayoutActionRedirect {
   
    public class RolesExistanceException extends Exception {}
    public class FinetProgramDataException extends Exception {}
    Static boolean finetError = false;
    
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        system.debug('=======In InitiateAwardHelper======');
        try {
            //Id recordId = layoutHolder.recordId;
            Id recordId = apexpages.currentpage().getparameters().get('id');
            createGrantAndAward(recordId);
        //    system.debug('=======In InitiateAwardHelper===recordId ==='+recordId );
        //    Application__c app = [SELECT Id, CurrentBudgetPeriodEndDate__c,ProposalDescription__c,TotalFederalMatch__c, Announcement__r.GrantCode__c,Announcement__r.Organization__c,ExternalOrganization__r.PointofContactUser__c,ExternalOrganization__r.PointofContactUser__r.Email,
        //                            CurrentBudgetPeriodStartDate__c,ExternalOrganization__c, ExternalOrganization__r.Name, GrantorOrganizationName__c, 
        //                            ProgramId__c, ProjectPeriodEndDate__c,Announcement__r.MatchRequired__c, Announcement__r.Program__r.ProgramPathway__c, Announcement__r.Program__c,
        //                            ProjectPeriodStartDate__c, ObligatedAmount__c,AmountThisAction__c ,RequestedAmount__c, ApplicationType__c, 
        //                            Title__c, Announcement__c, DataEvaluator__c, GrantMonitor__c,IndirectCostPercentage__c,
        //                            ProjectOfficer__c,Announcement__r.Program__r.ProgramSubType__c FROM Application__c WHERE id =: recordId LIMIT 1];
            
        //    if(app.GrantorOrganizationName__c == 'USBE'){
        //        Boolean isUploadProgramUSBE = false;
        //        Set<String> businessRolesToCheck;
        //        if (app.Announcement__r.Program__r.ProgramPathway__c.equals('MSP') || app.Announcement__r.Program__r.ProgramPathway__c.equals('Lump-Sum-No-App')) {
        //            businessRolesToCheck = new Set<String>{'Award Approver 1', 'Award Approver 2', 'Payment Approver 1','Payment Approver 2'};
        //        }
        //        else {
        //            businessRolesToCheck = new Set<String>{'Award Approver 1', 'Award Approver 2', 'Payment Approver 1','Payment Approver 2','Payment Approver 3','Payment Approver 4'};
        //        }
        //        List<RolesAndResponsibilities__c> rolesAndRespList = [SELECT Id, BusinessRole__c, Program__c FROM RolesAndResponsibilities__c WHERE Program__c =: app.Announcement__r.Program__c AND Name__c != null];
        //        Set<String> businessRolesInRoles = new Set<String>();
        //        for (RolesAndResponsibilities__c rolesAndRespIterator : rolesAndRespList) {
        //            if (businessRolesToCheck.contains(rolesAndRespIterator.BusinessRole__c)) {
        //                businessRolesToCheck.remove(rolesAndRespIterator.BusinessRole__c);
        //            }
        //        }
        //        if (businessRolesToCheck.size() > 0) {
        //            throw new RolesExistanceException('In order to create an Award, the roles table in the Program must also contain ' + businessRolesToCheck);
        //        }
        //    }
            
        //    Grant__c grant = new Grant__c();
        //    grant.Application__c = app.Id;
        //    grant.Announcement__c = app.Announcement__c;
        //    grant.ExternalOrganization__c =   app.Announcement__r.Organization__c;          // Grantor  Org
        //    grant.InternalOrganization__c= app.ExternalOrganization__c;
        //    grant.BudgetPeriodStartDate__c = app.CurrentBudgetPeriodStartDate__c;
        //    grant.BudgetPeriodEndDate__c = app.CurrentBudgetPeriodEndDate__c;
        //    grant.ProjectPeriodEndDate__c = app.ProjectPeriodEndDate__c;
        //    grant.ProjectPeriodStartDate__c = app.ProjectPeriodStartDate__c;
        //    grant.GrantAbbreviation__c=app.Announcement__r.GrantCode__c;
        //    grant.GranteePOC__c = app.ExternalOrganization__r.PointofContactUser__c;
        //    grant.ProjectTitle__c = app.Title__c;
        //    grant.Program__c = app.ProgramId__c;
        //    insert grant;
        //    app.awarddecisionstatus__c='Award Created';
        //    app.status__c='Converted to Award';
        //    ApplicationTriggerHelperUOVC.skipTrigger=true;
        //    ApplicationTriggerHelperUSBE.skipTrigger=true;            
        //    update app;
        //    ApplicationTriggerHelperUOVC.skipTrigger=false;
        //    ApplicationTriggerHelperUSBE.skipTrigger=false;

        //    // Update Announcement, decrement negotiation in process, increment negotiation completed, increment awarded count
        //    Announcement__c ann = [Select Id, Name,OrganizationName__c, ApplicationswithNegotiationCompleted__c,ApplicationsAwarded__c,ApplicationswithNegotiationInProcess__c from Announcement__c  where id =:app.Announcement__c];
        //    /*if(ann.ApplicationswithNegotiationCompleted__c==null){
        //        ann.ApplicationswithNegotiationCompleted__c=1;
        //      }
        //      else{
        //        ann.ApplicationswithNegotiationCompleted__c=ann.ApplicationswithNegotiationCompleted__c+1;
        //      }
        //      ann.ApplicationswithNegotiationInProcess__c=ann.ApplicationswithNegotiationInProcess__c-1;*/
        //      ann.ApplicationsAwarded__c=ann.ApplicationsAwarded__c+1;
        //     AnnouncementTriggerHelper.skipTrigger = true;
        //      update ann;
        //      AnnouncementTriggerHelper.skipTrigger = false;
        //    //List<Grant__Share> oldShares = [SELECT Id, AccessLevel, UserOrGroupId 
        //    //                                FROM Grant__Share WHERE ParentId =: grant.Id];
        //    //Map<Id, Grant__Share> shareMap = new Map<Id, Grant__Share>();
        //    //for(Grant__Share gs: oldShares) {
        //    //    shareMap.put(gs.UserOrGroupId, gs);
        //    //}
        //    //Grant__Share share = new Grant__Share();
        //    //List<Grant__Share> shares = new List<Grant__Share>();
        //    //Boolean ins = true;
        //    //if(shareMap.containsKey(app.GrantMonitor__c)) {
        //    //    if(shareMap.get(app.GrantMonitor__c).AccessLevel == 'All' || shareMap.get(app.GrantMonitor__c).AccessLevel == 'Edit') {
        //    //        ins = false;
        //    //    } else {
        //    //        share.Id = shareMap.get(app.GrantMonitor__c).Id;
        //    //    }
        //    //}
        //    //if(ins) {
        //    //    share.parentId = grant.Id;
        //    //    share.UserOrGroupId = app.GrantMonitor__c;
        //    //    share.AccessLevel = 'Edit';
        //    //    share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantMonitor__c; 
        //    //    shares.add(share);
        //    //} else {
        //    //    ins = true;
        //    //}
        //    //if(shareMap.containsKey(app.DataEvaluator__c)) {
        //    //    if(shareMap.get(app.DataEvaluator__c).AccessLevel == 'All' || shareMap.get(app.DataEvaluator__c).AccessLevel == 'Edit') {
        //    //        ins = false;
        //    //    } else {
        //    //        share.Id = shareMap.get(app.DataEvaluator__c).Id;
        //    //    }
        //    //}
        //    //if(ins) {
        //    //    share.parentId = grant.Id;
        //    //    share.UserOrGroupId = app.DataEvaluator__c;
        //    //    share.AccessLevel = 'Edit';
        //    //    share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantMonitor__c; 
        //    //    shares.add(share);
        //    //} else {
        //    //    ins = true;
        //    //}
        //    //if(shareMap.containsKey(app.ProjectOfficer__c)) {
        //    //    if(shareMap.get(app.ProjectOfficer__c).AccessLevel == 'All' || shareMap.get(app.ProjectOfficer__c).AccessLevel == 'Edit') {
        //    //        ins = false;
        //    //    } else {
        //    //        share.Id = shareMap.get(app.ProjectOfficer__c).Id;
        //    //    }
        //    //}
        //    //if(ins) {
        //    //    share.parentId = grant.Id;
        //    //    share.UserOrGroupId = app.ProjectOfficer__c;
        //    //    share.AccessLevel = 'Edit';
        //    //    share.RowCause = Schema.Grant__Share.RowCause.SharetoProjectOfficer__c; 
        //    //    shares.add(share);
        //    //} else {
        //    //    ins = true;
        //    //}
        ////  SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
        ////  SystemContextMethodsHelper.upsertGrantShare(shares);

        //    Award__c award = new Award__c();
        //    award.Application__c = app.Id;
                        
        //    //Original code below:
        //    //award.AwardIssueDate__c = System.Now();
        //    //New code to replace the above code
        //    DateTime tmpDate = System.Now();
        //    award.AwardIssueDate__c = tmpDate.date();
            
        //    //if (app.ApplicationType__c == 'New') {
        //    //    award.AwardType__c = 'New';
        //    //} else {
        //    //    award.AwardType__c = 'Renewal';
        //    //}
        //    award.BudgetPeriodEndDate__c = app.CurrentBudgetPeriodEndDate__c;
        //    award.BudgetPeriodStartDate__c = app.CurrentBudgetPeriodStartDate__c;
        //    award.Grant__c = grant.Id;
        //    award.ProgramCode__c = app.ProgramId__c;
        //    award.AwardNegotiated__c=true;
        //    award.GranteePOC__c = app.ExternalOrganization__r.PointofContactUser__c;
        //    award.GrantAwardDescription__c = app.ProposalDescription__c;
        //    award.ApplicationPOC__c = app.ExternalOrganization__r.PointofContactUser__r.Email;
        //    award.ProjectPeriodEndDate__c = app.ProjectPeriodEndDate__c;
        //    award.ProjectPeriodStartDate__c = app.ProjectPeriodStartDate__c; 
        //    award.IsStateMatchRequired__c=app.Announcement__r.MatchRequired__c;               
        //    award.ProjectTitle__c = app.Title__c;           
        //    award.GrantAwardName__c = app.Title__c;
        //    award.Announcement__c = app.Announcement__c;           
        //    award.TotalObligateAmount__c=app.ObligatedAmount__c;
        //    award.AwardedAmountthisAction__c=app.AmountThisAction__c;
        //    award.ObligatedAwardAmount__c = app.TotalFederalMatch__c;
        //    award.IndirectCostPercentageProposed__c=app.IndirectCostPercentage__c;
        //    insert award;

        //    //List<AnnouncementFundingAccount__c> appFundingAccounts = [SELECT FundingAccount__c FROM AnnouncementFundingAccount__c WHERE Announcement__c =: app.Announcement__c];
        //    //List<AwardFundingAccount__c> awardFundingAccounts = new List<AwardFundingAccount__c>();
        //    //AwardFundingAccount__c tmpAwardFA;
        //    //for(AnnouncementFundingAccount__c tmpAppFA: appFundingAccounts) {
        //    //    tmpAwardFA = new AwardFundingAccount__c(Award__c = award.Id, FinancialAssistanceAmount__c = 0, FundingAccount__c = tmpAppFA.FundingAccount__c);
        //    //    awardFundingAccounts.add(tmpAwardFA);
        //    //}
        //    //System.debug(awardFundingAccounts.size());
        //    //if(awardFundingAccounts.size() > 0) {
        //    //    insert awardFundingAccounts;
        //    //}

        //    List<Attachment> appAttachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =: app.Id];
        //    List<Attachment> awardAttachments = new List<Attachment>();
        //    Attachment tmpAttachment;
        //    for (Attachment a: appAttachments) {
        //        tmpAttachment = new Attachment(name = a.Name, body = a.Body, parentId = award.Id);
        //        awardAttachments.add(tmpAttachment);
        //    }
        //    System.debug(awardAttachments.size());
        //    if(awardAttachments.size() > 0) {
        //        insert awardAttachments;
        //        GNT__AttachmentExtension__c tmpExt;
        //        List<String> attIds = new List<String>();
        //        for(Attachment att: awardAttachments) {
        //            attIds.add(att.Id);
        //        }
        //        List<GNT__AttachmentExtension__c> extensions = [SELECT GNT__AttachmentName__c, GNT__Attachment__c, GNT__Classification__c FROM GNT__AttachmentExtension__c WHERE GNT__Attachment__c IN: attIds];
        //        Map<String, GNT__AttachmentExtension__c> attMap = new Map<String, GNT__AttachmentExtension__c>();
        //        for(GNT__AttachmentExtension__c ext: extensions) {
        //            attMap.put(ext.GNT__Attachment__c, ext);
        //        }
        //        List<GNT__AttachmentExtension__c> newExts = new List<GNT__AttachmentExtension__c>();
        //        for(Attachment att: awardAttachments) {
        //            if(attMap.get(att.Id)!=null){
        //                tmpExt = new GNT__AttachmentExtension__c();
        //                tmpExt.GNT__ParentId__c = award.Id;
        //                tmpExt.GNT__Attachment__c = att.Id;
        //                tmpExt.GNT__AttachmentName__c = attMap.get(att.Id).GNT__AttachmentName__c;
        //                tmpExt.GNT__Classification__c = attMap.get(att.Id).GNT__Classification__c;
        //                newExts.add(tmpExt);
        //            }
        //        }
        //        System.debug(newExts.size());
        //        insert newExts;
        //    }
        //    if(ann.OrganizationName__c == 'USBE'){
        //        linkFinetCode(new List<Award__c>{award});
        //    }
            //PageReference p = Page.AwardView;
           // p.getParameters().put('id',award.Id);
            //p.setRedirect(true);
            //return p;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Success'));  
        } catch (RolesExistanceException  e) {
            ApplicationTriggerHelper.skipTrigger=false;
            AnnouncementTriggerHelper.skipTrigger=false;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        } catch(Exception e){
            ApplicationTriggerHelper.skipTrigger=false;
            AnnouncementTriggerHelper.skipTrigger=false;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;

    }

    @future
    private static void createGrantAndAward(Id recordId){
        system.debug('=======In InitiateAwardHelper===recordId ==='+recordId );
        Application__c app = [SELECT Id, CurrentBudgetPeriodEndDate__c,ProposalDescription__c,TotalFederalMatch__c, Announcement__r.GrantCode__c,Announcement__r.Organization__c,ExternalOrganization__r.PointofContactUser__c,ExternalOrganization__r.PointofContactUser__r.Email,
                                CurrentBudgetPeriodStartDate__c,ExternalOrganization__c, ExternalOrganization__r.Name, GrantorOrganizationName__c, 
                                ProgramId__c, ProjectPeriodEndDate__c,Announcement__r.MatchRequired__c, Announcement__r.Program__r.ProgramPathway__c, Announcement__r.Program__c,
                                ProjectPeriodStartDate__c, ObligatedAmount__c,AmountThisAction__c ,RequestedAmount__c, ApplicationType__c, 
                                Title__c, Announcement__c, DataEvaluator__c, GrantMonitor__c,IndirectCostPercentage__c,
                                ProjectOfficer__c,Announcement__r.Program__r.ProgramSubType__c FROM Application__c WHERE id =: recordId LIMIT 1];
        
        if(app.GrantorOrganizationName__c == 'USBE'){
            Boolean isUploadProgramUSBE = false;
            Set<String> businessRolesToCheck;
            if (app.Announcement__r.Program__r.ProgramPathway__c.equals('MSP') || app.Announcement__r.Program__r.ProgramPathway__c.equals('Lump-Sum-No-App')) {
                businessRolesToCheck = new Set<String>{'Award Approver 1', 'Award Approver 2', 'Payment Approver 1','Payment Approver 2'};
            }
            else {
                businessRolesToCheck = new Set<String>{'Award Approver 1', 'Award Approver 2', 'Payment Approver 1','Payment Approver 2','Payment Approver 3','Payment Approver 4'};
            }
            List<RolesAndResponsibilities__c> rolesAndRespList = [SELECT Id, BusinessRole__c, Program__c FROM RolesAndResponsibilities__c WHERE Program__c =: app.Announcement__r.Program__c AND Name__c != null];
            Set<String> businessRolesInRoles = new Set<String>();
            for (RolesAndResponsibilities__c rolesAndRespIterator : rolesAndRespList) {
                if (businessRolesToCheck.contains(rolesAndRespIterator.BusinessRole__c)) {
                    businessRolesToCheck.remove(rolesAndRespIterator.BusinessRole__c);
                }
            }
            if (businessRolesToCheck.size() > 0) {
                throw new RolesExistanceException('In order to create an Award, the roles table in the Program must also contain ' + businessRolesToCheck);
            }
        }
        
        Grant__c grant = new Grant__c();
        grant.Application__c = app.Id;
        grant.Announcement__c = app.Announcement__c;
        grant.ExternalOrganization__c =   app.Announcement__r.Organization__c;          // Grantor  Org
        grant.InternalOrganization__c= app.ExternalOrganization__c;
        grant.BudgetPeriodStartDate__c = app.CurrentBudgetPeriodStartDate__c;
        grant.BudgetPeriodEndDate__c = app.CurrentBudgetPeriodEndDate__c;
        grant.ProjectPeriodEndDate__c = app.ProjectPeriodEndDate__c;
        grant.ProjectPeriodStartDate__c = app.ProjectPeriodStartDate__c;
        grant.GrantAbbreviation__c=app.Announcement__r.GrantCode__c;
        grant.GranteePOC__c = app.ExternalOrganization__r.PointofContactUser__c;
        grant.ProjectTitle__c = app.Title__c;
        grant.Program__c = app.ProgramId__c;
        insert grant;
        app.awarddecisionstatus__c='Award Created';
        app.status__c='Converted to Award';
        ApplicationTriggerHelperUOVC.skipTrigger=true;
        ApplicationTriggerHelperUSBE.skipTrigger=true;            
        update app;
        ApplicationTriggerHelperUOVC.skipTrigger=false;
        ApplicationTriggerHelperUSBE.skipTrigger=false;

        // Update Announcement, decrement negotiation in process, increment negotiation completed, increment awarded count
        Announcement__c ann = [Select Id, Name,OrganizationName__c, ApplicationswithNegotiationCompleted__c,ApplicationsAwarded__c,ApplicationswithNegotiationInProcess__c from Announcement__c  where id =:app.Announcement__c];
        /*if(ann.ApplicationswithNegotiationCompleted__c==null){
            ann.ApplicationswithNegotiationCompleted__c=1;
          }
          else{
            ann.ApplicationswithNegotiationCompleted__c=ann.ApplicationswithNegotiationCompleted__c+1;
          }
          ann.ApplicationswithNegotiationInProcess__c=ann.ApplicationswithNegotiationInProcess__c-1;*/
          ann.ApplicationsAwarded__c=ann.ApplicationsAwarded__c+1;
         AnnouncementTriggerHelper.skipTrigger = true;
          update ann;
          AnnouncementTriggerHelper.skipTrigger = false;
        //List<Grant__Share> oldShares = [SELECT Id, AccessLevel, UserOrGroupId 
        //                                FROM Grant__Share WHERE ParentId =: grant.Id];
        //Map<Id, Grant__Share> shareMap = new Map<Id, Grant__Share>();
        //for(Grant__Share gs: oldShares) {
        //    shareMap.put(gs.UserOrGroupId, gs);
        //}
        //Grant__Share share = new Grant__Share();
        //List<Grant__Share> shares = new List<Grant__Share>();
        //Boolean ins = true;
        //if(shareMap.containsKey(app.GrantMonitor__c)) {
        //    if(shareMap.get(app.GrantMonitor__c).AccessLevel == 'All' || shareMap.get(app.GrantMonitor__c).AccessLevel == 'Edit') {
        //        ins = false;
        //    } else {
        //        share.Id = shareMap.get(app.GrantMonitor__c).Id;
        //    }
        //}
        //if(ins) {
        //    share.parentId = grant.Id;
        //    share.UserOrGroupId = app.GrantMonitor__c;
        //    share.AccessLevel = 'Edit';
        //    share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantMonitor__c; 
        //    shares.add(share);
        //} else {
        //    ins = true;
        //}
        //if(shareMap.containsKey(app.DataEvaluator__c)) {
        //    if(shareMap.get(app.DataEvaluator__c).AccessLevel == 'All' || shareMap.get(app.DataEvaluator__c).AccessLevel == 'Edit') {
        //        ins = false;
        //    } else {
        //        share.Id = shareMap.get(app.DataEvaluator__c).Id;
        //    }
        //}
        //if(ins) {
        //    share.parentId = grant.Id;
        //    share.UserOrGroupId = app.DataEvaluator__c;
        //    share.AccessLevel = 'Edit';
        //    share.RowCause = Schema.Grant__Share.RowCause.SharetoGrantMonitor__c; 
        //    shares.add(share);
        //} else {
        //    ins = true;
        //}
        //if(shareMap.containsKey(app.ProjectOfficer__c)) {
        //    if(shareMap.get(app.ProjectOfficer__c).AccessLevel == 'All' || shareMap.get(app.ProjectOfficer__c).AccessLevel == 'Edit') {
        //        ins = false;
        //    } else {
        //        share.Id = shareMap.get(app.ProjectOfficer__c).Id;
        //    }
        //}
        //if(ins) {
        //    share.parentId = grant.Id;
        //    share.UserOrGroupId = app.ProjectOfficer__c;
        //    share.AccessLevel = 'Edit';
        //    share.RowCause = Schema.Grant__Share.RowCause.SharetoProjectOfficer__c; 
        //    shares.add(share);
        //} else {
        //    ins = true;
        //}
    //  SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
    //  SystemContextMethodsHelper.upsertGrantShare(shares);

        Award__c award = new Award__c();
        award.Application__c = app.Id;
                    
        //Original code below:
        //award.AwardIssueDate__c = System.Now();
        //New code to replace the above code
        DateTime tmpDate = System.Now();
        award.AwardIssueDate__c = tmpDate.date();
        
        //if (app.ApplicationType__c == 'New') {
        //    award.AwardType__c = 'New';
        //} else {
        //    award.AwardType__c = 'Renewal';
        //}
        award.BudgetPeriodEndDate__c = app.CurrentBudgetPeriodEndDate__c;
        award.BudgetPeriodStartDate__c = app.CurrentBudgetPeriodStartDate__c;
        award.Grant__c = grant.Id;
        award.ProgramCode__c = app.ProgramId__c;
        award.AwardNegotiated__c=true;
        award.GranteePOC__c = app.ExternalOrganization__r.PointofContactUser__c;
        award.GrantAwardDescription__c = app.ProposalDescription__c;
        award.ApplicationPOC__c = app.ExternalOrganization__r.PointofContactUser__r.Email;
        award.ProjectPeriodEndDate__c = app.ProjectPeriodEndDate__c;
        award.ProjectPeriodStartDate__c = app.ProjectPeriodStartDate__c; 
        award.IsStateMatchRequired__c=app.Announcement__r.MatchRequired__c;               
        award.ProjectTitle__c = app.Title__c;           
        award.GrantAwardName__c = app.Title__c;
        award.Announcement__c = app.Announcement__c;           
        award.TotalObligateAmount__c=app.ObligatedAmount__c;
        award.AwardedAmountthisAction__c=app.AmountThisAction__c;
        award.ObligatedAwardAmount__c = app.TotalFederalMatch__c;
        award.IndirectCostPercentageProposed__c=app.IndirectCostPercentage__c;
        insert award;

        //List<AnnouncementFundingAccount__c> appFundingAccounts = [SELECT FundingAccount__c FROM AnnouncementFundingAccount__c WHERE Announcement__c =: app.Announcement__c];
        //List<AwardFundingAccount__c> awardFundingAccounts = new List<AwardFundingAccount__c>();
        //AwardFundingAccount__c tmpAwardFA;
        //for(AnnouncementFundingAccount__c tmpAppFA: appFundingAccounts) {
        //    tmpAwardFA = new AwardFundingAccount__c(Award__c = award.Id, FinancialAssistanceAmount__c = 0, FundingAccount__c = tmpAppFA.FundingAccount__c);
        //    awardFundingAccounts.add(tmpAwardFA);
        //}
        //System.debug(awardFundingAccounts.size());
        //if(awardFundingAccounts.size() > 0) {
        //    insert awardFundingAccounts;
        //}

        List<Attachment> appAttachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId =: app.Id];
        List<Attachment> awardAttachments = new List<Attachment>();
        Attachment tmpAttachment;
        for (Attachment a: appAttachments) {
            tmpAttachment = new Attachment(name = a.Name, body = a.Body, parentId = award.Id);
            awardAttachments.add(tmpAttachment);
        }
        System.debug(awardAttachments.size());
        if(awardAttachments.size() > 0) {
            insert awardAttachments;
            GNT__AttachmentExtension__c tmpExt;
            List<String> attIds = new List<String>();
            for(Attachment att: awardAttachments) {
                attIds.add(att.Id);
            }
            List<GNT__AttachmentExtension__c> extensions = [SELECT GNT__AttachmentName__c, GNT__Attachment__c, GNT__Classification__c FROM GNT__AttachmentExtension__c WHERE GNT__Attachment__c IN: attIds];
            Map<String, GNT__AttachmentExtension__c> attMap = new Map<String, GNT__AttachmentExtension__c>();
            for(GNT__AttachmentExtension__c ext: extensions) {
                attMap.put(ext.GNT__Attachment__c, ext);
            }
            List<GNT__AttachmentExtension__c> newExts = new List<GNT__AttachmentExtension__c>();
            for(Attachment att: awardAttachments) {
                if(attMap.get(att.Id)!=null){
                    tmpExt = new GNT__AttachmentExtension__c();
                    tmpExt.GNT__ParentId__c = award.Id;
                    tmpExt.GNT__Attachment__c = att.Id;
                    tmpExt.GNT__AttachmentName__c = attMap.get(att.Id).GNT__AttachmentName__c;
                    tmpExt.GNT__Classification__c = attMap.get(att.Id).GNT__Classification__c;
                    newExts.add(tmpExt);
                }
            }
            System.debug(newExts.size());
            insert newExts;
        }
        if(ann.OrganizationName__c == 'USBE'){
            linkFinetCode(new List<Award__c>{award});
        }
    }

    private static void linkFinetCode(List<Award__c> newAwardList) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<Award__c> awardList = new List<Award__c>([SELECT Id, Status__c, Grant__r.InternalOrganization__c, Grant__r.Program__c, Grant__r.Application__r.ProgramFiscalYear__c FROM Award__c WHERE Id IN :newAwardList]);
            List<Id> programIdList = new List<Id>();
            List<Id> subRecipientIdList = new List<Id>();
            List<String> fiscalYearList = new List<String>();
            for (Award__c award : awardList) {
                programIdList.add(award.Grant__r.Program__c);
                subRecipientIdList.add(award.Grant__r.InternalOrganization__c);
                fiscalYearList.add(award.Grant__r.Application__r.ProgramFiscalYear__c.substring(4, 8));
            }

            List<FedBudgetMain__c> fedMainList = new List<FedBudgetMain__c>([SELECT Id, Program__c, SubRecipient__c, ProgramCode__c,
                    ObjectCode__c, BudgetAmountFormula__c, FiscalYear__c
                    FROM FedBudgetMain__c WHERE
                    Program__c IN :programIdList AND SubRecipient__c IN :subRecipientIdList
                    AND FiscalYear__c IN :fiscalYearList
                                                                            ]);
            System.debug('MANUALDEBUG >>> fedMainList: ' + fedMainList);
            List<String> programCodeList = new List<String>();
            List<String> objectCodeList = new List<String>();
            Map<String, List<FedBudgetMain__c>> fedMainMap = new Map<String, List<FedBudgetMain__c>>();
            for (FedBudgetMain__c fedMain : fedMainList) {
                String key = String.valueOf(fedMain.Program__c) + String.valueOf(fedMain.SubRecipient__c) + fedMain.FiscalYear__c;
                if (!fedMainMap.containsKey(key)) {
                    fedMainMap.put(key, new List<FedBudgetMain__c>());
                }
                fedMainMap.get(key).add(fedMain);
                programCodeList.add(fedMain.ProgramCode__c);
                objectCodeList.add(fedMain.ObjectCode__c);
            }

            List<r_prog__c> programCode = [SELECT Id, PROG_CD__c, FederalAwardDate__c, FAINnumber__c, FederalAwardedAmount__c FROM r_prog__c WHERE PROG_CD__c IN :programCodeList];
            List<r_obj__c> objectCode = [SELECT Id, OBJ_CD__c FROM r_obj__c WHERE OBJ_CD__c IN :objectCodeList];
            System.debug('MANUALDEBUG >>> programCode: ' + programCode);

            Map<String, Id> programCodeMap = new Map<String, Id>();
            Map<String, Id> objectCodeMap = new Map<String, Id>();

            for (r_prog__c pc : programCode) {
                if (pc.FederalAwardDate__c == null || pc.FAINnumber__c == null || pc.FederalAwardedAmount__c == null) {
                    finetError = true; //throw new FinetProgramDataException('To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount');
                    //pc.addError('To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount');
                    throw new FinetProgramDataException('To create an Award, please ensure that your Finet Program contains values for Federal Award Date, FAIN Number, and Federal Awarded Amount');
                }
                programCodeMap.put(pc.PROG_CD__c, pc.Id);
            }
            System.debug('MANUALDEBUG >>> programCodeMap: ' + programCodeMap);

            for (r_obj__c oc : objectCode) {
                objectCodeMap.put(oc.OBJ_CD__c, oc.Id);
            }

            List<AwardFINETCode__c> newAfcList = new List<AwardFINETCode__c>();
            for (Award__c award : awardList) {
                for (FedBudgetMain__c fedMain : fedMainMap.get(String.valueOf(award.Grant__r.Program__c) + String.valueOf(award.Grant__r.InternalOrganization__c) + award.Grant__r.Application__r.ProgramFiscalYear__c.substring(4, 8))) {
                    System.debug('MANUALDEBUG >>> fedMain: ' + fedMain);
                    System.debug('MANUALDEBUG >>> programCode: ' + programCodeMap.get(fedMain.ProgramCode__c));
                    AwardFINETCode__c temp = new AwardFINETCode__c(
                        Award__c = award.Id,
                        AwardStatus__c = award.Status__c,
                        ProgramCode__c = programCodeMap.get(fedMain.ProgramCode__c),
                        ObjectCode__c = objectCodeMap.get(fedMain.ObjectCode__c),
                        Amount__c = fedMain.BudgetAmountFormula__c
                    );
                    newAfcList.add(temp);
                }
            }
            insert newAfcList;
        } catch (FinetProgramDataException e) {
            Database.rollback(sp);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } catch (Exception e) {
            Database.rollback(sp);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

    }
}