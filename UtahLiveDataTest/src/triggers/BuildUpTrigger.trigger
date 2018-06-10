trigger BuildUpTrigger on BuildUpItem__c  (after insert,after update,before delete,after delete ) {
   new BuildUpItemTriggerHelper().process();
}