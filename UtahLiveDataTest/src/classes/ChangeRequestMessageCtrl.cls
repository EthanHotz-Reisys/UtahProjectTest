global with sharing class ChangeRequestMessageCtrl {
    
    public String userId {get; set;}
    public ChangeRequestMessageCtrl() {
        userId = UserInfo.getUserId();
    }
    
    @RemoteAction
    global static List<String> getMessage(String recordId) {
        List<String> result = new List<String>();
        List<ChangeRequest__c> requests = [SELECT id, CreatedBy.Name,RecordCreatedBy__c,CreatedDate,
                                           comments__c, ApplicationSections__c, Application__r.ProjectOfficer__c, 
                                           Application__r.GrantMonitor__c, Application__r.DataEvaluator__c, 
                                           Application__r.OwnerId FROM ChangeRequest__c WHERE Application__r.ChangeRequestStatus__c in('Change Request Assigned','Change Request Completed','Change Request Accepted') AND Application__c =: recordId
                        order by createdDate Desc];
        String tmpString;

        if (requests.size() > 0 ) {
            if(UserInfo.getUserId() == requests[0].Application__r.ProjectOfficer__c || UserInfo.getUserId() == requests[0].Application__r.GrantMonitor__c|| UserInfo.getUserId() == requests[0].Application__r.DataEvaluator__c || UserInfo.getUserId() == requests[0].Application__r.OwnerId){
                tmpString = requests[0].ApplicationSections__c;
                result.add(requests[0].RecordCreatedBy__c +' on '+requests[0].CreatedDate.format());
               
                result.add(tmpString);
            result.add(requests[0].comments__c);
            return result;
        }        
        }        
        return result;
    }
    // deprecated
    //hence commenting the method.
    @RemoteAction
    global static String approveRequest(String requestId) {
        
        return 'Unable to find request.';
    }
    // deprecated
    //hence commenting the method.
    @RemoteAction
    global static String disapproveRequest(String requestId) {
       
        return 'Unabled to find request.';
    }
}