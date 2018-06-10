/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
global with sharing class CaseClosureCtrl extends GNT.DynamicLayoutActionRedirect {
    
    global override Pagereference whenClicked(){
        //Shah 4/28/2017 Commenting out since we should not be using native Case object
        /*
         Pagereference pg ;        
        //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String tier1Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier1ProfileName',true);
        String tier2Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier2ProfileName',true);
        String daProfile = GNT.KeyValueStoreHelper.getTextValue('TS_DAProfileName',true);
        String adminProfile = GNT.KeyValueStoreHelper.getTextValue('TS_AdminProfileName',true);        
        
        String recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        Case caseObj= [Select Id, CaseComments__c,Detailed_Comments__c,Case_Comments_All__c from Case where Id=:recordId];
        String closureComments = caseObj.Detailed_Comments__c;        
        String caseComments = caseObj.CaseComments__c;        
        String str = caseComments!=null?caseComments:'' + ' Closed by ' +userinfo.getFirstName() + ' ' +userinfo.getLastName();
        str= str + ' on  '+ datetime.now();        
        caseObj.Case_Comments_All__c = (caseObj.Case_Comments_All__c!=null?caseObj.Case_Comments_All__c: '') +  str;
        
        if(closureComments!=null&&closureComments.trim().length()>0){
          if(UserProfile!=null && UserProfile.size()>0){
            String profileName = UserProfile[0].Name;
            if(profileName.equalsIgnoreCase(tier1Profile) || profileName.equalsIgnoreCase(daProfile) || profileName.equalsIgnoreCase(adminProfile))  {// this is tier 1 user who clicked on close case button
              caseObj.Status='Closed';
              caseObj.Status__c='Closed';
            }
            else if(profileName.equalsIgnoreCase(tier2Profile)){// this is tier 2 user who clicked on close case button
              caseObj.Status='Closed';
              caseObj.Status__c='Resolved';
           }           
           ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-80225') );
           ApexPages.addmessage(msg);
           Update caseObj;
          }
        pg = new Pagereference('/apex/CasesMaster');
        pg.setRedirect(true);
        }
        else{
             ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-55441') );
             ApexPages.addmessage(msg);             
        }       
        return pg;
        */
        return null;
      }
}