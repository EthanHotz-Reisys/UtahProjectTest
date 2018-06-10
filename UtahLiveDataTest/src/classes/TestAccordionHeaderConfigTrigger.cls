@isTest
public class TestAccordionHeaderConfigTrigger {
    static testMethod void method(){
        
        GNT__CustomApp__c cap = new GNT__CustomApp__c();
        cap.Name='test';
        cap.GNT__Active__c = True;
        insert cap;
       GNT__PhaseConfig__c p =new GNT__PhaseConfig__c(Name='test');
       p.GNT__PhaseType__c = 'Phase';
       p.GNT__Abbreviation__c = 'DSS';
       p.GNT__CustomAppName__c = cap.Name;
       p.GNT__URL__c = 'urslkj';
        p.GNT__GroupName__c = 'test';
        p.GNT__TabName__c='test';
        p.GNT__Sequence__c = 9;
        
        insert p;
      // GNT__Sequence__c c = new GNT__Sequence__c();T
         
        
        GNT__AccordionHeader__c ac = new GNT__AccordionHeader__c();
        ac.GNT__PhaseConfig__c = p.Id;
        ac.GNT__Sequence__c=9;
        
       
        insert ac;
    }

}