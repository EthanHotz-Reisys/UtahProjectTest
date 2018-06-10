trigger AccordionHeaderConfigTrigger on GNT__AccordionHeader__c (before insert, before update, after undelete) {
    GNT.TriggerHelper th = new GNT.TriggerHelper ();
    th.setInternalUniqueID();

}