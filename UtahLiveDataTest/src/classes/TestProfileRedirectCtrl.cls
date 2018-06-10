@isTest
private class TestProfileRedirectCtrl {
    @isTest
    static void testEmptyConstructor() {
    AccountTriggerHelper.skipTrigger = true;
        test.startTest();
        ProfileRedirectCtrl prc = new ProfileRedirectCtrl();
        test.stopTest();        
    }
    @isTest
    static void testConstructor() {
        String userId = '000000000000000000';
        PageReference vfPage = new PageReference('/apex/profileRedirect');
        vfPage.getParameters().put('id', userId);
        system.Test.setCurrentPage(vfPage);
        test.startTest();
        ProfileRedirectCtrl prc = new ProfileRedirectCtrl();
        test.stopTest();
    }
    @isTest
    static void testProfileRedirectWithNoData() {
        test.startTest();
        ProfileRedirectCtrl prc = new ProfileRedirectCtrl();
        PageReference newReference = prc.ProfileRedirect();
        test.stopTest();
        System.assert(newReference == null);
    }

    @isTest
    static void testProfileRedirectWithStandardUser() {
        String userId = TestHelper.getStandardUser(true).id;
        PageReference vfPage = new PageReference('/apex/profileRedirect');
        vfPage.getParameters().put('id', userId);
        system.Test.setCurrentPage(vfPage);
        test.startTest();
        ProfileRedirectCtrl prc = new ProfileRedirectCtrl();
        PageReference newReference = prc.ProfileRedirect();
        test.stopTest();
        PageReference cmpReference = new PageReference('/apex/' + AppUtils.getNamespacePrefix() + 'myProfileView?id=' + userId);
        System.assert(newReference.getUrl() == cmpReference.getUrl());
        System.assert(newReference.getParameters().get('id') == cmpReference.getParameters().get('id'));
    }
    @isTest
    static void testProfileRedirectWithPortalUser() {
    /*
        AccountTriggerHelper.skipTrigger = true;
        UserTriggerHelper.skipTrigger = true;
        User tmpUser = TestHelper.getPortalUser(true);
        
        PageReference vfPage = new PageReference('/apex/profileRedirect');
        vfPage.getParameters().put('id', tmpUser.id);
        system.Test.setCurrentPage(vfPage);
        test.startTest();
        ProfileRedirectCtrl prc = new ProfileRedirectCtrl();
        PageReference newReference = prc.ProfileRedirect();
        test.stopTest();
        PageReference cmpReference = new PageReference('/apex/' + AppUtils.getNamespacePrefix() + 'communityUserProfileView?id=' + tmpUser.ContactId);
    
        System.assert(newReference.getUrl() == cmpReference.getUrl());
        System.assert(newReference.getParameters().get('id') == cmpReference.getParameters().get('id'));
        
        */
    }
}