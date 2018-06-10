@isTest
private class TestAddSiteVisitPersonstoReport {

    static testMethod void myUnitTest() {
        
        AccountTriggerHelper.skipAll = true;
        GrantTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            
            
            UserTriggerHelper.skipTrigger = true;
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(u.id);
            SiteVisit__c sitevisit = TestHelper.getSiteVisit(false);
            sitevisit.VisitEndDateTime__c = System.today() - 1;
            insert sitevisit;
            SiteVisitPerson__c sitevisitperson = new SiteVisitPerson__c(User__c = u.id,SiteVisit__c = sitevisit.id);
            insert sitevisitperson;
            ApexPages.currentPage().getParameters().put('Id', sitevisit.Id);
            
            Map<String,String> urlParams = new Map<String,String>();
            AddSiteVisitPersonsToReport addsitevisitperson = new AddSiteVisitPersonsToReport();
            addsitevisitperson.selectedRecordIds = selectedRecordIds;
            urlParams.put('id',sitevisit.Id);
            urlParams.put('tabName','tabname');
            urlParams.put('userType','User');
            addsitevisitperson.urlParams = urlParams;
            addsitevisitperson.clickHandler();           
        }
    
        }
        static testMethod void myUnitTest1() {
        
        AccountTriggerHelper.skipAll = true;
        GrantTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
            
            UserTriggerHelper.skipTrigger = true;
            Contact con = testHelper.getcontact(true);
            List<String> selectedRecordIds = new List<String>();
            selectedRecordIds.add(con.id);
            SiteVisit__c sitevisit = TestHelper.getSiteVisit(false);
            sitevisit.VisitEndDateTime__c = System.today() - 1;
            insert sitevisit;
            SiteVisitPerson__c sitevisitperson = new SiteVisitPerson__c(Contact__c = con.id,SiteVisit__c = sitevisit.id);
            insert sitevisitperson;
            ApexPages.currentPage().getParameters().put('Id', sitevisit.Id);
            
            Map<String,String> urlParams = new Map<String,String>();
            AddSiteVisitPersonsToReport addsitevisitperson = new AddSiteVisitPersonsToReport();
            addsitevisitperson.selectedRecordIds = selectedRecordIds;
            urlParams.put('id',sitevisit.Id);
            urlParams.put('tabName','tabname');
            urlParams.put('userType','Contact');
            addsitevisitperson.urlParams = urlParams;
            addsitevisitperson.clickHandler();           
        }
    
        }
    }