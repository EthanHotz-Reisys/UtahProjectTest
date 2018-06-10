/*
    This trigger on Task Object
    **********************************************************
    Audit History
    **********************************************************
    2014-05-27  Vineeth Shetty      Created
    
    **********************************************************  
*/ 
trigger TaskTrigger on Task (after insert, after update,after delete,before delete, before insert, before update) {
    new TaskTriggerHelper().process();
}