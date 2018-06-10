@isTest
public class TestGNTApprovalDecisionActionConfig{
 static testMethod void method(){

GNT__SobjectConfig__c s = new GNT__SobjectConfig__c(Name='Test');
 insert s;
 GNT__ApprovalDecisionActionConfig__c ad =new GNT__ApprovalDecisionActionConfig__c();
 ad.GNT__SobjectConfig__c = s.id;
 insert ad ; 
  }
}