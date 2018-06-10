@isTest
private with sharing class TestUSPSAddress{
      
        @isTest  
        private static void testAll(){            
            user u = TestHelper.getAdminUser(true);
            system.runAs(u){
                Test.startTest();            
                    USPSAddress ctrl = new USPSAddress();
                    Boolean hasDataResult = ctrl.hasData();
                    USPSAddress ctrl_1 = new USPSAddress();
                            ctrl_1.Address1='test_1';                     
                            Boolean hasDataResult_1 = ctrl_1.hasData();
                    USPSAddress ctrl_2 = new USPSAddress();
                          ctrl_2.Address2='test_2';                         
                          Boolean hasDataResult_2 = ctrl_2.hasData();
                          ctrl_2.Address1='test_1';
                          Boolean hasDataResult_2_2 = ctrl_2.hasData();
                    USPSAddress ctrl_3 = new USPSAddress();
                           ctrl_3.City='test_3';
                          Boolean hasDataResult_3 = ctrl_3.hasData();
                   USPSAddress ctrl_4 = new USPSAddress();
                        ctrl_4.State='test_4';
                        Boolean hasDataResult_4 = ctrl_4.hasData();
                   USPSAddress ctrl_5 = new USPSAddress();
                        ctrl_5.Zip5='test_5';
                          Boolean hasDataResult_5 = ctrl_5.hasData();
                  USPSAddress ctrl_6 = new USPSAddress();
                        ctrl_6.Zip4='test_6';
                          Boolean hasDataResult_6 = ctrl_6.hasData();
                  USPSAddress ctrl_7 = new USPSAddress();
                        ctrl_7.USPS_Returned_Error=true;
                          Boolean hasDataResult_7 = ctrl_7.hasData();
                  USPSAddress ctrl_8 = new USPSAddress();
                        ctrl_8.USPS_ERROR_CODE='test_8';
                          Boolean hasDataResult_8 = ctrl_8.hasData();        
                 USPSAddress ctrl_9 = new USPSAddress();
                        ctrl_9.USPS_ERROR_DESC='test_9';
                          Boolean hasDataResult_9 = ctrl_9.hasData(); 
                  USPSAddress ctrl_10 = new USPSAddress();
                        ctrl_10.USPS_ERROR_SOURCE='test_10';
                          Boolean hasDataResult_10 = ctrl_10.hasData();     
                Test.stopTest();
                system.assert(ctrl != null);
            }
        }
}