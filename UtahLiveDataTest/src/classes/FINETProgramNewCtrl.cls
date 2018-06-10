public with sharing class FINETProgramNewCtrl {
    
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
   
    public FINETProgramNewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'FINETProgramNew';
       savePage = Page.FINETProgramView;
       // System.debug('LEON TEST=============>'+savePage.getParameters());
       ////recordId = ApexPages.CurrentPage().getParameters().get('id');
       savePage.getParameters().put('id', recordId);
       System.debug('LEON TEST2=============>');
       System.debug('recordidis '+recordId);
       System.debug('finetrecordid '+recordId);

        
        
        
        
    }

    //public static PageReference redirectToAward() {
    //    ID recordId = ApexPages.CurrentPage().getParameters().get('id');
    //    System.debug('ActionClassId '+recordId);
    //    //r_prog__c finetProgram = [SELECT Id, BudgetRevisionInitiatedByUSBE__c, AllocationMatchUpdatedAllocation__c FROM Award__c WHERE Id =: recordId]; 
    //    //if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' || currentAward.AllocationMatchUpdatedAllocation__c == false) { //Budget revision for allocation change has started     
    //    //    PageReference awardPage =  Page.AwardView;
    //    //    awardPage.setRedirect(true);
    //    //    awardPage.getParameters().put('id', ApexPages.CurrentPage().getParameters().get('id'));
    //    //    return awardPage; //You can't waive/accept an allocation change if there is already an active allocation change budget revision for your award, so redirect to the award page
    //    //}
    //    if (recordId!=null)
    //    return null;
    //    return null;
    //}

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        return JSON.serialize(keyValueMap);
    }
}