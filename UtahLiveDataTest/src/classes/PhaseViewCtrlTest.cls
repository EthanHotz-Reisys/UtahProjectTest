@isTest
public class PhaseViewCtrlTest {

    public static testMethod void test() {
         Cookie counter =  new Cookie('govgrants_tabname','TestPhase',null,-1,false);
         ApexPages.currentPage().setCookies(new Cookie[]{counter});
         Test.startTest();
         GNT__CustomApp__c cap = new GNT__CustomApp__c();
         cap.Name = 'StateasGrantor';
         cap.GNT__Active__c = True;
         insert cap;
         GNT__PhaseConfig__c phase=TestHelper.getPhase(false);
         phase.GNT__CustomAppName__c =cap.Name;
         phase.Name = 'TestPhase';
        phase.GNT__TabName__c='PLANNING';
        phase.GNT__URL__c = '/apex/planning';
        phase.GNT__GroupName__c='2';
        phase.GNT__Sequence__c=2;
        phase.GNT__Abbreviation__c ='PL';
        phase.GNT__SObject__c = 'Accouncement__c;Program__c;Package__c'; 
        phase.GNT__AccordionHeader__c = 'Planning';
        phase.GNT__EnableSearch__c = true;
        phase.GNT__SidebarSearchLabel__c = 'Search';
        phase.GNT__SidebarRecentlyViewedLabel__c = 'Recently Viewed';
        phase.GNT__SidebarExternalLinksLabel__c = 'External Links';     
        phase.GNT__SearchResultPage__c ='/apex/planning';
        phase.GNT__SidebarComponentSequence__c = 'Search,Links,RecentlyViewed,SubMenu';
        phase.GNT__EnableExternalLinks__c = true;
     phase.GNT__FlexTableParameters__c = 'orgType=Organization';
        phase.GNT__Active__c= true;
        phase.GNT__PhaseType__c = 'Phase';
        phase.GNT__SelectedByDefault__c = true;
         insert phase;
         PhaseViewCtrl objCls = new PhaseViewCtrl();
         objCls.getDisplayFlexTable();
         objCls.getKeyValueMap();
         objCls.getKeyValueMap1();
         Test.stopTest();
         
    }

}