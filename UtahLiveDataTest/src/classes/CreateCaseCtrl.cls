/*
    <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 

public with sharing class CreateCaseCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public String recordType {get;set;}
     public PageReference savePage {get;set;}
     public PageReference cancelPage {get;set;}
   
    public CreateCaseCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        
          //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
   
        if(UserProfile!=null && UserProfile.size()>0)
        {
        String profileName = UserProfile[0].Name;
         //Shah CRF: avoid hardcoding profile names in the code as client could rename it. Use custom setting instead.
         if(profileName.equalsIgnoreCase('Helpdesk Tier1 Support') || profileName.equalsIgnoreCase('Helpdesk Tier2 Support') || profileName.equalsIgnoreCase('DEV'))
         {
                 
        savePage = New PageReference('/apex/CasesMaster');
        
        
        cancelPage = savePage;
         }
         else
         {
          savePage = New PageReference('/apex/FlexTableView?flexTableName=ExternalCaseDetails');
        
        
          cancelPage = savePage ;
         }
        }
            
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));      
        return JSON.serialize(keyValueMap);
    }
}