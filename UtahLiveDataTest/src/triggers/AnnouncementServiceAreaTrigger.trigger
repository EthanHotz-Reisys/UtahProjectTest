trigger AnnouncementServiceAreaTrigger on AnnouncementServiceArea__c (before insert, before update, after undelete, before delete) {
   
   new AnnouncementServiceAreaTriggerHelper().process();

}