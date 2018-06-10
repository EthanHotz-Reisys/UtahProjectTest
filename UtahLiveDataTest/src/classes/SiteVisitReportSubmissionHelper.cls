global with sharing class SiteVisitReportSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
    Boolean isError = false;
    public SiteVisitReportSubmissionHelper() {}
    public SiteVisitReportSubmissionHelper(GNT.DynamicLayoutHolder layoutHolder) {
        this.layoutHolder = layoutHolder;
    }
    global override PageReference whenClicked(){
        String siteVisitReportId = layoutHolder.recordId;
        system.debug('siteVisitReportId: '+siteVisitReportId);
        Savepoint sp = Database.setSavepoint();
        try {
            if(siteVisitReportId != null) {
                //Approval.ProcessResult result = GNT.AppUtils.submitRecordForApproval(siteVisitReportId);
                //system.debug('result: '+result);

                
                SiteVisit__c sv = [Select id,Name,DateReportSubmitted__c,SubmittedOn__c,SubmittedBy__c,ActivityQuestion2__c,ProjectTitle__c, FormsValidated__c, SiteVisitName__c FROM SiteVisit__c where id =: siteVisitReportId limit 1];
                 system.debug('Site Visit sv------ '+sv);
                 Id svid = sv.id;
                List<SiteVisitActivity__c> sva = new List<SiteVisitActivity__c>([Select id,ActivityDescription__c,Date__c FROM SiteVisitActivity__c WHERE SiteVisit__c = :svid] );
                 system.debug('Site Visit sva--------' +sva.size());
                 if(sva.size() == 0){
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add at least 1 Site Visit Finding'));
                 return null;
                 }
                 if(!sv.FormsValidated__c){
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Forms needs to be validated before the site visit can be submitted.')); 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M02-GRNTR-16621')));
                    isError = true;
                  }
                  if(isError == true){
                    return null;
                  }

                sv.DateReportSubmitted__c = System.Today();      
                sv.SubmittedOn__c=System.Today();     
                sv.SubmittedBy__c=UserInfo.getUserId();
                SiteVisitTriggerHelper.skipTrigger=True;
                update sv;
                SiteVisitTriggerHelper.skipTrigger=False;

                // EmailTemplate emailTemplate = [Select Id from EmailTemplate where Name = 'Site Visit Report Submitted' limit 1];
                // Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
                // List<String> mailTo = new List<String>();
                // mailTo.add(UserInfo.getUserEmail());
                // recIdToAddressMap.put(sv.Id, mailTo);
                // Contact cont = [select id, Email from Contact where email <> null limit 1];
                // AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, cont.Id, false);
                    
            if( sv.ActivityQuestion2__c==null)
            {
             
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in the Achievement of the Site Visit'));
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-68475')));
             return null;
            }

            List<String> reportIds = new List<String>();
            Map<String, Map<String, SiteVisit__Share>> shareMap = new Map<String, Map<String, SiteVisit__Share>>();
            List<SiteVisit__c> sVisits = [Select id,Name,DateReportSubmitted__c,GrantAdministrator__c,SubmittedOn__c,SubmittedBy__c,ActivityQuestion2__c,ProjectTitle__c, FormsValidated__c, SiteVisitName__c FROM SiteVisit__c where id =: siteVisitReportId limit 1];
            for(SiteVisit__c report: sVisits) {
            reportIds.add(report.id);
                if(!shareMap.containsKey(report.id)) {
                    shareMap.put(report.id, new Map<String, SiteVisit__Share>());
                }
            }
            List<SiteVisit__Share> currentShares = [SELECT ParentId, AccessLevel, UserOrGroupId FROM SiteVisit__Share WHERE ParentId IN: reportIds];
            System.debug(currentShares);
            for(SiteVisit__Share ps: currentShares) {
                shareMap.get(ps.ParentId).put(ps.userOrGroupId, ps);
            }
            SiteVisit__Share share;
            List<SiteVisit__Share> shares = new List<SiteVisit__Share>();
            List<SiteVisit__c> reportslist = [select id,Award__r.CreatedById,ApprovalManager__c,Award__r.ProgramManager__c,ProjectManager__c, GrantAdministrator__c, ProgramApprover__c,OwnerId  
                                                      from SiteVisit__c where id IN:reportIds ];
            for(SiteVisit__c report: reportslist) {
            System.debug('**report: ' + report);
            system.debug('Grant Admin is ' +report.GrantAdministrator__c);
            if(report.ProgramApprover__c != null && report.Award__r.CreatedById!=report.OwnerId) {
                    share = new SiteVisit__Share(parentId = report.id, AccessLevel = 'Edit', UserOrGroupId = report.ProgramApprover__c, RowCause = Schema.SiteVisit__Share.RowCause.SharetoApprover__c);
                    shares.add(share);
                    shareMap.get(report.id).put(report.ProgramApprover__c, share);
                }
            }
            try{
            if(shares.size() > 0) {
                    System.debug('Upsert');
                     SystemContextMethodsHelper SystemContextMethodsHelper = new SystemContextMethodsHelper();
                SystemContextMethodsHelper.upsertSiteVisitShare(shares);
                }
            }
            catch(Exception exc){
                system.debug(exc.getStackTraceString());
                system.debug(exc.getMessage());
            }
             //GNT.TaskCreationHandler.createApprovalProcessTasks(sv.Id,'Review Site Visit Report',sv.Name,null,System.Today() + 7,true);
             GNT.TaskCreationHandler.createApprovalProcessTasks(sv.Id,'Review Site Visit Report',sv.Name,null,System.Today() + 7, sv.SiteVisitName__c+'- Review the site visit report',true);
              system.debug('Site Visit task completion------ ');
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Site Visit Report has been successfully submitted for approval'));
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-09537')));

            List<Task> taskList = [Select Id, Status, WhatId,lastModifieddate from Task where WhatId = :sv.Id AND Status='In Progress'];
            if(taskList!=null && taskList.size()>0){
                for(Task task : taskList){
                    task.Status='Completed';
                }
                update taskList;
            }

             system.debug('Site Visit Reported successfully------ ');
            }
        }
        catch(Exception e) {
            Database.rollback(sp);
                system.debug('siteVisitReportId: exception '+e.getMessage());
            //return e.getMessage();
        }
        PageReference pageUrl = Page.SiteVisitView;
        pageUrl.getParameters().put('id',siteVisitReportId);
        pageUrl.setRedirect(true);
        return pageUrl;
    }
}