trigger FormTrigger on Form__c (after insert, before update, after update) {
     new FormTriggerHelper().process();

}