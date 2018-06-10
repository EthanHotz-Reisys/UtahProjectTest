/*
    Content to Populate the What's New Section on the Login Page is
    queried here.
    ***********************************************************
    Audit History
    ***********************************************************
    03/06/2014      Vineeth Shetty             Created
    2017-09-21        Shah Kadirmohideen            Code Reviewed
    *********************************************************** 
*/
public with sharing class LoginWhatsNewCtrl {
    public List<Announcement__c> extendedAnnouncementList {get;set;}
    public List<Announcement__c> minAnnouncementList {get;set;}
    public Integer minItemsCount {get;set;}
    public Integer actualItemCount {get;set;}
    public String namespace{get;set;}
    
    public LoginWhatsNewCtrl(){
        minAnnouncementList = new List<Announcement__c>();
        extendedAnnouncementList = new List<Announcement__c>();
        minItemsCount = 0;
        actualItemCount = 0;
        initialize();
        namespace = AppUtils.getNamespacePrefix();
    }
    
    /*
        Method Queries the Announcement Object to fetch the latest Announcements ordered by Created Date 
    */
    public void initialize(){
       //Number of Announcment Items to display when VIEW ALL is clicked
        Integer maxItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('WhatsNewExpandedItemsCount', true);
        //Number of Announcement Items to display by default
        minItemsCount = GNT.KeyValueStoreHelper.getIntegerValue('WhatsNewVisibleItemsCount', true);
        //Number of characters allowed to display for each What's New Item
        Integer whatsNewCharacterCount = GNT.KeyValueStoreHelper.getIntegerValue('WhatsNewCharacterCount', true); 
        Integer i = 0;
        
        List<Announcement__c> AnnouncementList = new List<Announcement__c>();
       AnnouncementList = [Select Id, AnnouncementName__c,AnnouncementDescription__c, ApplicationDeadlineWithDateTime__c,CreatedDate 
            from Announcement__c where Status__c  = 'Active' AND AnnouncementType__c = 'New' order by LastModifiedDate DESC LIMIT :maxItemsCount];
        actualItemCount = AnnouncementList.size();       
        
        
        for(Announcement__c announcementInstance : AnnouncementList){
            Announcement__c updatedAnnouncement = new Announcement__c();
            
            if(announcementInstance.AnnouncementName__c != null){
                if(announcementInstance.AnnouncementName__c.length() > whatsNewCharacterCount){
                    updatedAnnouncement.AnnouncementName__c = announcementInstance.AnnouncementName__c.substring(0 , whatsNewCharacterCount) + '...';
                }
                else{
                    updatedAnnouncement.AnnouncementName__c = announcementInstance.AnnouncementName__c;
                }
            }
             updatedAnnouncement.ApplicationDeadlineWithDateTime__c = announcementInstance.ApplicationDeadlineWithDateTime__c;
            updatedAnnouncement.Id = announcementInstance.Id;
                
            if(i < minItemsCount){
                minAnnouncementList.add(updatedAnnouncement);
            }
            else{
                extendedAnnouncementList.add(updatedAnnouncement);
            }
            i++;
        } 
                        
    }
}