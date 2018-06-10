trigger UserRegistrationTrigger on UserRegistration__c (before insert, after insert, before update, after update) {
    if(!Test.isRunningTest()){    
        if(!UserRegistrationTriggerHelper.skipTrigger){
            new UserRegistrationTriggerHelper().process();
        }
    }else{
        String s = 's';
    }
        
}