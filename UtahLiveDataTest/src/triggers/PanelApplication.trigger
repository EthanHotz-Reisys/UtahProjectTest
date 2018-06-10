/*
11/13/2014    Nakul     Created
*/
trigger PanelApplication on PanelApplication__c (before insert,after insert,before delete,after delete) {
    new PanelApplicationTriggerHelper().process();
}