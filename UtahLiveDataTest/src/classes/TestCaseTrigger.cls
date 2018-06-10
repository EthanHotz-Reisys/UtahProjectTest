@isTest
public class TestCaseTrigger{
 static testMethod void method(){
CaseTriggerHelper.skipTrigger = true;
	Case__c ca = new Case__c();
insert ca;
}
}