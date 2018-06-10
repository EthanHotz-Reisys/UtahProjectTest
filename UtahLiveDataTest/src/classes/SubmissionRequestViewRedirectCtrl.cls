public without sharing class SubmissionRequestViewRedirectCtrl{

    public PageReference redirect(){
        ChangeRequest__c changeReq;        
        String recordId = ApexPages.CurrentPage().getParameters().get('id');        
        if(recordId !=null){
            List<ChangeRequest__c> changeReqList = [Select Id, Name, Application__c, Status__c,Application__r.ProjectOfficer__r.Id, 
                                                        Application__r.DataEvaluator__r.Id, Application__r.GrantMonitor__r.Id from ChangeRequest__c where 
                                                                id = :recordId Limit 1];       
            system.debug('application Project Officer Id is'+changeReqList[0].Application__r.ProjectOfficer__r.Id);                                             
            if(changeReqList.size() > 0 && (UserInfo.getUserId()== changeReqList[0].Application__r.ProjectOfficer__r.Id || 
                                            UserInfo.getUserId()== changeReqList[0].Application__r.GrantMonitor__r.Id ||
                                            UserInfo.getUserId()== changeReqList[0].Application__r.DataEvaluator__r.Id ) 
                                            && changeReqList[0].Status__c == 'Submitted By Applicant'){
                changeReq = changeReqList[0];
                changeReq.Status__c='Review in Progress';
                update changeReq;
                
            } else if (changeReqList.size() > 0 && changeReqList[0].Status__c == 'Initiated'){
                changeReq = changeReqList[0];
                changeReq.Status__c='In Progress';
                update changeReq;
            }
                                                            
        }
       
        return   new PageReference('/apex/'+AppUtils.getNamespacePrefix()+'SubmissionRequestView?id='+recordId);
    }

}