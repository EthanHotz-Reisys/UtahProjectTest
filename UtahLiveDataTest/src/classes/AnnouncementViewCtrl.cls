public with sharing class AnnouncementViewCtrl {
    
    //Properties Please configure template.
    public  ID recordId{get;set;}
    public  ID programId {get;set;}
    private Boolean rfaParameter;
    public  string templateName {get;set;}
    public  string packageName {get;set;}
    public boolean isExternal {get;set;}
    public boolean isGuest {get; set;}
    private String annType,programName ;
    boolean isInternal;
    public Boolean hideSideBar {get;set;}
    public AnnouncementViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        User u = [SELECT id,Name,IsExternalUser__c, UserType FROM User WHERE Id=:UserInfo.getUserId()];
        isGuest = u.UserType == 'Guest';
        hideSideBar = (u.UserType == 'Guest') ? true : false;
        if(u.IsExternalUser__c == true){
            isExternal = true;
            isInternal = false;
        }else{
            isExternal = false;
            isInternal = true; 
        }
        Announcement__c ann = [select RFARequired__c, Program__c,Program__r.Name,AnnouncementType__c, Program__r.Account__r.Name from Announcement__c where id=:recordId limit 1];
        if(isExternal == true){
               String view = ApexPages.CurrentPage().getParameters().get('view');
               programId = ann.Program__c;
               if(view!=null){
                 templateName = 'QualifiedAnnoucementExternalGrantor';
               }
               else{
                templateName = 'AnnoucementExternalGrantor';
               }            
        } else if(isGuest == true){
           templateName = 'PublicAnnouncementDetails';
        }
        else
         {
          packageName = null;
          programId = ann.Program__c;
          programName = ann.Program__r.Name;
          rfaParameter=ann.RFARequired__c;
          annType=ann.AnnouncementType__c;
          if(ann.Program__r.Account__r.Name == 'USBE'){
            templateName = 'USBE Announcement';
            }else{
              if(annType!=null && annType=='Sole Source/Directed'){
                        templateName = 'Announcement-Internal Grantor-Sole Source';
                }else if(rfaParameter!=null && !rfaParameter){  // If RFA does not need to be shown
                    templateName = 'Announcement-Internal Grantor-FOA';
                }
                else{
                    templateName = 'Announcement-Internal Grantor';
                }
            }
            String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
            if(appName != null && appName == 'StateAsGrantee'){
                templateName = 'AnnouncementGrantee';
            }
           
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();

        String announcementid = ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('announcementId',announcementid); 
        keyValueMap.put('programId',programId);
        keyValueMap.put('programid',programId);
        keyValueMap.put('programName',programName);        
        System.debug('programid----------------------->' + programId);
        keyValueMap.put('UserId',UserInfo.getUserId());    
        Id recTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        keyValueMap.put('recTypeAppId',(String)recTypeIdApp);
        Id recTypeIdPreapp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        keyValueMap.put('recTypePreAppId',(String)recTypeIdPreapp ); 
         
        List<TaskSchedule__c> taskScheduleList = Database.query('SELECT Id FROM TaskSchedule__c WHERE ParentId__c LIKE \'' +announcementid +'%\'');
        if(taskScheduleList.size() > 0){
            keyValueMap.put(AppUtils.getNamespacePrefix() + 'TaskSchedule__c',taskScheduleList[0].Id);
        }
        System.debug('announcementId----'+announcementId);
        List<Announcement__c> announcementList  = [SELECT Id,ScheduleManager__c FROM Announcement__c WHERE Id=:announcementid];
        System.debug('announcementList----'+announcementList);
        keyValueMap.put(AppUtils.getNamespacePrefix() +'AssignedTo__c',announcementList[0].ScheduleManager__c);     
		//keyValueMap.put('showToQueue',false+'');

       // Setting Funding Sources List
     //  keyValueMap.put('fundingSourcesList','a1D37000000c2CXEAY');

        return JSON.serialize(keyValueMap);
    }
    public string getListParams(){
        Map<String,List<String>> listParams = new Map<String,List<String>>();
        String announcementid = ApexPages.currentPage().getParameters().get('id');
        if(announcementid != null && announcementid != ''){
            Map<Id,ReviewGroup__c> reviewGroupsMap = new Map<Id,ReviewGroup__c>([SELECT Id FROM ReviewGroup__c WHERE Announcement__c =:announcementid]);
            List<String> reviewGroupIdsList = new List<String>();
            for(Id rgId:reviewGroupsMap.keySet()){
                reviewGroupIdsList.add((String)rgId);    
            }
            listParams.put('reviewGroupIdsList',reviewGroupIdsList);
        }

        return JSON.serialize(listParams);
    }
    
     public void updateStatus(){
        EventHandlerCtrl ctrl = new EventHandlerCtrl();
        ctrl.updateStatus();
    }
}