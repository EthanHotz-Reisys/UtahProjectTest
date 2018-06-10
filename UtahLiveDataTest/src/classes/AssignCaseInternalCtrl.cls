global with sharing class AssignCaseInternalCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
        String recordId = ApexPages.CurrentPage().getParameters().get('id');
        Pagereference pg = null;        
        //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
   
        if(UserProfile!=null && UserProfile.size()>0){
        String profileId = UserProfile[0].Id;     
        Map<String, SObject> recordMp= layoutHolder.recordMap;        
        Case caseObj=(Case) recordMp.get('Case');            
        String newOwnerId = caseObj.OwnerId;            
        system.debug('whenClicked   '+newOwnerId);
            
        List<GroupMember> gmList=  [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId =: newOwnerId AND Group.Type = 'Queue' AND Group.Name = 'GovGrants_Helpdesk_Tier2'];
            system.debug('whenClicked   gmList   '+gmList);
            if(gmList!=null && gmList.size()>0){
                // valid assignment        
             caseObj.Status='In Progress';
             Update caseObj;
            pg =  new Pagereference('/apex/CasesMaster');
            pg.setRedirect(false);
            }
            else{
                 // invalid assignment              
                //ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Invalid Case Assignment, you can only assign to a user in your group.' );
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-41136') );
                ApexPages.addmessage(msg);
             }
          }                    
        return pg;
    }
}