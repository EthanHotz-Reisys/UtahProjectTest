public with sharing class ApplicantSRComments {


    public String comments{get;set;}
    public string namespace {get;set;}
    public List<ChangeRequest__c> changeReqList ;
    public ChangeRequest__c changeReq;
    public Id crId;
    public Id appId;
    public String page{get;set;}
    
    public ApplicantSRComments() {
        namespace = AppUtils.getNamespacePrefix();
        crId = ApexPages.currentPage().getParameters().get('id');
        changeReqList = [Select Id, Application__r.Id, ApplicantComments__c from ChangeRequest__c where id=:crId Limit 1];
        changeReq = changeReqList[0];
        appId = changeReq.Application__r.Id;
    }

    public PageReference save(){
        
        changeReq.ApplicantComments__c = comments;
        update changeReq;
        page='/apex/'+namespace+'ApplicationView?id='+appId;
        return null;
        //return new PageReference('/apex/'+namespace+'ApplicationView?id='+appId);
    } 

}