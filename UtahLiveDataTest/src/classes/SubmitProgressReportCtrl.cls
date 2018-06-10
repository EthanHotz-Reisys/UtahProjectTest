global with sharing class SubmitProgressReportCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
        String recordId = ApexPages.CurrentPage().getParameters().get('id');
        Pagereference pg = null;
        Id rptId;
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        List<ProgressReports__c> listReport = [SELECT Id, Name, Status__c,OwnerId,FormsValidated__c FROM ProgressReports__c WHERE Id=:recordId  LIMIT 1];
        String userName = UserInfo.getUserName();
        User activeUser = [Select Name, Email From User where Username = : userName limit 1];
        if(listReport!=null && listReport.size()>0){
            ProgressReports__c rpt = listReport[0];
            if(!rpt.FormsValidated__c){
                ApexPages.addmessage(new Apexpages.Message(ApexPages.Severity.INFO,'Please validate the forms before submitting the progress report'));
                return null;
            }
            system.debug('AppName is ' +appName);
            
        if(appName == 'StateasGrantee'){
            system.debug('inside');            
            rpt.status__c='Submitted to Grantor';
            rpt.SubmittedBy__c=UserInfo.getUserId();
            rpt.SubmittedOn__c=System.Today();
            rpt.NameAndTitleOfACO__c=activeUser.Name;
            rpt.DateReportSubmitted__c=Date.today();
            rpt.EmailAddress__c=activeUser.Email;
            rpt.Signature__c = activeUser.Name;
            rptId=rpt.Id;
            update rpt;
            //ApexPages.addmessage(new Apexpages.Message(ApexPages.Severity.INFO,'Progress Report is submitted to Grantor Succesfully'));
            
            ApexPages.addmessage(new Apexpages.Message(ApexPages.Severity.INFO,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-40127')));
        }
        else if(appName == 'Recipient'){
            system.debug('inside '+appName);
            rpt.Status__c = 'Submitted to Grantor';
            rpt.SubmittedBy__c=UserInfo.getUserId();
            rpt.SubmittedOn__c=System.Today();
            rpt.NameAndTitleOfACO__c=activeUser.Name;
            rpt.DateReportSubmitted__c=Date.today();
            rpt.EmailAddress__c=activeUser.Email;
            rpt.Signature__c = activeUser.Name;
            rptId=rpt.Id;
            update rpt;

            GNT.TaskCreationHandler.createApprovalProcessTasks(rpt.Id, 'Review Grantor ProgressReport', rpt.Name, null, System.TODAY() + 7, rpt.Name, true);
            List<Task> taskList = [Select Id, Status, WhatId,lastModifieddate from Task where WhatId = :recordId AND OwnerId=:rpt.OwnerId AND Status='In Progress'];
            if(taskList!=null && taskList.size()>0){
                for(Task task : taskList){
                    task.Status='Completed';
                }
                update taskList;
            }
            EmailTemplate emailTemplate = [Select Id from EmailTemplate where Name = 'Notify Applicant Progress Report Submitted' limit 1];
            Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]>();
            List<String> mailTo = new List<String>();
            mailTo.add(activeUser.Email);
            recIdToAddressMap.put(rptId, mailTo);
            Contact cont = [select id, Email from Contact where email <> null limit 1];
            //AppUtils.sendEmailUsingTemplate(emailTemplate.Id, recIdToAddressMap, cont.Id, false);

            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Progress Report has been submitted successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-40127')));
          
        }
       }
    PageReference p = Page.ProgressReportView;
    p.getParameters().put('Id', rptId);
    p.setRedirect(true);
    return p; 
    }
 }