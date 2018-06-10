trigger PreapplicationTrigger on Preapplication__c (before insert, after insert,before update, after update, before delete) {    
        new PreApplicationTriggerHelper().process();
}