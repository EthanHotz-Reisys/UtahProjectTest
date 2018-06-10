global with sharing class AssignInternalCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
      //Shah 4/28/2017 Commenting out since we should not be using native Case object
      /*
        String recordId = ApexPages.CurrentPage().getParameters().get('id');
        Pagereference pg = null;
        
        //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
   
        if(UserProfile!=null && UserProfile.size()>0)
        {
        String profileId = UserProfile[0].Id;
     
        Map<String, SObject> recordMp= layoutHolder.recordMap;
        
        Case caseObj=(Case) recordMp.get('Case');
            
           String newOwnerId = caseObj.OwnerId;
            
          List<GroupMember> gmList=  [SELECT Group.Name FROM GroupMember WHERE UserOrGroupId =: newOwnerId AND Group.Type = 'Queue' AND Group.Name = 'GovGrants_Helpdesk_Tier1'];
            
            if(gmList!=null && gmList.size()>0)
            {
                // valid assignment
               
            caseObj.Status='In Progress';
            caseObj.TrackedBy__c=newOwnerId; // This is to enable tracking by this Tier 1 user. 
             Update caseObj;
            pg =  new Pagereference('/apex/CasesMaster');
            pg.setRedirect(false);
            }
            else{
                 // invalid assignment
              
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,'Invalid Case Assignment, you can only assign to a user in your group.' );
              //  ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-22325') );  Vinayak made this change as it was not compiling
                ApexPages.addmessage(msg);
             }
              
      
             }
                    
        return pg;
        */
        return null;
    }
    
    
}