/*
    Trigger for Program Object
    ***********************************************************
    Audit History
    ***********************************************************
    26/02/2014      Kunal Shah             Created
    03/06/2014      Vineeth Shetty         Modified
    *********************************************************** 
*/
trigger ProgramTrigger on Program__c ( before insert, before update, before delete,after update, after insert) {
    List<Program__c> programListUSBE = new List<Program__c>();
    List<Program__c> programListUOVC = new List<Program__c>();
    List<Program__c> programList = new List<Program__c>();
    
    if (Trigger.isDelete) {
        for (Program__c programIterator : Trigger.Old) {
            if (programIterator.OrganizationName__c  == 'USBE') {
                programListUSBE.add(programIterator);
            }
            else if (programIterator.OrganizationName__c  == 'UOVC') {
                programListUOVC.add(programIterator);
            }
            else {
                programList.add(programIterator);
            }
        }
    }
    else {
        for (Program__c programIterator : Trigger.New) {
            if (programIterator.OrganizationName__c  == 'USBE') {
                programListUSBE.add(programIterator);
            }
            else if (programIterator.OrganizationName__c  == 'UOVC') {
                programListUOVC.add(programIterator);
            }
            else {
                programList.add(programIterator);
            }
        }
    }

    if(!ProgramTriggerHelper.skipTrigger) {
        if (programListUSBE.size() > 0) {
            new ProgramTriggerHelperUSBE().process();
        }
        else if (programListUOVC.size() > 0) {
            new ProgramTriggerHelperUOVC().process();
        }
        else {
            new ProgramTriggerHelper().process();   
        }
    }
}