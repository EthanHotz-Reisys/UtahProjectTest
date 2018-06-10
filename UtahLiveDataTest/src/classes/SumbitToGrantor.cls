global with sharing class SumbitToGrantor extends GNT.DynamicLayoutActionRedirect{
    public SumbitToGrantor() {
         
    }

    global override PageReference whenClicked(){      
        String ns = AppUtils.getNamespacePrefix(); 
        Id recordId = apexpages.currentpage().getparameters().get('id');
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        
        Preapplication__c preapp = [SELECT Id,Status__c,Announcement__c,GranteeRequestedAmount__c,AwardCeiling__c,AwardFloor__c,RequestedAmount__c,FormsValidated__c,SubmittedOn__c,SubmittedBy__c FROM Preapplication__c WHERE id =: recordId];
        if(preapp.GranteeRequestedAmount__c>preapp.AwardCeiling__c){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested Amount can not be more than Award Ceiling Amount')); 
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-65227')));         
         return null; 
        }
        else if(preapp.GranteeRequestedAmount__c < preapp.AwardFloor__c){
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested Amount can not be less than Award Floor Amount'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-33051')));         
         return null;
        }
        
        if(!preapp.FormsValidated__c){
         //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Forms have not been validated, please click on Validate Button for Forms')); 
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-82460')));         
         return null;
        }
        preapp.Status__c = 'Submitted to Grantor';
        preapp.SubmittedOn__c=System.Today();
        preapp.SubmittedBy__c=UserInfo.getUserId();
        update preapp; 
        
        if(appName == 'StateasGrantor'){
            List<OpportunityQualification__c> qualifiedAnnouncementList = [Select Id, FundingOpportunity__c,PreApplicationCreated__c 
            from OpportunityQualification__c where FundingOpportunity__c=:preapp.Announcement__c limit 1];
            qualifiedAnnouncementList[0].IsPreapplicationSubmitted__c=true;
            update qualifiedAnnouncementList[0];
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Submitted to Grantor'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-02689')));         
         PageReference  returnPage = new PageReference('/apex/PreapplicationView?id='+preapp.id);
         returnPage.setRedirect(true);
         return returnPage;
             
    }  
}