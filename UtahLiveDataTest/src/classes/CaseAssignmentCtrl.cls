/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
// to Assign Case to Tier 2 User/Queue
global with sharing class CaseAssignmentCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
        //Shah 4/28/2017 Commenting out since we should not be using native Case object
        /*
        String recordId = ApexPages.CurrentPage().getParameters().get('id');
        boolean errorFlag=false;
        PageReference pg=null;
        Case caseObj=null;
        ApexPages.Message msg = null;
        
        //check the profile of logged in user.
        List<Profile> UserProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];  
        caseObj = [Select Id,Case_Comments_All__c,  CaseComments__c,Tier1_Analysis__c,Tier2_Analysis__c from Case where id=:recordId]; 
        if(UserProfile!=null && UserProfile.size()>0){
            String tier1Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier1ProfileName',true);
            String tier2Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier2ProfileName',true);
            String daProfile = GNT.KeyValueStoreHelper.getTextValue('TS_DAProfileName',true);
            String adminProfile = GNT.KeyValueStoreHelper.getTextValue('TS_AdminProfileName',true);
            //  String tier3Profile = GNT.KeyValueStoreHelper.getTextValue('TS_Tier3ProfileName',true);       
            String profileName = UserProfile[0].Name;     
            String caseComments = caseObj.CaseComments__c;                    
            String str = caseComments!=null?caseComments:'' + ' Updated by ' +userinfo.getFirstName() + ' ' +userinfo.getLastName();
            str= str + ' on  '+ datetime.now();        
            caseObj.Case_Comments_All__c = (caseObj.Case_Comments_All__c!=null?caseObj.Case_Comments_All__c: '') +  str;       
                
           // Validation Check            
                String tier2QueueName = GNT.KeyValueStoreHelper.getTextValue('TS_Tier2QueueName',true);
                //Shah CRF: If queue is not present, the below SOQL will throw exception which is not handled.
                Group gp = [Select Id, Name from Group where Name=:tier2QueueName and Type='Queue' Limit 1];                            
                caseObj.OwnerId=gp.Id; // assign to tier2 Queue
                caseObj.status='In Progress';                      
                String tier1Comments = caseObj.Tier1_Analysis__c;         
                if(profileName.equalsIgnoreCase(daProfile) || profileName.equalsIgnoreCase(adminProfile) || profileName.equalsIgnoreCase(tier1Profile) )  {// DA Profile and Admin Profile can re assign without comments       
                    if((tier1Comments!=null && tier1Comments.trim().length()>0) || !profileName.equalsIgnoreCase(tier1Profile) )
                        errorFlag=false;
                    else{ 
                        errorFlag=true;
                        msg =new Apexpages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-49125') );
                    }
                }           
                else{
                        errorFlag=true;
                        //Shah CRF: hardcoded exception message should be moved to data driven
                        msg=new Apexpages.Message(ApexPages.Severity.ERROR,'Cases can be assigned by Tier 1 or Admin Users' );
                }
           
            if(errorFlag){           
             ApexPages.addmessage(msg);
            }else{              
             Update caseObj;  
            }   
      }
   
       if(!errorFlag){ 
       pg=new Pagereference('/apex/CasesMaster');
       pg.setRedirect(true);          
       }   
        return pg;
        */
        return null;
    }
    
    
}