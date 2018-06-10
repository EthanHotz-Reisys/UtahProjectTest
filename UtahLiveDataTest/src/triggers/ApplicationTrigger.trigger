/*
    This trigger is created for applying the Name to the Application object
    **********************************************************
    Audit History
    **********************************************************
    2014-03-04  Vinayak Sharma      Created
    
    **********************************************************  
*/ 


trigger ApplicationTrigger on Application__c (before insert,after insert,before update, after update, before delete,after delete) {
    List<Application__c> appListUSBE = new List<Application__c>();
    List<Application__c> appListUOVC = new List<Application__c>();
    List<Application__c> appList = new List<Application__c>();
    
    if (Trigger.isDelete) {
        for (Application__c appIterator : Trigger.Old) {
            if (appIterator.GrantorOrganizationName__c == 'USBE') {
                appListUSBE.add(appIterator);
            }
            else if (appIterator.GrantorOrganizationName__c == 'UOVC') { //If UOVC, can add more elseif in the case of more agencies being added and we want to expand the trigger
                appListUOVC.add(appIterator);
            }
            else {
                appList.add(appIterator);
            }
        }
    }
    else {
        for (Application__c appIterator : Trigger.New) {
            if (appIterator.GrantorOrganizationName__c == 'USBE') {
                appListUSBE.add(appIterator);
            }
            else if (appIterator.GrantorOrganizationName__c == 'UOVC') { //If UOVC, can add more elseif in the case of more agencies being added and we want to expand the trigger
                appListUOVC.add(appIterator);
            }
            else {
                appList.add(appIterator);
            }
        }
    }
    if (appListUSBE.size() > 0) {
        new ApplicationTriggerHelperUSBE().process();
    }
    else if (appListUOVC.size() > 0) {
        new ApplicationTriggerHelperUOVC().process();
    }
    else {
        new ApplicationTriggerHelper().process();
    }
}