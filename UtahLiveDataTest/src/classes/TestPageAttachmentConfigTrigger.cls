@isTest
public class TestPageAttachmentConfigTrigger{
 static testMethod void method(){

//GNT__SobjectConfig__c s = new GNT__SobjectConfig__c(Name='Test');
 //insert s;

GNT__PageLayoutConfig__c pl = new GNT__PageLayoutConfig__c ();
pl.GNT__Description__c='Test'; 
pl.GNT__ObjectAPIName__c = 'Program__c';
insert pl;

 GNT__TabConfig__c p =new GNT__TabConfig__c();
 p.GNT__PageLayoutConfig__c = pl.Id; 
 p.GNT__SortOrder__c=5;
 p.GNT__StandardTabName__c ='Test';
 insert p;
 GNT__PageBlockConfig__c b = new GNT__PageBlockConfig__c();
 b.GNT__TabLayoutConfig__c =p.Id;
 b.GNT__SortOrder__c = 3;
 insert b;
 GNT__PageAttachmentConfig__c kc = new GNT__PageAttachmentConfig__c();
 kc.GNT__PageBlockConfig__c =b.Id;
 
 insert kc;

  }
}