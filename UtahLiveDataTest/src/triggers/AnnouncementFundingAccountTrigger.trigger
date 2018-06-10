trigger AnnouncementFundingAccountTrigger on AnnouncementFundingAccount__c (before insert, before update, after undelete, after insert, after delete) {
  //  GNT.TriggerHelper th = new GNT.TriggerHelper ();
   // th.setInternalUniqueID();


    new AnnouncementFundingAccountTriggerHelper().process();

}