/*
    Trigger for Announcement Object
    ***********************************************************
    Audit History
    ***********************************************************
    03/06/2014      Vineeth Shetty             Created
    30/11/2015      Pankaj H.                  Added Trigger skip check
    *********************************************************** 
*/
trigger AnnouncementTrigger on Announcement__c (before insert, after insert, before update, after update,before delete) {
    
    List<Announcement__c> UOVCAnnouncement = new List<Announcement__c>();
    List<Announcement__c> USBEAnnouncement = new List<Announcement__c>();

    if(Trigger.isInsert){
        for(Announcement__c announcement : Trigger.new){
            if(announcement.OrganizationName__c == 'USBE'){    
                USBEAnnouncement.add(announcement);
            }else{
                UOVCAnnouncement.add(announcement);
            }
        }
    }else{
        for(Announcement__c announcement : Trigger.old){
            if(announcement.OrganizationName__c == 'USBE'){    
                USBEAnnouncement.add(announcement);
            }else{
                UOVCAnnouncement.add(announcement);
            }
        }
    }

    if( !AppUtils.skipAnnoucementTrigger ){
        if(UOVCAnnouncement.size() > 0){    
            new AnnouncementTriggerHelper().process();
        }else if(USBEAnnouncement.size() > 0){
            new USBEAnnouncementTriggerHelper().process();
        }
    }
}