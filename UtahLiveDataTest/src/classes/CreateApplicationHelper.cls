global with sharing class CreateApplicationHelper extends GNT.DynamicLayoutActionRedirect {

  Id announcementId;

  global override PageReference whenClicked() {


    Id recordId = layoutHolder.getPrimarySObject().Id;
    //  String hostVal  = ApexPages.currentPage().getHeaders().get('Host');
    //  System.debug('hostVal  ' +hostVal  );
    //  String urlvalue = Apexpages.currentPage().getUrl();
    // System.debug('urlvalue1' +urlvalue);
    String ns = AppUtils.getNamespacePrefix();
    //Id applicationId = apexpages.currentpage().getparameters().get('id');
    Integer appCount, maxAppCount;
    System.debug('The record Id is ' + recordId);
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    User u = [select AccountId, GNT__OrganizationId__c, Contact.Account.IsExtensionAllowed__c from User where id = :Userinfo.getUserId()];
    if (appName == 'Recipient') {
      announcementId = apexpages.currentpage().getparameters().get('announcementid');
      //*************************Leons code

      Announcement__c announcementObj = [Select Program__c from Announcement__c where Id = :announcementId limit 1];
      //Id programId=announcementObj.Program__c;
      //System.debug('*****************PROGID'+programId);
      //List<Program__c> program=new List<Program__c>();
      SystemContextMethodsHelper sysCnt = new SystemContextMethodsHelper();
      List<Program__c> program = sysCnt.getProgramIds(announcementObj.Program__c);
      //List<Program__c> program= [Select id from Program__c where id =:announcementObj.Program__c LIMIT 1];
      Program__c prog = sysCnt.getProgramfields(program);
      //Program__c prog=[Select FunderType__c,OrganizationName__c from Program__c where id IN:program LIMIT 1];
      Id account = u.AccountId;
      //system.debug('account id is ' +account);
      
      /*
      System.debug('program has organization name ' + prog.OrganizationName__c );
      if ( (prog.OrganizationName__c == 'USBE')) {
        if (prog.FunderType__c == 'Federal') {
          checkFederalAssurances(account);

        }

        else if (prog.FunderType__c == 'State') {
          checkStateAssurances(account);
        }
      }

      */

      //*********************************Leons code
    }

    else if (appName == 'StateasGrantee') {
      announcementId = apexpages.currentpage().getparameters().get('id');
    }
    Boolean HideSubmit = true;
    Announcement__c announcementObj = [Select Program__c, RFARequired__c, Status__c, ApplicationDeadlineWithDateTime__c, ExtensionDays__c, TimeExtensionAllowed__c from Announcement__c where Id = :announcementId limit 1];

    DateTime d = DateTime.newInstance(announcementObj.ApplicationDeadlineWithDateTime__c.year(), announcementObj.ApplicationDeadlineWithDateTime__c.month(), announcementObj.ApplicationDeadlineWithDateTime__c.day(), announcementObj.ApplicationDeadlineWithDateTime__c.hour(), announcementObj.ApplicationDeadlineWithDateTime__c.minute(), announcementObj.ApplicationDeadlineWithDateTime__c.second());
    if (u.Contact.Account.IsExtensionAllowed__c == true && announcementObj.TimeExtensionAllowed__c == true) {
      if (d + Integer.valueOf(announcementObj.ExtensionDays__c ) > DateTime.parse(System.now().format())) {
        HideSubmit = false;
      }
    } else {
      if (d > DateTime.parse(System.now().format())) {
        HideSubmit = false;
      }
    }

    if (HideSubmit) {
      // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application cannot be created after deadline'));
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31596')));
      return null;
    }

    if (announcementObj.RFARequired__c == True) {
      if (announcementObj.Status__c != 'RFA Published') {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create an Application without the publication of RFA'));
        return null;
      }
    }

    if (appName == 'Recipient') {
      OpportunityQualification__c qualifiedAnnouncement = [Select Id, FundingOpportunity__r.Name, FundingOpportunity__c, FundingOpportunity__r.MaxApplicationsAllowed__c, ApplicationCreated__c, PreApplicationCreated__c, IsPreapplicationSubmitted__c , IsPreApplicationRequired__c, FundingOpportunity__r.AllowMultipleApplicationsFromOrg__c from OpportunityQualification__c where id = :recordId limit 1];
      if (qualifiedAnnouncement.IsPreApplicationRequired__c == true && qualifiedAnnouncement.IsPreapplicationSubmitted__c == false) {
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pre-Application needs to be submitted before creating an application'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-46251')));
        return null;
      }
      GNT__UserPreferences__c userPrefs = GNT__UserPreferences__c.getValues(UserInfo.getUserId());
      List<Application__c> appList = [Select Id, Name from Application__c where Announcement__c = :qualifiedAnnouncement.FundingOpportunity__c and ExternalOrganization__c = :userPrefs.GNT__OrganizationAccountId__c];
      if (appList != null &&  appList.size() > 0) {
        appCount = appList.size();
      } else {
        appCount = 0;
      }
      if (qualifiedAnnouncement.FundingOpportunity__r.MaxApplicationsAllowed__c != null && qualifiedAnnouncement.FundingOpportunity__r.MaxApplicationsAllowed__c > 0) {
        maxAppCount = (Integer)qualifiedAnnouncement.FundingOpportunity__r.MaxApplicationsAllowed__c;
      } else {
        maxAppCount = 1;
      }

      if (maxAppCount <= appCount) {
        // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Application cannot be created as you have reached the maximum limit for allowed applications for '+qualifiedAnnouncement.FundingOpportunity__r.Name));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-74572') + ' ' + qualifiedAnnouncement.FundingOpportunity__r.Name));
        return null;
      }
      if ((qualifiedAnnouncement.FundingOpportunity__r.AllowMultipleApplicationsFromOrg__c == true) || (qualifiedAnnouncement.FundingOpportunity__r.AllowMultipleApplicationsFromOrg__c == false && qualifiedAnnouncement.ApplicationCreated__c == false)) {
        String hostval =  EncodingUtil.urlEncode('/apex/QualifiedOpportunityView?announcementid=' + qualifiedAnnouncement.FundingOpportunity__c + '&id=' + qualifiedAnnouncement.Id, 'UTF-8');

        /* qualifiedAnnouncement.ApplicationCreated__c =true;
         qualifiedAnnouncement.OpportunityStatus__c='Converted to Application';
         update qualifiedAnnouncement; */
        return new PageReference('/apex/' + ns + 'ApplicationEdit?announcementId=' + qualifiedAnnouncement.FundingOpportunity__c + '&retURL=' + hostVal);
      } else {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-70031')));
        return null;
      }
    }
    if (appName == 'StateasGrantee') {
      List<Application__c> applicationList = [SELECT Id, Status__c FROM Application__c WHERE Announcement__c = : recordId AND CreatedBy.GNT__OrganizationId__c = :u.GNT__OrganizationId__c ]; //CreatedById =: Userinfo.getUserId()];
      if (applicationList.size() == 0) {
        return new PageReference('/apex/' + ns + 'ApplicationEdit?announcementId=' + recordId + '&t=GranteeApplication' );
      }
      //List<Application__c> applst = [SELECT Id,Status__c FROM Application__c WHERE Id =: applicationId AND CreatedBy.GNT__OrganizationId__c =:u.GNT__OrganizationId__c ];
      //if(applst.size()>0){
      //    if(applst[0].Status__c =='Approved'){
      //        applst[0].Status__c ='Submitted to Grantor';
      //        update applst[0];
      //    }
      //    if(applst[0].Status__c =='Submitted to Grantor'){
      //        applst[0].Status__c ='Accepted';
      //        update applst[0];
      //    }
      //     PageReference page = new PageReference('/apex/'+ns+'ApplicationView?id=' + applst[0].id);
      //     page.setRedirect(true);
      //     return page;
      //}
    }
    return null;
  }

  private void checkFederalAssurances(Id account) {
    List<GNT__AttachmentExtension__c> attachements = [SELECT id, GNT__Classification__c, Year__c FROM GNT__AttachmentExtension__c where GNT__ParentId__c = :account];
    Integer currentYear = System.Today().year();
    Integer count = 0;
    String a = String.ValueOf(currentYear);
    for (GNT__AttachmentExtension__c b : attachements) {
      if (b.Year__c != a && b.GNT__Classification__c != 'Federal Assurance') {
        continue;
      } else {
        count++;
      }

    }

    if (count != 1) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create an Application as there needs to be exactly one Federal Assurance Form uploaded for the current year. Please refer to the hyperlink displayed in the attachements tab of your organization profile to download the form and attach a single copy'));

    }

  }

  private void checkStateAssurances(Id account) {
    List<GNT__AttachmentExtension__c> attachements = [SELECT id, GNT__Classification__c, Year__c FROM GNT__AttachmentExtension__c where GNT__ParentId__c = :account];
    Integer currentYear = System.Today().year();
    Integer count = 0;
    String a = String.ValueOf(currentYear);
    for (GNT__AttachmentExtension__c b : attachements) {
      if (b.Year__c != a && b.GNT__Classification__c != 'State Assurance') {
        continue;
      } else {
        count++;
      }

    }

    if (count != 1) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create an Application as there needs to be exactly one State Assurance Form uploaded for the current year. Please refer to the hyperlink displayed in the attachements tab of your organization profile to download the form and attach a single copy'));

    }

  }

}