global with sharing class ReSendInvitationHelper extends GNT.FlexTableActionHandler{
     
     global override Map<String,Object> clickHandler(){
     	Map<String,Object> resultMap = new Map<String,Object>();
        System.debug('++ selected ids ' + selectedRecordIds); 
        List<String> recordIds;
        recordIds = GNT.RecordIdStorageHelper.getRecordIds('SelectedUserInvitations'); 
        /* List<UserInvitation__c> userInvitedList = [Select id,Name,InviteeEmail__c, Status__c from 
                                                  UserInvitation__c where Id IN :selectedRecordIds ];
        for(UserInvitation__c userinvited : userInvitedList){
            userinvited.Status__c = 'Invited';
            userInvited.SecurityToken__c = GNT.AppUtils.generateToken(32);            
        } 
        update userInvitedList;  */     
        //resultMap.put('Message','Invitation sent successfully');                                         
        resultMap.put('Message',GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-69683')); 
        return resultMap;
     } 
     
}