public with sharing class ApplicationEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public String packageId {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private Announcement__c announcementObj;
   // private OpportunityQualification__c qualifiedAnnouncementObj;
    public String pbdIds{get;set;}
    public ID organizationId {get;set;}
    public String title;
    private Application__c app {get;set;}
    public ID AnnId{get;set;}
    public ID userid{get;set;}

    
    public ApplicationEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        if (recordId != null){
	        Application__c appobj=[Select Announcement__c from Application__c where id=:recordId];
	        AnnId=appobj.announcement__c;
        }
        System.debug('The recordId     is --'+recordId);  
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        Id  preAppId = ApexPages.CurrentPage().getParameters().get('preAppId');  
        System.debug('The preAppId is --'+preAppId); 
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id accountId = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId() ].GNT__OrganizationId__c; 
        organizationId= accountId;
        if(recordId == null && preAppId == null ){  // When we are creating a new Application which is not saved to Salesforce
             Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
             System.debug('The announcementId is --'+announcementId);
             //Id accountId = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId() ].GNT__OrganizationId__c;         
             System.debug('The accountId is --'+accountId);
             if(accountId != null){
             Account userOrganization = [Select Id, Code__c from Account where id =: accountId Limit 1];  
             }           
             
             announcementObj = [SELECT Id, ApplyingAgency__c ,ApplyingAgency__r.Code__c, AnnouncementName__c,AwardingFedAgency__c,AwardCeiling__c,CloseDate__c,AnnouncementNumber__c,
                                  AwardFloor__c ,Budget__c,ApplicationDeadlineWithDateTime__c,EligibilityDescription__c,PreApplicationDeadline__c,PreApplicationDeadlineWithDateTime__c,StateProgram__c , AgencyContact__c,
                                  Program__c ,CFDANumber__c,EstimatedProjectPeriodStartDate__c, EstimatedProjectPeriodEndDate__c,OpportunityCategory__c, FOALead__c, FOALead__r.LastUpdateDate__c, (select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Application') FROM Announcement__c WHERE id=:announcementId ]; 
           // qualifiedAnnouncementObj  = [SELECT Id, ApplicationCreated__c,OpportunityStatus__c FROM OpportunityQualification__c WHERE id=:announcementId  ]  ;                    
            // organizationId= accountId;                                
            GNT.DynamicLayoutDefaultValueHelper dv121 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrganization__c',accountId,true);
            listDefaultValues.add(dv121); 

            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalAwardingAgency__c',announcementObj.AwardingFedAgency__c,true);
            listDefaultValues.add(dv2); 
            GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityNumber__c',announcementObj.AnnouncementNumber__c,true);
            listDefaultValues.add(dv3); 
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardCeiling__c',announcementObj.AwardCeiling__c,true);
            listDefaultValues.add(dv4); 
            GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Budget__c',announcementObj.Budget__c,true);
            listDefaultValues.add(dv5); 
            GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardFloor__c',announcementObj.AwardFloor__c,true);
            listDefaultValues.add(dv6); 
            GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ApplicationDeadlineWithDateTime__c',announcementObj.ApplicationDeadlineWithDateTime__c,true);
            listDefaultValues.add(dv7); 
            GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PreApplicationDeadline__c',announcementObj.PreApplicationDeadline__c,true);
            listDefaultValues.add(dv8);
          //GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StateProgram__c',announcementObj.StateProgram__c,true);
          //listDefaultValues.add(dv9); 
            GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'EligibilityDescription__c',announcementObj.EligibilityDescription__c,true);
            listDefaultValues.add(dv10); 
            GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AgencyContact__c',announcementObj.AgencyContact__c,true);
            listDefaultValues.add(dv12); 
            GNT.DynamicLayoutDefaultValueHelper dv34 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodStartDate__c',announcementObj.EstimatedProjectPeriodStartDate__c,true);
            listDefaultValues.add(dv34);                
            GNT.DynamicLayoutDefaultValueHelper dv35 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodEndDate__c',announcementObj.EstimatedProjectPeriodEndDate__c,true);
            listDefaultValues.add(dv35);                        
            //GNT.DynamicLayoutDefaultValueHelper dv14 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Title__c',announcementObj.AnnouncementName__c,true);
            //listDefaultValues.add(dv14);   
            GNT.DynamicLayoutDefaultValueHelper dv15 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GranteeTypeOfSubmission__c','Application',true); 
            listDefaultValues.add(dv15);  
          //GNT.DynamicLayoutDefaultValueHelper dv16 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalProgram__c',announcementObj.Program__c,true); 
          //listDefaultValues.add(dv16); 
            GNT.DynamicLayoutDefaultValueHelper dv17 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CFDANumber__c',announcementObj.CFDANumber__c,true);
          //listDefaultValues.add(dv17);      
            GNT.DynamicLayoutDefaultValueHelper dv18 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityCategory__c',announcementObj.OpportunityCategory__c,true);
        //  listDefaultValues.add(dv18);  
          //  GNT.DynamicLayoutDefaultValueHelper dv19 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'QualifiedAnnouncements__r.OpportunityStatus__c','Converted to Application',true);
          //  listDefaultValues.add(dv15);
            GNT.DynamicLayoutDefaultValueHelper dv19 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'LeadLastModifiedDate__c',announcementObj.FOALead__r.LastUpdateDate__c,true);  
            listDefaultValues.add(dv19);
            if(announcementObj.FOALead__c == null){
              GNT.DynamicLayoutDefaultValueHelper dv20 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SubmitToGrants__c',false,true);  
            listDefaultValues.add(dv20);
            }else{
              GNT.DynamicLayoutDefaultValueHelper dv20 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SubmitToGrants__c',true,true);  
            listDefaultValues.add(dv20);
            }
        }
        if(preAppId == null){   
            System.debug('00 THE APP IS NULL  >>>'+ recordId);
            String applicationSubmitted = ApexPages.CurrentPage().getParameters().get('applicationSubmitted');
            if(applicationSubmitted != null && applicationSubmitted == 'true'){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.ApplicationApplyWarningMessage));
            } 
            Id announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
            accountId = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId() ].GNT__OrganizationId__c; 
            // Changed from Account to List<Account> -> Was throwing List has no rows for Assignment error
            List<Account> userOrganization = [Select Id, Code__c from Account where id =: accountId];
            System.debug('<<<<<< USER ORGANIZATION ID IS  >>>>>> '+ userOrganization);
      
            if(recordId != null){
             app = [SELECT Id, announcement__c, OwnerId,ExternalOrganization__c,Announcement__r.AnnouncementName__c FROM Application__c WHERE Id =:recordId ];
             System.debug('11 THE APP IS NULL  >>>'+ announcementId);
             organizationId= app.ExternalOrganization__c;
             }
             if(announcementId != null) {
                announcementObj = [SELECT Id, ApplyingAgency__c ,ApplyingAgency__r.Code__c, AnnouncementName__c,AwardingFedAgency__c,AwardCeiling__c,CloseDate__c,AnnouncementNumber__c, OrganizationName__c,
                                  AwardFloor__c ,Budget__c,ApplicationDeadlineWithDateTime__c,EligibilityDescription__c,PreApplicationDeadline__c,PreApplicationDeadlineWithDateTime__c,StateProgram__c , AgencyContact__c,
                                  Program__c ,CFDANumber__c,EstimatedProjectPeriodStartDate__c, EstimatedProjectPeriodEndDate__c,OpportunityCategory__c,(select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Application') FROM Announcement__c WHERE id=:announcementId ]; 
            }else {
             //   Application__c app = [SELECT Id, announcement__c, OwnerId,Announcement__r.AnnouncementName__c FROM Application__c WHERE Id =:recordId ];
                announcementObj = [SELECT Id, ApplyingAgency__c ,AnnouncementName__c,AwardCeiling__c,CloseDate__c,AwardingFedAgency__c, OrganizationName__c,
                                 AwardFloor__c ,Budget__c,ApplicationDeadlineWithDateTime__c,EstimatedProjectPeriodStartDate__c, EstimatedProjectPeriodEndDate__c,PreApplicationDeadline__c,EligibilityDescription__c,StateProgram__c,CFDANumber__c
                                 ,(select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Application') FROM Announcement__c WHERE id=:app.announcement__c ]; 
                title = app.Announcement__r.AnnouncementName__c;
                System.debug('title----'+title);
                // if the Application owner is the current user then proceed with checking if there exitsts any changes requests for this App
                /*if(app.OwnerId == UserInfo.getUserId()){
                    List<ChangeRequest__c> changeReq = [Select id From ChangeRequest__c 
                                                        where Application__c = :recordId AND Status__c in('Accepted','Initiated') 
                                                        Order by CreatedDate DESC Limit 1];
                    if(changeReq.size() > 0){
                        Set<Id> pgBlockIdSet = new Set<Id>();
                        List<ChangeRequestDetail__c> crDetail = [Select GNT__PageBlockConfig__c From ChangeRequestDetail__c 
                                                                 Where ChangeRequest__c IN :changeReq];
                        for(ChangeRequestDetail__c crd : crDetail){
                            pgBlockIdSet.add(crd.PageBlockConfig__c);
                        }
                        pbdIds = JSON.serialize(pgBlockIdSet);
                    }
                }*/
            }
            try{
            system.debug('--announcementObj--'+announcementObj);
            
               //system.debug('--announcementObj.Business_Packages__r[0]--'+announcementObj.Business_Packages__r[0]);
            //BusinessPackage__c applicationPackage = [select id from BusinessPackage__c where FundingOpportunity__c=:] 
            if (announcementObj.Business_Packages__r.size() > 0) {
                packageId = announcementObj.Business_Packages__r[0].PackageConfig__c;  
            }
            else { //Dummy package for now
                //packageId = 'a0n35000000CnsG';
                if(announcementObj.OrganizationName__c== 'USBE' || announcementObj.OrganizationName__c == 'SYSTEM'){
                    pageTemplateName = 'ApplicationTemplateUSBE';
                }else{
                    pageTemplateName = 'Application template Grantor';
                }

            }
            
            System.debug('THE packageid  >>>'+ packageId);         
            System.debug('22 THE APP IS NULL  >>>'+ pageTemplateName); 
            savePage = Page.ApplicationView;
            savePage.getParameters().put('id', recordId); 
            }
            catch(Exception exc){
                system.debug('error occured--'+exc.getMessage());
                system.debug(exc);
            }
          
           String retURL= apexpages.currentpage().getparameters().get('retURL');
           if (!String.isEmpty(retURL)) {
             cancelPage = new pagereference(retURL);
           }else if (!String.isEmpty(recordId)) {
                cancelPage = Page.ApplicationView;
                cancelPage.getParameters().put('id', recordId);   
            }else if(!String.isEmpty(preAppId) && String.isEmpty(recordId) ){
                cancelPage = Page.PreApplicationView;
                cancelPage.getParameters().put('id', preAppId);  
            }
            else {cancelPage = Page.RecipientOpportunity;} 
                              
            //listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
            listDefaultValues.add(dv); 
           
             System.debug('33  THE APP IS NULL  >>>'+ appName);   
            if(appName == 'StateasGrantee'){
                if(app == null){  
                        System.debug(' 44 THE APP IS NULL >>>>>');
                        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityTitle__c',announcementObj.AnnouncementName__c,true);
                        listDefaultValues.add(dv1); 
                        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalAwardingAgency__c',announcementObj.AwardingFedAgency__c,true);
                        listDefaultValues.add(dv2); 
                        GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityNumber__c',announcementObj.AnnouncementNumber__c,true);
                        listDefaultValues.add(dv3); 
                        GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardCeiling__c',announcementObj.AwardCeiling__c,true);
                        listDefaultValues.add(dv4); 
                        GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Budget__c',announcementObj.Budget__c,true);
                        listDefaultValues.add(dv5); 
                        GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardFloor__c',announcementObj.AwardFloor__c,true);
                        listDefaultValues.add(dv6); 
                        GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ApplicationDeadlineWithDateTime__c',announcementObj.ApplicationDeadlineWithDateTime__c,true);
                        listDefaultValues.add(dv7); 
                        GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PreApplicationDeadline__c',announcementObj.PreApplicationDeadline__c,true);
                        listDefaultValues.add(dv8);
                        GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StateProgram__c',announcementObj.StateProgram__c,true);
                        listDefaultValues.add(dv9); 
                        GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'EligibilityDescription__c',announcementObj.EligibilityDescription__c,true);
                        listDefaultValues.add(dv10); 
                        GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AgencyContact__c',announcementObj.AgencyContact__c,true);
                        listDefaultValues.add(dv12); 
                        if(userOrganization != null && userOrganization.size () > 0){
                            GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrganization__c',announcementObj.ApplyingAgency__c,true);
                            listDefaultValues.add(dv13);
                            GNT.DynamicLayoutDefaultValueHelper dv13i = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalCode__c',announcementObj.ApplyingAgency__r.Code__c,true);
                            listDefaultValues.add(dv13i);    
                            //ExternalCode__c
                        }
                        GNT.DynamicLayoutDefaultValueHelper dv14 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Title__c',announcementObj.AnnouncementName__c,true);
                        listDefaultValues.add(dv14);   
                        GNT.DynamicLayoutDefaultValueHelper dv15 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GranteeTypeOfSubmission__c','Application',true); 
                        listDefaultValues.add(dv15);  
                        GNT.DynamicLayoutDefaultValueHelper dv16 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalProgram__c',announcementObj.Program__c,true); 
                        listDefaultValues.add(dv16); 
                        GNT.DynamicLayoutDefaultValueHelper dv17 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CFDANumber__c',announcementObj.CFDANumber__c,true);
                        listDefaultValues.add(dv17);      
                        GNT.DynamicLayoutDefaultValueHelper dv18 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityCategory__c',announcementObj.OpportunityCategory__c,true);
                        listDefaultValues.add(dv18);  

                    } 
                }  
            GNT.DynamicLayoutDefaultValueHelper helper; 
            System.debug('55 THE APP IS NULL >>>>>' + title);
            System.debug('66 THE APP IS NULL >>>>>' +!String.isEmpty(title));
            if(!String.isEmpty(title)){
                helper = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Title__c',title,false);
                system.debug('helper---->>>'+helper);
            }
            if(helper != null) 
            listDefaultValues.add(helper); 
            System.debug('77 listDefaultValues----'+listDefaultValues);
        } 
        if(preAppId != null){  // ie; PreAppliation is already created 
                 listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
                Preapplication__c preApplication = [Select OpportunityNumber__c,OpportunityTitle__c , AwardCeiling__c , AwardFloor__c ,Budget__c , ApplicationDeadline__c , GranteeTypeOfSubmission__c ,
                FederalAwardingAgency__c ,CFDANumber__c ,EligibilityDescription__c ,AwardingAgencyContact__c , Title__c ,StateProgram__c ,RequestedAmount__c ,FederalProgram__c ,ProjectAbstract__c,
                OpportunityCategory__c, ProjectPeriodStartDate__c,ProjectPeriodEndDate__c ,Status__c ,ProjectDirector__c,Announcement__c from Preapplication__c where Id =:preAppId]; 

                
               
                announcementObj = [SELECT Id, AnnouncementName__c,AwardingFedAgency__c,AwardCeiling__c,CloseDate__c,AnnouncementNumber__c,
                                  AwardFloor__c ,Budget__c,ApplicationDeadlineWithDateTime__c,PreApplicationDeadline__c,EligibilityDescription__c,PreApplicationDeadlineWithDateTime__c,StateProgram__c , 
                                  AgencyContact__c,(select PackageConfig__r.Name from Business_Packages__r where PackageType__c='Application')
                                  FROM Announcement__c WHERE id=:preApplication.Announcement__c]; 
               
             
                //pageTemplateName = announcementObj.ApplicationPackage__r.GNT__PageTemplateConfig__r.Name;
                System.debug('shivankar: '+announcementObj.Business_Packages__r);
                if(announcementObj.Business_Packages__r[0].PackageConfig__c != null){   
                packageId = announcementObj.Business_Packages__r[0].PackageConfig__c;
                }
                accountId = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId() ].GNT__OrganizationId__c; 
                Account userOrganization = [Select Id, Code__c from Account where id =: accountId];
                System.debug(' The userOrganization Id is '+ userOrganization);  

                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',preApplication.Announcement__c,true);
                listDefaultValues.add(dv);             

                GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityTitle__c',preApplication.OpportunityTitle__c,true);
                listDefaultValues.add(dv1); 
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityNumber__c',preApplication.OpportunityNumber__c,true);
                listDefaultValues.add(dv2); 
              
                GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardCeiling__c',preApplication.AwardCeiling__c,true);
                listDefaultValues.add(dv3); 
             
                GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardFloor__c',preApplication.AwardFloor__c,true);
                listDefaultValues.add(dv4); 

                GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Budget__c',preApplication.Budget__c,true);
                listDefaultValues.add(dv5); 

                GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ApplicationDeadlineWithDateTime__c',preApplication.ApplicationDeadline__c,true);
                listDefaultValues.add(dv6); 

                GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GranteeTypeOfSubmission__c','Application',true); 
                listDefaultValues.add(dv7);  

                GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalAwardingAgency__c',preApplication.FederalAwardingAgency__c,true);
                listDefaultValues.add(dv8); 

                GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CFDANumber__c',preApplication.CFDANumber__c,true);
                listDefaultValues.add(dv9); 

                GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'EligibilityDescription__c',preApplication.EligibilityDescription__c,true);
                listDefaultValues.add(dv10); 
 
                GNT.DynamicLayoutDefaultValueHelper dv11 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AgencyContact__c',preApplication.AwardingAgencyContact__c,true);
                listDefaultValues.add(dv11);
              
                GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StateProgram__c',preApplication.StateProgram__c,true);
                listDefaultValues.add(dv12); 
                
                GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FederalProgram__c',preApplication.FederalProgram__c,true);
                listDefaultValues.add(dv13); 

                GNT.DynamicLayoutDefaultValueHelper dv14 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodStartDate__c',preApplication.ProjectPeriodStartDate__c,true);
                listDefaultValues.add(dv14); 
                
                GNT.DynamicLayoutDefaultValueHelper dv15 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodEndDate__c',preApplication.ProjectPeriodEndDate__c,true);
                listDefaultValues.add(dv15); 

            //    GNT.DynamicLayoutDefaultValueHelper dv16 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RequestedAmount__c',preApplication.RequestedAmount__c,true);
            //    listDefaultValues.add(dv16); 
       
                GNT.DynamicLayoutDefaultValueHelper dv17 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrganization__c',userOrganization.Id,true);
                listDefaultValues.add(dv17);   // Owner Agency
                
                GNT.DynamicLayoutDefaultValueHelper dv13i = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalCode__c',userOrganization.Code__c,true);
                listDefaultValues.add(dv13i); 

                GNT.DynamicLayoutDefaultValueHelper dv18 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Title__c',preApplication.Title__c,true);
                listDefaultValues.add(dv18);   
               
                GNT.DynamicLayoutDefaultValueHelper dv19 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectAbstract__c',preApplication.ProjectAbstract__c,true);
                listDefaultValues.add(dv19); 
                
                GNT.DynamicLayoutDefaultValueHelper dv20 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectDirector__c',preApplication.ProjectDirector__c,true);
                listDefaultValues.add(dv20); 

                GNT.DynamicLayoutDefaultValueHelper dv21 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'OpportunityCategory__c',preApplication.OpportunityCategory__c,true);
                listDefaultValues.add(dv21); 

                GNT.DynamicLayoutDefaultValueHelper dv22 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TypeOfApplication__c','New',true);
                listDefaultValues.add(dv22);   

                GNT.DynamicLayoutDefaultValueHelper dv23 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Preapplication__c',preAppId,true);
                listDefaultValues.add(dv23); 

                System.debug('LIST OF DEFAULT VALUES IS '+ listDefaultValues + '>>>>>>>>>>>');
        }
         
    }
    
    public PageReference redirectForExtUsers(){
        if(GNT.AppUtils.isSite()){
            PageReference loginPage=  Page.CommunitiesLanding;
            loginPage.setRedirect(true);
            loginPage.getParameters().put('announcementId', ApexPages.CurrentPage().getParameters().get('announcementId'));
            loginPage.getParameters().put('preApplication', 'true');
            return loginPage;
        }
        return null;
    }  

    public string getKeyValueMap(){ 
        Map<String,String> keyValueMap = new Map<String,String>();
        System.debug('88 THE APP IS NULL >>>>>'+ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('applicationid',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('AnnId',AnnId);
        if(organizationId!=null)
        keyValueMap.put('orgId',organizationId);
        userid=UserInfo.getUserId() ;
         keyValueMap.put('userid',userid);

        return JSON.serialize(keyValueMap);
    }

       public static String findObjectName(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                System.debug('Prefix is ' + prefix);
                 
                //Check if the prefix matches with requested prefix
                if(prefix!=null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();
                    System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
}