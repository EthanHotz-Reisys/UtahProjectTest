public with sharing class ApproveRejectAwardAllocationChangeCtrl {

    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}

    
    public ApproveRejectAwardAllocationChangeCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'ApproveRejectAwardAllocationChange';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('awardId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('parentid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('recordId', ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);
    }
    
    public PageReference redirectToAward() {
        Award__c currentAward = [SELECT Id, BudgetRevisionInitiatedByUSBE__c, AllocationMatchUpdatedAllocation__c FROM Award__c WHERE Id =: recordId]; 
        if (currentAward.BudgetRevisionInitiatedByUSBE__c == 'Allocation Change' || currentAward.AllocationMatchUpdatedAllocation__c == false) { //Budget revision for allocation change has started     
            PageReference awardPage =  Page.AwardView;
            awardPage.setRedirect(true);
            awardPage.getParameters().put('id', ApexPages.CurrentPage().getParameters().get('id'));
            return awardPage; //You can't waive/accept an allocation change if there is already an active allocation change budget revision for your award, so redirect to the award page
        }
        return null;
    }
}