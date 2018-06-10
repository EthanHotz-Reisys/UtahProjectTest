/**
    **********************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-09-21        Shah Kadirmohideen            Code Reviewed
    **********************************************************************************************************************  
*/ 
public with sharing class LoginTrendsCtrl {
    public Integer announcementCount {get;set;}
    public Integer programCount {get;set;}
    
    public LoginTrendsCtrl(){
        announcementCount = 0;
        programCount = 0;
        
        initialize();
    }
    
    public void initialize(){
        //Shah CRF: Use custom settings to track the announcements and programs instead of counting like this
        announcementCount = [SELECT count() FROM Announcement__c Where Status__c = 'Active' AND AnnouncementType__c = 'New' LIMIT 25000];
        system.debug('announcementCount----------->>>'+announcementCount);
        programCount = [SELECT count() FROM Program__c Where Status__c = 'Active' LIMIT 25000];
    }
}