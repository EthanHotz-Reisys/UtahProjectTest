public without sharing class SendApplicationRejectionCtrl implements GNT.InvokeEmailActionInterface {

    public Id recordId {
        get;
        set;
    }
    public String email {
        get;
        set;
    }
    public String emailTemplateName {
        get;
        set;
    }
    public Id targetId {
        get;
        set;
    }
    public Id appId {
        get;
        set;
    }


    public SendApplicationRejectionCtrl() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        fetchEmailCtrlData(recordId);
    }

    public void fetchEmailCtrlData(Id recordId) {
        ReviewStepApplication__c rejectRSApp = [SELECT Id, Application__c,Comments__c FROM ReviewStepApplication__c WHERE Id =: recordId];
        Application__c rejectApp = [SELECT Id, OwnerId, Owner.Email,ReviewStepAppRejectioncomments__c FROM Application__c WHERE Id =: rejectRSApp.Application__c];
        //rejectApp.ReviewStepAppRejectioncomments__c = rejectRSApp.Comments__c;
        //ApplicationTriggerHelper.SkipTrigger = True;
        //update rejectApp;
        email = rejectApp.Owner.Email;
        targetId = rejectApp.OwnerId;
        appId = rejectApp.Id;
    }

    public SendApplicationRejectionCtrl getThis() {
        return this;
    }

    public String actionToInvokeBefore() {
        String soql = 'SELECT Id, RejectedApplicantNotified__c FROM ReviewStepApplication__c WHERE Id =: recordId';
        ReviewStepApplication__c rsa = Database.query(soql);
        rsa.RejectedApplicantNotified__c = true;
        ReviewStepApplication__c rejectRSApp = [SELECT Id, Application__c,Comments__c FROM ReviewStepApplication__c WHERE Id =: recordId];
        Application__c rejectApp = [SELECT Id, OwnerId, Owner.Email,ReviewStepAppRejectioncomments__c FROM Application__c WHERE Id =: rejectRSApp.Application__c];
        rejectApp.ReviewStepAppRejectioncomments__c = rejectRSApp.Comments__c;
        ApplicationTriggerHelper.SkipTrigger = True;
        update rejectApp;
        System.debug('rsa'+rsa);
        try{
          update rsa;
          return 'success';
        }catch(Exception e){
          return 'error';
        }
    }
    public String actionToInvokeAfter() {
        String soql = 'SELECT Id, RejectedApplicantNotified__c FROM ReviewStepApplication__c WHERE Id =: recordId';
        ReviewStepApplication__c rsa = Database.query(soql);
        rsa.RejectedApplicantNotified__c = true;
        System.debug('rsa'+rsa);
        try{
          update rsa;
          return 'success';
        }catch(Exception e){
          return 'error';
        }

    }

}