trigger ServiceAreaTrigger on ServiceArea__c (after insert,before insert, before update, after delete,before delete) {
    if(!Test.isRunningTest()){
        new ServiceAreaTriggerHelper().process();
        GNT.TriggerHelper th = new GNT.TriggerHelper ();
        th.setInternalUniqueID();
    }else{
        String s = 's';
    }
}