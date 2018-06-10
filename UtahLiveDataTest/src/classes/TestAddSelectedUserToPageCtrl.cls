@isTest
public class TestAddSelectedUserToPageCtrl {
	@isTest
    public static void test() {
        User u = TestHelper.getAdminUser(true);
        System.runAs(u) {
       
            Test.startTest();
            AddSelectedUserToPageCtrl ac = new AddSelectedUserToPageCtrl();
            ac.getListParameters();
            Test.stopTest();
            System.assert(ac!=null);
        }
    }
}