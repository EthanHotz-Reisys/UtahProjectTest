global with sharing class RejectInvitedExternalReviewerCtrl extends GNT.FlexTableActionHandler {
    public List<Id> selectedIds {get;set;}
    //public List<UserInvitation__c> userInvitesList;
    //public List<UserInvitation__c> userInvitesListToBeRejected;
    
    public RejectInvitedExternalReviewerCtrl(){
        selectedIds = selectedRecordIds;
    }
    
    global override Map<String,Object> clickhandler(){
        Map<String,Object> resultMap = new Map<String,Object>();
        /* userInvitesList = new List<UserInvitation__c>();
        userInvitesListToBeRejected = new List<UserInvitation__c>();
        userInvitesList = [SELECT Id,Name,Status__c FROM UserInvitation__c WHERE Id IN :selectedRecordIds];
        if(userInvitesList.size() > 0){
            for(UserInvitation__c invite : userInvitesList){
                invite.Status__c = 'Canceled';
                userInvitesListToBeRejected.add(invite);
            }
            if(userInvitesListToBeRejected.size() > 0){
                update userInvitesListToBeRejected;
            } 
        }
         resultMap.put('Message','Invitation canceled successfully'); */
         return resultMap; 
    } 
}