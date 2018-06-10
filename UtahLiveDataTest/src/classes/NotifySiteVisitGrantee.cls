/*
    
    ***********************************************************
    Audit History
    ***********************************************************
    09/15/2015      Nishit Babaria             Created
    2017-04-01      Shah Kadirmohideen         Code Reviewed
    *********************************************************** 
*/

global with sharing class NotifySiteVisitGrantee extends GNT.DynamicLayoutActionRedirect {
    
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    global override PageReference whenClicked(){
 
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        Id recordId ;
        SiteVisit__c siteVisit;
        try{

            system.debug('***NotifySiteVisitGrantee***');

            recordId = apexpages.currentpage().getparameters().get('id');
            siteVisit = [SELECT Id,Name,SiteVisitPersons__c,NotifiedRecipientPointofContact__c,Award__r.Grant__r.InternalOrganization__c ,VisitDateandTime__c,VisitEndDateTime__c,
            ActivityQuestion1__c,ActivityQuestion3__c , TypeofSiteVisit__c,Award__r.SubAwardee__c,NotificationTemplate__c,SubAwardee__c,SubAwardee__r.Email, DocumentDueDate__c, SiteVisitName__c
                                        FROM SiteVisit__c WHERE ID = : recordId];
    
            List<SiteVisitPerson__c> siteVisitPersons = new List<SiteVisitPerson__c>([Select id,SiteVisit__c,User__r.IsExternalUser__c FROM SiteVisitPerson__c where SiteVisit__c =: recordId]);
            Boolean AddGranteePersonnel = false;
            Boolean AddGrantorPersonnel = false;

             system.debug('***NotifySiteVisitGrantee***siteVisitPersons---'+siteVisitPersons);

             for(SiteVisitPerson__c svp : siteVisitPersons){
                if(svp.User__r.IsExternalUser__c){
                    AddGranteePersonnel = True;
                }else if(svp.User__r.IsExternalUser__c == false){
                    AddGrantorPersonnel = True;
                }
             }

             if(AddGranteePersonnel == false || AddGrantorPersonnel == false){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please add atleast one grantor personnel and one grantee personnel'));
                return null;
             }

             if(siteVisitPersons==null || siteVisitPersons.size()<2)
             {
               /* Pranjali : Commented out the first addMessage for test coverage */
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please add the Internal Attendees for the Site Visit'));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-26182')));
               return null;
             }

             if (siteVisit.DocumentDueDate__c == null) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a Document Submission Due Date'));
                 return null;
             }

             if (siteVisit.DocumentDueDate__c < System.TODAY()) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose a future document due date'));
                 return null;
             }

              if(siteVisit.ActivityQuestion1__c==null || siteVisit.ActivityQuestion3__c==null  || siteVisit.TypeofSiteVisit__c==null)
             {
               /* Pranjali : Commented out the first addMessage for test coverage */
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the details for the Visit (Purpose, Type of Visit, Source of Planning)'));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-99919')));
               return null;
             }

            if(siteVisit != null && siteVisit.VisitDateandTime__c != null && siteVisit.VisitEndDateTime__c != null && siteVisit.ActivityQuestion1__c != null) {
                errorMsg = sendEmailNotification(siteVisit);
                if(errorMsg != '') {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
               return null;
                }
                
            }
            else {
              // Commented the next line since it is not used- charan(5/1/2017)
              // errorMsg = 'Please fill out the visit date and time, people attending the site visit and reason for the visit';
            //  return errorMsg; 
                 // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                //  return errorMsg;
            //   return null;

            }
           
        }
        catch(Exception e){
            Database.rollback(sp);
            errorMsg = e.getMessage();
            
        }


        try {
            siteVisit.NotifiedRecipientPointofContact__c = true;
            siteVisit.Status__c='Planned and Submitted to Subrecipient';
            update siteVisit;

            List<Task> taskList = [Select Id, Status, WhatId,lastModifieddate from Task where WhatId = :siteVisit.Id AND Status='In Progress'];
            if(taskList!=null && taskList.size()>0){
                for(Task task : taskList){
                    task.Status='Completed';
                }
                update taskList;
            }

        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'All attendees have been notified successfully'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-89028')));
        PageReference p = Page.SiteVisitView;
        p.getParameters().put('Id',recordId);
        p.setRedirect(true);
        return p;

        }
        catch(Exception e) {
            system.debug(e.getMessage());
        }
        
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));  
     return null;
    }
    
     private String sendEmailNotification(SiteVisit__c siteVisit){
        
        List<EmailTemplate> emailTemplate = new List<EmailTemplate>();
        String notificationTemplate = '';
        Id targetUserId;
        String svpName = '';
        String[] toAddresses = new String[] {};
        List<Task> tasks = new List<Task>();
        
        // Emails will be sent to all internal attendees and all contacts
    
        //for(SiteVisitPerson__c svPerson : [Select Id, User__c, Contact__c, FullName__c, EmailID__c, SiteVisit__r.SiteVisitName__c from SiteVisitPerson__c where SiteVisit__c=:siteVisit.Id])
        //{
            //toAddresses.add(svPerson.EmailID__c);
            //new GNT.EmailFeeder().TargetObjectID(svPerson.User__c).template('GranteeSiteVisitNotifyEmailTemplate').contextRecordId(siteVisit.Id).send();
        //    svpName += svPerson.FullName__c + '; ';
        //    if (svPerson.User__c == siteVisit.SubAwardee__c) {
                GNT.TaskCreationHandler.createTasks(siteVisit.Subawardee__c, siteVisit.Id, 'Site Visit Submit Attachments', siteVisit.Name, null, false, System.TODAY() + 7, null, siteVisit.SiteVisitName__c + '- Submit required attachments', true);
                new GNT.EmailFeeder().TargetObjectID(siteVisit.Subawardee__c).template('Site_Visit_Attachments_Submit_Request').contextRecordId(siteVisit.Id).send();
        //    }
        //}
        siteVisit.SiteVisitPersons__c = svpName;
        update siteVisit; 
        // try {
        // insert tasks;
        // } catch (Exception e) {
        //     return 'Insert failed: ' + e;
        // }

  /*      for(Contact contact : [Select Title,Name,Email,Phone from Contact where Account.Id=:siteVisit.Award__r.Grant__r.InternalOrganization__c ])
        {
             toAddresses.add(contact.Email);
        }

    */
    //      system.debug('siteVisitEmail: toAddresses---'+toAddresses);

    //     // Email Id of the Applicants contact 
    //   //  if(siteVisit != null && siteVisit.SubAwardee__c != null && siteVisit.SubAwardee__r.Email != null){
    //       if(siteVisit != null && siteVisit.SubAwardee__c != null ){
    //         if(!String.isEmpty(siteVisit.NotificationTemplate__c)){
    //             notificationTemplate = siteVisit.NotificationTemplate__c;
    //             //emailTemplate = [select Id,Name,Subject,body from EmailTemplate where name  like :notificationTemplate];
    //         }
    //         targetUserId = siteVisit.SubAwardee__c;
    //     }
    //     else if(String.isEmpty(notificationTemplate)){
    //         notificationTemplate = GNT.KeyValueStoreHelper.getTextValue('GranteeSiteVisitNotifyEmailTemplate__c', true);
    //         //emailTemplate = [select Id,Name,Subject,body from EmailTemplate where name  like :notificationTemplate]; 
    //     }
     
        
    //            // system.debug('siteVisitEmail: '+siteVisit.SubAwardee__r.Email);
    //           //  toAddresses.add(siteVisit.SubAwardee__r.Email); 
    //             //Shah CRF: Following SOQL could be moved to utility method to keep code clean
    //             emailTemplate = [Select id From EmailTemplate Where DeveloperName = 'GranteeSiteVisitNotifyEmailTemplate' Limit 1];
    //             Contact cont = [select id, Email from Contact where email <> null limit 1];  //Shah CRF: This SOQL could fail as it selects non specific record
    //             try {
    //                 /*List<SiteVisitPerson__c> siteVisitPersonsList = [Select Id,FirstName__c,LastName__c,SiteVisit__r.Grant__r.ExternalOrganization__r.Name,Email__c FROM SiteVisitPerson__c where SiteVisit__c =: siteVisit.Id];
                    
    //                 String svpName = '';
    //                 if(!siteVisitPersonsList.isEmpty()) {
    //                     if(siteVisitPersonsList.size() > 0) {
    //                         for(SiteVisitPerson__c svp : siteVisitPersonsList) {
    //                             svpName += svp.LastName__c+', '+svp.FirstName__c+' - '+ svp.SiteVisit__r.Grant__r.ExternalOrganization__r.Name +'\n';
    //                             if(svp.Email__c != null || svp.Email__c != '') {
    //                                 toAddresses.add(svp.Email__c);
    //                             }
                                
    //                         }
    //                     }
    //                 }
    //                 siteVisit.SiteVisitPersons__c = svpName;
    //                 update siteVisit; */
    //                 Map<Id, String[]> recIdToAddressMap = new Map<Id, String[]> ();
    //                 recIdToAddressMap.put(siteVisit.Id, toAddresses); 
    //              AppUtils.sendEmailUsingTemplate(emailTemplate[0].Id, recIdToAddressMap, cont.Id, false);//   
    //             }
    //             catch(Exception e) {
    //                 system.debug('Error in email notitication--'+e);
    //                 return 'Email was not sent';
    //             }
                
    //            //}
            return '';
        }
       
    }