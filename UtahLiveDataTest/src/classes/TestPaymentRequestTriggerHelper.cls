@isTest
private class TestPaymentRequestTriggerHelper {
	
	@isTest static void someTest() {

		User u = TestHelper.getAdminUser(true);
		system.runAs(u) {
			// skip unwanted triggers
			AnnouncementTriggerHelper.skipTrigger = true;
			ApplicationtriggerHelper.skiptrigger = true;
			RolesandResponsibilitiesTriggerHelper.skipTrigger = true;
			GranttriggerHelper.skipTrigger = true;
			AwardTriggerHelper.skipTrigger = true;

			Announcement__c ann = TestHelper.getAnnouncement(true);
			Application__c app = TestHelper.getApplication(ann.Id,true);

			Grant__c grant = new Grant__c(ProjectPeriodStartDate__c=Date.newInstance(2015,3,14),
										  ProjectPeriodEndDate__c=Date.newInstance(2016,3,14),
										  IssueDate__c=Date.newInstance(2015,2,14),
										  Program__c=ann.Program__c,GranteePOC__c = u.id);
			insert grant;

			GrantServiceArea__c grantSrvArea = new GrantServiceArea__c(Grant__c=grant.Id);
			insert grantSrvArea;


			BudgetPeriod__c budPeriod = new BudgetPeriod__c(BudgetStartDate__c = System.Today() - 7,
															BudgetEndDate__c = System.today() + 358);
	        insert budPeriod;

	        Award__c aw  = new Award__c(Grant__c = grant.Id,Name = Math.Random()+'AW12',OrganizationName__c = 'Test Org',
	        							OrganizationAddress__c = 'Test Address',FiscalYear__c = '2013',
	        							SupportYear__c = Decimal.valueOf('2013'),Application__c=app.Id,
	        							AwardedAmountthisAction__c = 10000.00,TotalObligateAmount__c = 100000.00,
	        							BudgetPeriod__c = budPeriod.Id);
	        insert aw;

	        AwardBudgetCategory__c awdBudgetCategory = new AwardBudgetCategory__c(Award__c=aw.Id);
	        insert awdBudgetCategory;


	        List<PaymentRequest__c> paymentRequests = new List<PaymentRequest__c>();
			PaymentRequest__c paymentRequest1 = new PaymentRequest__c(Name='Test',Status__c='Approved',Award__c=aw.Id,
																	 FiscalOfficer__c=u.Id,ProgramManager__c=u.Id,Applicant__c=u.Id);
			PaymentRequest__c paymentRequest2 = new PaymentRequest__c(Name='Test',Status__c='Created',Award__c=aw.Id,
																	 FiscalOfficer__c=u.Id,ProgramManager__c=u.Id,Applicant__c=u.Id);
			paymentRequests.add(paymentRequest1);
			paymentRequests.add(paymentRequest2);

			insert paymentRequests;


	        AwardPaymentBudgetCategory__c awdPaymentBudgetCategory = new AwardPaymentBudgetCategory__c(Name='Test',Award__c=aw.Id);
	        insert awdPaymentBudgetCategory;

			paymentRequest1.Name = 'Test1';
			update paymentRequest1;

			PaymentBudgetCategory__c paymentBudgetCategory = new PaymentBudgetCategory__c(PaymentRequest__c=paymentRequest1.Id);
			insert paymentBudgetCategory;

			Test.startTest();
				PaymentRequestTriggerHelper	paymentRequestTriggerHelper = new PaymentRequestTriggerHelper();
			Test.stopTest();
		}

	}
	
}