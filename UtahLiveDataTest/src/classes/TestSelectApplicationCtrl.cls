@isTest(SeeAllData=false)
private class TestSelectApplicationCtrl {
    
    @isTest static void testAll() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        AccountTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        System.runAs(u){
            GNT.UserPreferenceHelper.setStringValue('ActiveAppName__c','StateasGrantor');
            UserRole ur=new UserRole();
            ur.Name= 'ENTERPRISE';
            insert ur;
            u.UserRoleId = [Select Id From UserRole Where Name = 'ENTERPRISE' Limit 1].Id;
            update u;
            SelectApplicationCtrl sap = new SelectApplicationCtrl();
            sap.clickHandler();
            SelectApplicationCtrl.getFoType();
            SelectApplicationCtrl.getBudgetPeriodType();
            SelectApplicationCtrl.getBudgetCatType();
            Account child = TestHelper.getAccount(true);
            Account parent = TestHelper.getAccount(true);
            child.Parent = parent;
            update child;
            SelectApplicationCtrl.getBureaus(child.Parent.id);
            Program__c program = TestHelper.getProgram(child.Id, true);
            SelectApplicationCtrl.getOrganization(program.Id);

            ServiceArea__c sa = TestHelper.getServiceArea(true);
            ServiceArea__c csa = TestHelper.getServiceArea(true);
            
            sa.CoreServiceArea__c = csa.Id;
            sa.CoreServiceArea__r = csa;
            update sa;
            ProgramServiceArea__c psa = TestHelper.getProgramServiceArea(true, program.Id, sa.Id);
            psa.ServiceArea__r = sa;
            update psa;
            SelectApplicationCtrl.getCoreServiceArea(program.Id);
            SelectApplicationCtrl.getServiceArea(program.Id, csa.Name);

            Announcement__c ann = TestHelper.getAnnouncement(true);
            Application__c app = TestHelper.getApplication(ann.Id, true);
            Announcement__c fo = TestHelper.getAnnouncement(true);
            OpportunityQualification__c oq = new OpportunityQualification__c();
            oq.FundingOpportunity__c = fo.Id;
            insert oq;
            SelectApplicationCtrl.saveAndContinue(app.Id, oq.Id);
            SelectApplicationCtrl.getAllPrograms();


        }
        */
    }
    
    @isTest static void testGetServiceArea() {
    /*
        UserTriggerHelper.skipTrigger = true;
        User u = TestHelper.getAdminUser(true);
        AccountTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelper.skipTrigger = true;
        RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
        System.runAs(u){
                Account child = TestHelper.getAccount(true);
                Program__c program = TestHelper.getProgram(child.Id, true);

                ServiceArea__c sa = TestHelper.getServiceArea(true);
                ServiceArea__c csa = TestHelper.getServiceArea(true);
                sa.CoreServiceArea__r = csa;
               // sa.CoreServiceArea__c = csa;
                update sa;
                ProgramServiceArea__c psa = TestHelper.getProgramServiceArea(true, program.Id, sa.Id);
                psa.ServiceArea__r = sa;
                update psa;
                SelectApplicationCtrl.getServiceArea(program.Id, csa.Name);
        }
        */
    }
    
}