@isTest
public class TestCampaignTrigger{
 static testMethod void method(){

//GNT__SobjectConfig__c s = new GNT__SobjectConfig__c(Name='Test');
 //insert s;
 Campaign__c c = new Campaign__c ();
 c.StartDate__c = System.today();
 
 c.EndDate__c =System.today()+30;
 c.Subject__c='test';
 insert c;

  }
}