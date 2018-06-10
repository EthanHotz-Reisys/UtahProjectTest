public with sharing class CasesMasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public String recordType {get;set;}
       public transient String previousTabName {get; set;}
    public String userRole {get;set;}
 
    public Boolean getDisplayTableTier1() {

            //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
   
         if(UserProfile!=null && UserProfile.size()>0)
        {
         String profileName = UserProfile[0].Name;
                  
       if(profileName.equalsIgnoreCase('Helpdesk Tier1 Support') || profileName.equalsIgnoreCase('System Administrator') ) // checking against tier 1 profile
        {
            return true;
        }            
       
        }
         return false;
    }

 

  public Boolean getDisplayTableTier2() {

            //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
   
    
        if(UserProfile!=null && UserProfile.size()>0)
        {
    
        String profileName = UserProfile[0].Name; // checking value to test exceptio TODO: revert code here
                    
        if(profileName.equalsIgnoreCase('Helpdesk Tier2 Support')) // checking against tier 2 profile
        {
            return true;
        }            
       
        }
         return false;
    }
 
 public String getLoggedInUserRole() {

            //check the profile of logged in user.
        //List<Profile> UserRole = [SELECT Id, Name FROM Role WHERE Id=: userinfo.getUserRoleId() LIMIT 1];
   String role = UserInfo.getUserRoleId();
   
   System.debug('role    '+role );
   
    userRole=role;
      
        return role ;
    }
    
  
    public CasesMasterCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');       
        GNT.AppUtils.setTabCookie();  
        previousTabName = GNT.AppUtils.getSelectedTabName(); 
        
        String role = UserInfo.getUserRoleId();
   
  
   
    userRole=role;    
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('loggedInUser', UserInfo.getUserId());      
        return JSON.serialize(keyValueMap);
    }
}