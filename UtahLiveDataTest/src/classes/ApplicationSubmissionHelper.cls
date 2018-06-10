global with sharing class ApplicationSubmissionHelper extends GNT.DynamicLayoutActionRedirect {

  global override PageReference whenClicked() {
    Savepoint sp = Database.setSavePoint();
    Boolean HideSubmit = true;
    Boolean isError = false;
    Decimal match;
    Integer appCount, maxAppCount;
    try {
      Id recordId = layoutHolder.getPrimarySObject().Id;
      //List<Attachment> attachment = [SELECT Id, Name FROM Attachment WHERE ParentId = :recordId];
      Application__c app = [Select Id, Name, ProposalDescription__c, Approver__c, IndirectCostPicklist__c,IndirectCostPercentage__c, Announcement__r.Program__c, Announcement__r.AttachmentsRequired__c, Announcement__r.OrganizationName__c, Announcement__r.Program__r.AttachmentsRequired__c, TotalFederalMatch__c, Announcement__r.GranteeMatch__c, Announcement__r.MatchRequired__c, TotalCashMatch__c, TotalInKindMatch__c, TotalGrantCost__c , PrimaryApplicant__r.Id, Status__c, Announcement__r.DaysLeft__c, Announcement__r.Name , ExternalOrganization__c, ExternalOrganization__r.ApplicantType__c, Announcement__c, FormsValidated__c, Announcement__r.MaxApplicationsAllowed__c, Announcement__r.ApplicationsReviewStatus__c, NumberOfReviews__c, InitialRequestedAmount__c, RequestedAmount__c, AwardCeiling__c, AwardFloor__c, ProgramBudgetTypeUSBE__c, GrantorOrganizationName__c  from Application__c where id = :recordId Limit 1];
      Announcement__c announcementObj = [Select Program__c, ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c from Announcement__c where Id = :app.Announcement__c limit 1];
      SystemContextMethodsHelper sysCnt = new SystemContextMethodsHelper();
      List<Program__c> prog = sysCnt.getProgramIds(announcementObj.Program__c);
      //Program__c program = sysCnt.getProgramfields(prog);
      System.debug('SAI LOOK HERE ================>' + prog);
      DateTime d = DateTime.newInstance(announcementObj.ApplicationDeadlineWithDateTime__c.year(), announcementObj.ApplicationDeadlineWithDateTime__c.month(), announcementObj.ApplicationDeadlineWithDateTime__c.day(), announcementObj.ApplicationDeadlineWithDateTime__c.hour(), announcementObj.ApplicationDeadlineWithDateTime__c.minute(), announcementObj.ApplicationDeadlineWithDateTime__c.second());
      User u = [Select AccountId, Contact.Account.IsExtensionAllowed__c from User where Id = :UserInfo.getUserId()];

      if (app.ProposalDescription__c == null && app.Announcement__r.OrganizationName__c == 'USBE') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill out the description field of the application before submitting'));
        isError = true;
      }


      if (u.Contact.Account.IsExtensionAllowed__c == true && announcementObj.TimeExtensionAllowed__c == true) {
      if (d + Integer.valueOf(announcementObj.ExtensionDays__c ) > DateTime.parse(System.now().format())) {
          HideSubmit = false;
        }
      } else {
        if (d > DateTime.parse(System.now().format())) {
          HideSubmit = false;
        }
      }
      if (app.TotalGrantCost__c == 0) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input the application budget in the Budget Tab '));
        isError = true;
      } else {
        match = (app.TotalCashMatch__c + app.TotalInKindMatch__c) / app.TotalGrantCost__c * 100;
      }
      //*************************************LEON CODE

      /*
      if (prog[0].ProgramPathway__c == 'Fed-Formula' && app.Announcement__r.OrganizationName__c.equalsIgnoreCase('USBE') ) {
        Id account = u.AccountId;
        List<GNT__AttachmentExtension__c> attachements = [SELECT id, GNT__Classification__c FROM GNT__AttachmentExtension__c where GNT__ParentId__c = :account];
        Integer currentYear = System.Today().year();
        Integer count = 0;
        String a = String.ValueOf(currentYear);
        for (GNT__AttachmentExtension__c b : attachements) {
          if (b.GNT__Classification__c != a) {
            continue;
          } else {
            count++;
          }

        }

        if (count == 0) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot submit the Application as there is no Federal Assurance Form uploaded for the current year. Please refer to the hyperlink displayed in the attachements tab of your organization profile to download the form and attach a single copy'));
          return null;

        } else if (count > 1) {

          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot submit the Application as there are multiple Federal Assurance Forms uploaded for the current year. Please refer to the attachements tab of your organization profile and ensure only a single form is present for the current year'));
          return null;
        }

      }
      */


      //**********************************************************LEON CODE


      //if ( app.Announcement__r.OrganizationName__c.equalsIgnoreCase('USBE')){
      String attachmentTypes;
      if ( app.Announcement__r.OrganizationName__c.equalsIgnoreCase('USBE')) {
      attachmentTypes = app.Announcement__r.Program__r.AttachmentsRequired__c;
    } else {
      attachmentTypes = app.Announcement__r.AttachmentsRequired__c;
    }
    Id progId = app.Announcement__r.Program__r.id;
    if (attachmentTypes != null && !String.isEmpty(attachmentTypes)) {
      String[] attachmentTypesList = attachmentTypes.split('\\;');
        Integer countOfFiles = 0;
        Map<String, Integer> attCount = new Map<String, Integer>();
        for (Integer i = 0; i < attachmentTypesList.size(); i++) {
          String s = attachmentTypesList[i].trim().tolowercase();
          attachmentTypesList[i] = s;
          attCount.put(s, 0);
        }
        //for(String att1 : attachmentTypesList)
        //  attCount.put(att1,0);
        System.debug('count1: ' + attCount);
        List<GNT__AttachmentExtension__c> list1 = [Select GNT__Classification__c FROM GNT__AttachmentExtension__c where GNT__ParentId__c = :recordId];
        String s1; Integer c = 0;
        for (GNT__AttachmentExtension__c AttchExt : list1) {
          System.debug('Test count' + AttchExt.GNT__Classification__c);
          s1 = (String.valueOf(AttchExt.GNT__Classification__c)).trim().tolowercase();
          System.debug('Count2 ' + s1 + ' ' + s1.equalsIgnoreCase('State form'));
          if (attCount.containsKey(s1)) {
            System.debug('Count2 ' + s1 );
            countOfFiles = 1 + attCount.get(s1);
            attCount.put(s1, countOfFiles);
          }
        }
        System.debug('Map count:' + attCount);
        for (String att2 : attachmentTypesList) {
          countOfFiles = attCount.get(att2);
          System.debug('Count3 ' + att2 + ' ' + countOfFiles);
          if ((countOfFiles == 0 || countOfFiles == null)  && !att2.equalsIgnoreCase('other') ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-56212') + ' ' + att2 + '.'));
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Under the  attachments tab, attach atleast one, but not more than one file of type ' +att2));
            isError = true;

          }
        }
      }
      //}


      if (HideSubmit) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21359')));
        isError = true;
      }

      if (app.IndirectCostPicklist__c == null) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select Indirect Cost \'Yes\' or \'No\' in the Overview Tab'));
        isError = true;
      }
      
      if (app.IndirectCostPicklist__c == 'Yes' && (app.IndirectCostPercentage__c == null || app.IndirectCostPercentage__c == 0)) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the Indirect Cost Percentage.'));
        isError = true;
      }

      //if(app.Status__c=='Revision Initiated'){
      //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-83111')));
      //  isError = true;
      //}
      if (app.Status__c == 'Submitted to Grantor') {
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application is already submitted to Grantor'));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-47065')));
        isError = true;
      }
      if (match != null && app.Announcement__r.MatchRequired__c == true && match.setScale(2) < app.Announcement__r.GranteeMatch__c && app.ExternalOrganization__r.ApplicantType__c != 'Non Profit Victim Services') {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please make sure that the value of ((Total Cash Match+Total In-Kind Match)*100/Grant including indirect cost) is greater than ' + app.Announcement__r.GranteeMatch__c + '%. The present cash match percentage is ' + match.setScale(2) + '%.'));
        isError = true;
      }
      if (app.Announcement__r.DaysLeft__c < 0) {
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application can not be submitted after the Due date.'));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21359')));
        isError = true;
      }
      //if(app.GrantorOrganizationName__c != 'USBE' && app.Status__c!='Internally Reviewed'){
      //  // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Atleast one Peer Review must be Completed'));
      //  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-70037')));
      //  isError = true;
      //}
      if (!app.FormsValidated__c) {
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Forms needs to be validated before the application can be submitted.'));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61201')));
        isError = true;
      }
      if (app.TotalFederalMatch__c > app.AwardCeiling__c) {
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested Amount can not be greater than Award Ceiling Amount'));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-65227')));
        isError = true;
      }
      //if(app.RequestedAmount__c<app.AwardFloor__c){
      //   // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested Amount can not be less than Award Floor Amount'));
      //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33051')));
      //   isError = true;
      //}

      //   if(app.NumberOfReviews__c<1)    {
      //     // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'One Review is required for application to be submitted.'));
      //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-01106')));
      //  /*   PageReference pf = Page.ApplicationView;
      //     pf.getParameters().put('id', app.Id);
      //     pf.setRedirect(true);
      //*/
      //     isError = true;
      //   }

      List<Application__c> appList = [Select Id, Name from Application__c where Announcement__c = :app.Announcement__c and ExternalOrganization__c = :app.ExternalOrganization__c and Status__c NOT IN ('Created', 'Internally Reviewed')];
      if (appList != null &&  appList.size() > 0) {
      appCount = appList.size();
      } else {
        appCount = 0;
      }
      if (app.Announcement__r.MaxApplicationsAllowed__c != null && app.Announcement__r.MaxApplicationsAllowed__c > 0) {
      maxAppCount = (Integer)app.Announcement__r.MaxApplicationsAllowed__c;
      } else {
        maxAppCount = 1;
      }
      if (maxAppCount <= appCount) {
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application can not be submitted to Grantor as you have reached the maximum limit for allowed applications for '+app.Announcement__r.Name));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-55052') + ' ' + app.Announcement__r.Name));
        isError = true;
      }

      if (isError == false) {
      app.Status__c = 'Submitted to Grantor';
      app.SubmittedOn__c = System.Now();
        app.InitialRequestedAmount__c = app.RequestedAmount__c;
        app.SubmittedBy__c = UserInfo.getUserId();
        update app;
        List<Task> taskList = [Select Id, Status, WhatId from Task where
                               WhatId = :app.Id AND OwnerId = :app.PrimaryApplicant__r.Id AND Status = 'In Progress'];
        if (taskList != null && taskList.size() > 0) {

          for (Task task : taskList) {
            task.Status = 'Completed';
          }
          update taskList;
        }
        /*
        if (app.Announcement__r.ApplicationsReviewStatus__c != 'Not Started' && app.Announcement__r.ApplicationsReviewStatus__c != 'Ready for Review') {
          SystemContextMethodsHelper helper = new SystemContextMethodsHelper();
          helper.insertSingleApplicationToReview(app);
        }
        */
        //TaskCreationHandler.createApprovalProcessTasks(app.Id, 'Review Application Request', app.Name, null, System.TODAY() + 7,  true);
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Application has been successfully submitted.'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-81305')));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-49018')));
        PageReference pf = Page.ApplicationView;
        pf.getParameters().put('id', app.Id);
        pf.setRedirect(true);
        return pf;
      } else {
        return null;
      }
    } catch (Exception ex) {
      Database.rollback(sp);
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage()));
      return null;
    }
  }
}