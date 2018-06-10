trigger ApplicationServiceAreaTrigger on ApplicationServiceArea__c (after insert, after update, after undelete,after delete) {
   /* Pranjali: The below lines are commented because they did not make correct call to the trigger helper */
   // GNT.TriggerHelper th = new GNT.TriggerHelper ();
   // th.setInternalUniqueID();
       new ApplicationServiceAreaTriggerHelper().Process();
}