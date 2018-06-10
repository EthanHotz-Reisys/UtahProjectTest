global with sharing class ApplicationReviewTriggerHelper extends GNT.TriggerHelper {
    
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');  
    global override void processBeforeInsert() {    
        updateReviewWithUser(Trigger.new);
    }  

    global override void processAfterInsert() {  
        updatePreApplication(Trigger.new);
        UpdateNoofFOAReviews(Trigger.new);
        updateApplicationNoOfReviews(Trigger.new);
         if(appName != 'StateasGrantee' ){   
            updateGrantorApplication(Trigger.new);
        }
        
        
    }
    global override void processAfterUpdate() {
        UpdateNoofFOAReviews(Trigger.new);
        updateApplicationNoOfReviews(Trigger.new);
    }
    
    global override void processBeforeDelete() {
       UpdateNoofFOAReviews(Trigger.old);
       updateApplicationNoOfReviews(Trigger.old);
    }
      
    
    global override void processAfterDelete() {
        //UpdateNoofFOAReviews(Trigger.old);
       // updateApplicationNoOfReviews(Trigger.old);
    }
 
private void updateReviewWithUser(List<ApplicationReview__c> lstReviews){
        Id usrId = UserInfo.getUserId();
        // select the Role type for the user from the Roles and Reponsibilities
        Map<Id,List<ApplicationReview__c>> appId = new Map<Id,List<ApplicationReview__c>>();
        Map<Id,List<ApplicationReview__c>> preAppId = new Map<Id,List<ApplicationReview__c>>();

        for(ApplicationReview__c appReview : lstReviews){
            if(appReview.FOALead__c != null){               
                List<ApplicationReview__c> evaluations = [Select Id from ApplicationReview__c where CreatedById = :UserInfo.getUserId() AND FOALead__c = :appReview.FOALead__c];
                User u = [Select AccountNameFormulaField__c from User where Id = :UserInfo.getUserId()];
                List<Announcement__c> anns = [Select Id from Announcement__c where CreatedBy.AccountNameFormulaField__c = :u.AccountNameFormulaField__c AND FOALead__c = :appReview.FOALead__c];
                if(evaluations.size() > 0){
                    appReview.addError('You have already created evaluation');
                }else if(anns.size() > 0){
                    appReview.addError('An opportunity has already created for your organization');
                }else{
                    continue;
                }
            }           
            if(appReview.Application__c != null){
                List<ApplicationReview__c> lstAppReview =   appId.get(appReview.Application__c);
                if(lstAppReview == null ){              
                    lstAppReview = new List<ApplicationReview__c>();
                    appId.put(appReview.Application__c,lstAppReview);
                }       
                lstAppReview.add(appReview); 
            }

            if(appReview.PreApplication__c != null){
                List<ApplicationReview__c> lstPreAppReview = preAppId.get(appReview.PreApplication__c);
                if(lstPreAppReview == null){
                    lstPreAppReview = new List<ApplicationReview__c>();
                    preAppId.put(appReview.PreApplication__c,lstPreAppReview);
                }
                    lstPreAppReview.add(appReview);
            }           
        }    
 
        for(ApplicationReview__c appReview : lstReviews){
            if(appReview.FOALead__c != null){
                continue;
            } 
            if(appReview.Application__c!= null){
                List<ApplicationReview__c> applicationReviewList = appId.get(appReview.Application__c);
                for(ApplicationReview__c appRev: applicationReviewList){
                    appRev.OwnerId = UserInfo.getUserId();      
                }
            }
            if(appReview.PreApplication__c!= null){
                List<ApplicationReview__c> applicationReviewList = preAppId.get(appReview.PreApplication__c);
                for(ApplicationReview__c preAppRev: applicationReviewList){
                    preAppRev.OwnerId = UserInfo.getUserId();         
                }  
            } 
        }   
    }
    
    private void UpdateNoofFOAReviews(List<ApplicationReview__c> lstApplicationReview){
        Set<Id> foaIds = new Set<Id>();
        for (ApplicationReview__c appRev : lstApplicationReview) {
            if(appRev.FOALead__c != null){
                continue;
            } 
            if (appRev.FundingOpportunity__c != null) {
                foaIds.add(appRev.FundingOpportunity__c);
            }
       }
       if(foaIds.size() == 0){
            return;
       }
      List<Announcement__c> annsToRollup = new List<Announcement__c>();
      for (AggregateResult ar : [SELECT FundingOpportunity__c AnnId, Count(id) ReviewCount 
                               FROM ApplicationReview__c 
                               WHERE FundingOpportunity__c in: foaIds 
                               GROUP BY FundingOpportunity__c]){
        Announcement__c a = new Announcement__c();
        a.Id = (Id) ar.get('AnnId'); 
        a.FOAReviews__c = (Integer) ar.get('ReviewCount');
        if(Trigger.isbefore && Trigger.isdelete && (ar.get('ReviewCount')==1)){
            a.FOAReviews__c = 0;
        }
        annsToRollup.add(a);   
      }
      update annsToRollup;  
    }
    
    
   private void updateApplicationNoOfReviews(List<ApplicationReview__c> lstApplicationReview){
        Set<Id> ids = new Set<Id>();
        for (ApplicationReview__c appRev : lstApplicationReview) {
            if(appRev.FOALead__c != null){
                continue;
            } 
            if (appRev.Application__c != null) {
                ids.add(appRev.Application__c);
            }
       }
       if(ids.size() == 0){
            return;
       }
      List<Application__c> appRollUp = new List<Application__c>();
      for (AggregateResult ar : [SELECT Application__c appId, Count(id) ReviewCount 
                               FROM ApplicationReview__c 
                               WHERE Application__c in: ids 
                               GROUP BY Application__c]){
        Application__c app = new Application__c();
        app.Id = (Id) ar.get('appId'); 
        app.NumberOfReviews__c = (Integer) ar.get('ReviewCount');
        appRollUp.add(app);
      }
      update appRollUp;
    }
 
    private void updatePreApplication(List<ApplicationReview__c> lstApplicationReview){ 

        System.debug('The list of application is '+lstApplicationReview);

        Integer preAppReviewsCount = GNT.KeyValueStoreHelper.getIntegervalue('ReviewsForGranteePreApp',true);   
        Integer appReviewsCount = GNT.KeyValueStoreHelper.getIntegervalue('ReviewsForGranteeApp',true); 
        Map<Id,List<Id>> preApplicationReviewMap = new Map<Id,List<Id>>();
        Map<Id,List<Id>> applicationReviewMap = new Map<Id,List<Id>>(); 

        Set<Id> preApplicationId = new Set<Id>();
        Set<Id> applicationId = new Set<Id>();

        for(ApplicationReview__c app: lstApplicationReview){
            if(app.FOALead__c != null){
                continue;
            }
            if(app.PreApplication__c != null){
                preApplicationId.add(app.PreApplication__c);
            }
            if(app.Application__c != null){
                applicationId.add(app.Application__c); 
            }
        }   

        if(preApplicationId.size() == 0 && applicationId.size() == 0){
            return;
        }

        System.debug(' PReApp Count '+preAppReviewsCount);      
        List<ApplicationReview__c> lstPreAppReview = [Select Id,ReviewComments__c,PreApplication__c,Application__c from ApplicationReview__c where PreApplication__c in: preApplicationId];
        List<ApplicationReview__c> lstAppReview = [Select Id,ReviewComments__c,PreApplication__c,Application__c from ApplicationReview__c where Application__c in: applicationId];

        System.debug(' lstAppReview Count '+lstAppReview);

        for(ApplicationReview__c appReview : lstPreAppReview){   
            if(appReview.PreApplication__c != null){
                List<Id> lstReviewsPreApp = preApplicationReviewMap.get(appReview.PreApplication__c);   
                if(lstReviewsPreApp == null){  
                    lstReviewsPreApp = new List<Id>();
                    preApplicationReviewMap.put(appReview.PreApplication__c,lstReviewsPreApp);  
                }
                if(String.isNotEmpty(appReview.ReviewComments__c)){
                    lstReviewsPreApp.add(appReview.Id);     
                }
            }
        }

        for(ApplicationReview__c appReview : lstAppReview){     
            if(appReview.Application__c != null){
                List<Id> lstReviewsApp = applicationReviewMap.get(appReview.Application__c);    
                if(lstReviewsApp == null){
                    lstReviewsApp = new List<Id>();
                    applicationReviewMap.put(appReview.Application__c,lstReviewsApp);   
                }  
                if(String.isNotEmpty(appReview.ReviewComments__c)){
                    lstReviewsApp.add(appReview.Id);
                } 
            }
        }

        List<Id> lstPreApplication = new List<Id>();
        List<Id> lstApplication = new List<Id>();
        System.debug(' Pre Application keyset is '+preApplicationReviewMap);
        System.debug('  Application keyset is   '+applicationReviewMap);

        for( Id key : preApplicationReviewMap.keySet()){
            List<Id> lstReviews = preApplicationReviewMap.get(key);
            if(lstReviews.size() >= preAppReviewsCount)
                lstPreApplication.add(key); 
        }

        for( Id key : applicationReviewMap.keySet()){
            List<Id> lstReviews = applicationReviewMap.get(key);
            System.debug('The list of reviews is '+lstReviews); 
            System.debug('The list of reviews is '+lstReviews.size());
            System.debug('The list of reviews is '+appReviewsCount);
            System.debug('The list of reviews is '+(lstReviews.size() >= appReviewsCount));
            if(lstReviews.size() >= appReviewsCount)
                lstApplication.add(key);  
        }

        System.debug('List of PReApplications is '+ lstPreApplication); 
        System.debug('List of Applications is '+ lstApplication);

        List<PreApplication__c> lstPreAppstoUpdate = [Select Status__c from PreApplication__c where Id in: lstPreApplication];
        List<Application__c> lstAppstoUpdate = [Select Status__c from Application__c where Id in: lstApplication];

        System.debug(' Pre Application keyset is '+lstPreAppstoUpdate);
        System.debug('  Application keyset is   '+lstAppstoUpdate);

        for(PreApplication__c preapp: lstPreAppstoUpdate){
            preapp.Status__c = 'Reviewed';
        }

        for(Application__c app : lstAppstoUpdate){
            app.Status__c = 'Reviewed'; 
        }

        if(lstPreAppstoUpdate != null){
            update lstPreAppstoUpdate;
        }

        if(lstAppstoUpdate != null){ 
            update lstAppstoUpdate; 
        }
    }  




      private void updateGrantorApplication(List<ApplicationReview__c> lstApplicationReview){ 

        System.debug('The list of application is '+lstApplicationReview);

        Map<Id,List<Id>> applicationReviewMap = new Map<Id,List<Id>>(); 

        Integer appReviewsCount = 1;

        Set<Id> applicationId = new Set<Id>();

        for(ApplicationReview__c app: lstApplicationReview){

            if(app.FOALead__c != null){
                continue;
            }

             if(app.Application__c != null){
                applicationId.add(app.Application__c); 
            }
        }   

        if(applicationId.size() == 0){
            return;
        }

         List<ApplicationReview__c> lstAppReview = [Select Id,ReviewComments__c,Application__c from ApplicationReview__c where Application__c in: applicationId];

        System.debug(' lstAppReview Count '+lstAppReview);

     
        for(ApplicationReview__c appReview : lstAppReview){     
            if(appReview.Application__c != null){
                List<Id> lstReviewsApp = applicationReviewMap.get(appReview.Application__c);    
                if(lstReviewsApp == null){
                    lstReviewsApp = new List<Id>();
                    applicationReviewMap.put(appReview.Application__c,lstReviewsApp);   
                }  
                if(String.isNotEmpty(appReview.ReviewComments__c)){
                    lstReviewsApp.add(appReview.Id);
                } 
            }
        }

        List<Id> lstApplication = new List<Id>();
        System.debug('  Application keyset is   '+applicationReviewMap);

   
        for( Id key : applicationReviewMap.keySet()){
            List<Id> lstReviews = applicationReviewMap.get(key);
            if(lstReviews.size() >= appReviewsCount)
                lstApplication.add(key);  
        }

        System.debug('List of Applications is '+ lstApplication);

       List<Application__c> lstAppstoUpdate = [Select Status__c from Application__c where Id in: lstApplication];

      

        for(Application__c app : lstAppstoUpdate){
            app.Status__c = 'Internally Reviewed'; 
        }

     
        if(lstAppstoUpdate != null){ 
            update lstAppstoUpdate; 
        }
    }  

}