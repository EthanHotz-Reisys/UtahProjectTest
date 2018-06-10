trigger AccountTrigger on Account (before insert,after insert,before update,after update,before delete, after delete) {
    if(!AppUtils.skipAccountTrigger) { 
        new AccountTriggerHelper().process();
    }    
}