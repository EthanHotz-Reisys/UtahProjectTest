public with sharing class CaseViewCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public String recordType {get;set;}
    public String isCloseFlag;
    public transient String previousTabName {get; set;}
    
    public CaseViewCtrl(ApexPages.StandardController stdController) {
		recordId = ApexPages.CurrentPage().getParameters().get('id');  
		ApexPages.CurrentPage().getParameters().put('myrecid',recordId);
		isCloseFlag = ApexPages.CurrentPage().getParameters().get('isClose'); 
        if(isCloseFlag!=null && isCloseFlag.equalsIgnoreCase('true'))
            closeIssue();
            
        GNT.AppUtils.setTabCookie();  
        previousTabName = GNT.AppUtils.getSelectedTabName(); 
    }
    
    public string getKeyValueMap() {
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));      
        return JSON.serialize(keyValueMap);
    }
    
    public Pagereference closeIssue() {
        //Shah 4/28/2017 Commenting out since we should not be using native Case object
        /*
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        Case caseDetails = [Select ID from Case where id =:recordId];
        caseDetails.Status='Closed';
        caseDetails.Detailed_Comments__c='Closed by the Requester';
        Update caseDetails;
        */
        return new Pagereference('apex/GNT__FlexTableNewView?ft1=CaseDetails');

    }
}