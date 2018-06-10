@isTest
private with sharing class TestRecommendedAnnouncementsExternalCtrl {
    @isTest
    private static void testRecommendedAnnouncementsExternalCtrl(){
        User u=TestHelper.getAdminUser(true);
        system.runAs(u){
            Test.startTest();
            RecommendedAnnouncementsExternalCtrl raec=new RecommendedAnnouncementsExternalCtrl();
            system.assertNotEquals(raec.getKeyValueMap(),null); 
            Test.stopTest();
        }
    } 
}