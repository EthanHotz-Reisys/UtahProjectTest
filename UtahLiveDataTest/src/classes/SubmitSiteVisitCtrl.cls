global with sharing class SubmitSiteVisitCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
        String recordId = ApexPages.CurrentPage().getParameters().get('id');
        Pagereference pg = null;
        
        //check the profile of logged in user.
        List<SiteVisit__c> listReport = [SELECT Id, Status__c, DocumentDueDate__c, Owner.Id, GrantAdministrator__c, 
                                        SiteVisitName__c, Subawardee__c, Name
                                        FROM SiteVisit__c WHERE Id=:recordId  LIMIT 1]; //Owner ID is subrecipient
        
   
        if(listReport!=null && listReport.size()>0)
        {
            SiteVisit__c rpt = listReport[0];
         
            String userName = UserInfo.getUserName();
            User activeUser = [Select Name, Email From User where Username = : userName limit 1];
            //   String userEmail = activeUser.Email;
            if (rpt.Status__c == 'Planned and Submitted to Subrecipient') {
                if (rpt.DocumentDueDate__c < DateTime.now()) {
                    ApexPages.addmessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Document submission due date has passed. Please contact your grant administrator.'));
                    return null;
                }
                List<GNT__AttachmentExtension__c> svAttachmentsList = [SELECT GNT__Classification__c, Owner.Id FROM GNT__AttachmentExtension__c WHERE GNT__ParentId__c =:recordId];
                
                if (checkAttachments(svAttachmentsList, rpt.Subawardee__c)) {
                    
                    rpt.status__c='Submitted to Grantor';
            
                    update rpt;

                    List<Task> tasks = [SELECT WhatId,Status FROM Task where WhatId=:rpt.Id and OwnerId =:rpt.Subawardee__c and Status = 'In Progress'];
                    if (tasks != null && tasks.size() > 0) {
                        for (Task t : tasks) {
                            t.Status = 'Completed';
                        }
                        update tasks;
                    }
                    GNT.TaskCreationHandler.createApprovalProcessTasks(rpt.Id, 'Grantee Attachment Approval', rpt.Name, null, System.TODAY() + 7, rpt.SiteVisitName__c+'- Approve submitted attachments', true); 
                    if (!Test.isRunningTest()) {
                        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-14216') );
                        ApexPages.addmessage(msg);
                    }
                    PageReference p = Page.SiteVisitView;
                    p.getParameters().put('Id', rpt.Id);
                    p.setRedirect(true);
                    return p;
                    
                } else {
                    
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please submit at least one attachment'));
                    return null;
                }
            } else if (rpt.Status__c == 'Sent to Subrecipient') {
                if (!feedbackGiven(recordId)) {
                    ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Feedback is required for all Site Visit Findings'));
                    return null;
                }
                rpt.Status__c = 'Feedback from Subrecipient';
                update rpt;
                List<Task> tasks = [SELECT WhatId,Status FROM Task where WhatId=:rpt.Id and OwnerId =:rpt.Owner.Id and Status = 'In Progress'];
                if (tasks != null && tasks.size() > 0) {
                    for (Task t : tasks) {
                        t.Status = 'Completed';
                    }
                    update tasks;
                }
                GNT.TaskCreationHandler.createTasks(rpt.GrantAdministrator__c, rpt.Id, 'Site Visit Close',rpt.Name, null, false, System.TODAY() + 7, null, rpt.SiteVisitName__c+'- Close the site visit', true);
                new GNT.EmailFeeder().TargetObjectID(rpt.GrantAdministrator__c).template('Site_Visit_Ready_for_Close').contextRecordId(recordId).send();
                if (!Test.isRunningTest()) {
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-14216') );
                    ApexPages.addmessage(msg);
                }
                PageReference p = Page.SiteVisitView;
                p.getParameters().put('Id', rpt.Id);
                p.setRedirect(true);
                return p;
            }
       }
              
        return null;
    }

    private boolean checkAttachments(List<GNT__AttachmentExtension__c> attachmentList, Id subrecipient) {
        if (attachmentList.size() == 0) {
            return false;
        }

        for (GNT__AttachmentExtension__c attachment : attachmentList) {
            if (attachment.OwnerId == subrecipient) {
                return true;
            }
        }

        return false;
    }

    private boolean feedbackGiven(String recordId) {
        List<SiteVisitActivity__c> activityList = [SELECT SiteVisit__r.Id, SubRecipientResponse__c from SiteVisitActivity__c where SiteVisit__r.Id =: recordId and RecordType.Name='External'];
        System.debug('SVID: ' + recordId);
        System.debug('ClassObj: ' + activityList);
        if (activityList.isEmpty()) return false;
        for (SiteVisitActivity__c act : activityList) {
            if (act.SubRecipientResponse__c == null || act.SubRecipientResponse__c == '') {
                return false;
            }
        }
        return true;
    }
 }