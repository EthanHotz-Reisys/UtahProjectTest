@isTest
private with sharing class TestProcessLogging{
    static testMethod void testInsertIntegrationHeader() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){   
              List<String> resp = new List<String>();
              resp.add('Process API Url');
              
              Test.startTest();
              ApexPages.currentPage().getHeaders().put('True-Client-IP', 'Test123');
              ProcessLogging ctrl = new ProcessLogging();
              Id headerId = ctrl.InsertIntegrationHeader('User Registration','Not Found');
              ctrl.InsertIntegrationDetail(headerId,resp,u.Id);
              ctrl.InsertIntegrationHeader(null,null);
              Test.stopTest();
          }
        
    }
    
        static testMethod void testInsertIntegrationHeader2() {
       
          User u = TestHelper.getAdminUser(true);
          System.runAs(u){   
              List<String> resp = new List<String>();
              string year = '2016';
              string month = '08';
              string day = '5';
              string hour = '12';
              string minute = '20';
              string second = '20';
              string stringDate = year + '-' + month+ '-' + day + ' ' + hour + ':' +minute + ':' + second;

              resp.add('Process API Url');
              resp.add('Agency Name');
              resp.add('In Progress');
              resp.add('Test123');
              resp.add('Processing');
              resp.add(stringDate);
              resp.add(stringDate);
              resp.add(stringDate);
              
              Test.startTest();
              ApexPages.currentPage().getHeaders().put('True-Client-IP', 'Test123');
              ProcessLogging ctrl = new ProcessLogging();
              Id headerId = ctrl.InsertIntegrationHeader('User Registration','Not Found');
              ctrl.InsertIntegrationDetail(headerId,resp,u.Id);
              Test.stopTest();
          }
        
    }
    

}