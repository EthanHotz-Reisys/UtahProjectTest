@isTest
public class GrantViewCtrlTest {
    static testMethod void someTest() {
    
         GNT.TriggerHelper.skipTrigger=true;
         GrantTriggerHelper.skipTrigger=true;
         //SiteVisit__c sv = GNT.TestHelper.getSiteVisit(true);    
         //ApexPages.StandardController sc = new ApexPages.standardController(sv);
         //ApexPages.currentPage().getParameters().put('id',sv.Grant__c);
         GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantee');
         Grant__c grnts = new Grant__c();
         grnts.ProjectPeriodStartDate__c=Date.newInstance(2015,3,14);
         grnts.ProjectPeriodEndDate__c=Date.newInstance(2016,3,14);
         grnts.IssueDate__c=Date.newInstance(2014,3,14);
         insert grnts;
         ApexPages.StandardController sc = new ApexPages.standardController(grnts);
         ApexPages.currentPage().getParameters().put('id',grnts.Id);
         GrantViewCtrl e = new GrantViewCtrl(sc);
         e.getKeyValueMap();
    }
     
}