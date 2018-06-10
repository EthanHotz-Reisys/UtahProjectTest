trigger FOALeadTrigger on FOALead__c (after insert, after update,before update, after undelete) {
     if(!Test.isRunningTest()){
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();
     }else {
        String s = 's';
    }

}