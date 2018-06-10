/*
    This trigger has methods to execute methods related to Contact Trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-05-27   Nakul Kadam       Created 
    **********************************************************  
*/
trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
    new ContactTriggerHelper().process();
}