public with sharing class PreApplicationEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pkgId {get;set;}
    public String pageTemplateName{get;set;}
    private Boolean duplicatePreApplication ;
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private Announcement__c announcementObj;
    private PreApplication__c preapp {get;set;}

    public PreApplicationEditCtrl (ApexPages.StandardController stdController){
        Id accountId;
        Account userOrganization;
        duplicatePreApplication=false;
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String applicationSubmitted = ApexPages.CurrentPage().getParameters().get('preapplicationSubmitted');
        if(applicationSubmitted != null && applicationSubmitted == 'true'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.PreApplicationApplyWarningMessage));
        } 
        Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
    
        if(announcementId != null) {
        announcementObj = [SELECT Id ,AnnouncementName__c,EligibilityDescription__c,AwardingFedAgency__c,ProgramApprover__c,CFDANumber__c,CloseDate__c,AnnouncementNumber__c ,Organization__c ,AgencyContact__c ,Program__c ,EstimatedFundedAmount__c,
                             AwardCeiling__c,AwardFloor__c ,EstimatedProjectPeriodStartDate__c, EstimatedProjectPeriodEndDate__c ,(select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Pre-Application')
                             RequestedAmount__c ,Budget__c,ApplicationDeadlineWithDateTime__c,PreApplicationDeadlineWithDateTime__c,StateProgram__c  FROM Announcement__c WHERE id=:announcementId ]; 
        
          User u = [select GNT__OrganizationId__c from User where id =:Userinfo.getUserId()];
           
         List<PreApplication__c> preApplicationList = [SELECT Id,Status__c,CreatedBy.GNT__OrganizationId__c FROM PreApplication__c WHERE Announcement__c =: announcementId and CreatedBy.GNT__OrganizationId__c=:u.GNT__OrganizationId__c];//CreatedById =: Userinfo.getUserId()];
         System.debug('--preApplicationList--'+preApplicationList);
         if(!preApplicationList.IsEmpty()){
                 // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pre-Application already created for this Annoucement.')); 
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-77373')));   
              //  return null;
              duplicatePreApplication=true;
         }          

        }
        else 
        {

            preapp = [SELECT Id, announcement__c FROM PreApplication__c   WHERE Id =:recordId ];
            announcementObj = [SELECT Id,ProgramApprover__c,(select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Pre-Application')
            				  FROM Announcement__c WHERE id=:preapp.announcement__c ];  

       }

         pkgId =  announcementObj.Business_Packages__r[0].PackageConfig__c;

        savePage = Page.PreApplicationView;
        savePage.getParameters().put('id', recordId);
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.PreApplicationView;
            cancelPage.getParameters().put('id', recordId);  
        }   
         
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
         GNT.DynamicLayoutDefaultValueHelper dv0 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
         listDefaultValues.add(dv0); 
        
        if(preapp == null){ 

             User user = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId()];
               system.debug('--- user--->>>'+user);
     
             if(user <> null && user.GNT__OrganizationId__c <> null){
             	accountId=user.GNT__OrganizationId__c;
             }             
             system.debug('accountId---->>>'+accountId);
             
            if(accountId != null){
                userOrganization = [Select Id from Account where id =: accountId];      
            }
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityTitle__c',announcementObj.AnnouncementName__c,true);
            listDefaultValues.add(dv1); 

            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityNumber__c',announcementObj.AnnouncementNumber__c,true);
            listDefaultValues.add(dv2); 


            GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardFloor__c',announcementObj.AwardFloor__c,true);
            listDefaultValues.add(dv3); 

            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardCeiling__c',announcementObj.AwardCeiling__c,true);
            listDefaultValues.add(dv4);  

            GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RequestedAmount__c',announcementObj.EstimatedFundedAmount__c,true);
            listDefaultValues.add(dv5); 
 
           GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ApplicationDeadline__c',announcementObj.ApplicationDeadlineWithDateTime__c,true);
           listDefaultValues.add(dv6); 
             
            GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GranteeTypeOfSubmission__c','Pre-Application',true);
            listDefaultValues.add(dv7);

            GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalAwardingAgency__c',announcementObj.Organization__c,true);
            listDefaultValues.add(dv8);

            GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CFDANumber__c',announcementObj.CFDANumber__c,true);
            listDefaultValues.add(dv9);

            GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'EligibilityDescription__c',announcementObj.EligibilityDescription__c,true);
            listDefaultValues.add(dv10);   
                       
            GNT.DynamicLayoutDefaultValueHelper dv11 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardingAgencyContact__c',announcementObj.AgencyContact__c,true);
            listDefaultValues.add(dv11);

            if(userOrganization != null){
                GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrganization__c',userOrganization.Id,true);
                listDefaultValues.add(dv12);
            }
 
            GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StateProgram__c',announcementObj.StateProgram__c,true);
            listDefaultValues.add(dv13); 

            GNT.DynamicLayoutDefaultValueHelper dv14 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalProgram__c',announcementObj.Program__c,true);
            listDefaultValues.add(dv14); 

            GNT.DynamicLayoutDefaultValueHelper dv15 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Title__c',announcementObj.AnnouncementName__c,true);
            listDefaultValues.add(dv15);
            GNT.DynamicLayoutDefaultValueHelper dv16 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectDirector__c',UserInfo.getUserId(),true);
            listDefaultValues.add(dv16);

            GNT.DynamicLayoutDefaultValueHelper dv17 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgramApprover__c',announcementObj.ProgramApprover__c,true);
            listDefaultValues.add(dv17);
            
             GNT.DynamicLayoutDefaultValueHelper dv18 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalAwardingAgency__c',announcementObj.AwardingFedAgency__c,true);
            listDefaultValues.add(dv18);
            
            GNT.DynamicLayoutDefaultValueHelper dv19 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodStartDate__c',announcementObj.EstimatedProjectPeriodStartDate__c,true);
            listDefaultValues.add(dv19);
            
            GNT.DynamicLayoutDefaultValueHelper dv20 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodEndDate__c',announcementObj.EstimatedProjectPeriodEndDate__c,true);
            listDefaultValues.add(dv20);
          
        }    
            
                         
    } 
     public PageReference redirectForExtUsers(){ 
        

        if(duplicatePreApplication)
        {
           System.debug(' inside duplicatePreApplication');  
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pre-Application already created for this Annoucement.'));  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-77373')));   
           PageReference annPage=  Page.AnnouncementView;
            annPage.setRedirect(false);
            annPage.getParameters().put('Id', ApexPages.CurrentPage().getParameters().get('announcementId'));
               return annPage;

        }
        if(GNT.AppUtils.isSite()){
          System.debug(' inside 123'); 
            PageReference loginPage=  Page.CommunitiesLanding;
            loginPage.setRedirect(true);
            loginPage.getParameters().put('announcementId', ApexPages.CurrentPage().getParameters().get('announcementId'));
            loginPage.getParameters().put('preApplication', 'true');
            return loginPage;
        }
         System.debug(' inside redirectForExtUsers0982'); 
        return null;
    } 

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('preapplicationid',ApexPages.currentPage().getParameters().get('id'));
         System.debug(' PAGE TEMPALTE NAME IS 22'+ ApexPages.currentPage().getParameters().get('id'));  
        return JSON.serialize(keyValueMap);
    }
}