@isTest
private class TestPaymentBudgetCategoryTriggerHelper {
	
	@isTest static void testMethod1() {
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
										  IssueDate__c=Date.newInstance(2015,2,14),Application__c=app.Id,
										  Program__c=ann.Program__c,GranteePOC__c = u.id);
			insert grant;

	        Award__c aw  = new Award__c(Grant__c = grant.Id,Name = Math.Random()+'AW12',OrganizationName__c = 'Test Org',
							OrganizationAddress__c = 'Test Address',FiscalYear__c = '2013',
							SupportYear__c = Decimal.valueOf('2013'),Application__c=app.Id,
							AwardedAmountthisAction__c = 10000.00,TotalObligateAmount__c = 100000.00);
	        insert aw;

	        AwardBudgetCategory__c awdBudgetCategory = new AwardBudgetCategory__c(Award__c=aw.Id);
	        insert awdBudgetCategory;

	        List<PaymentRequest__c> paymentRequests = new List<PaymentRequest__c>();
			PaymentRequest__c paymentRequest1 = new PaymentRequest__c(Name='Test',Status__c='Approved',Grant__c=grant.Id,Award__c=aw.Id,
																	 FiscalOfficer__c=u.Id,ProgramManager__c=u.Id,Applicant__c=u.Id);
			PaymentRequest__c paymentRequest2 = new PaymentRequest__c(Name='Test',Status__c='Created',Grant__c=grant.Id,Award__c=aw.Id,
																	 FiscalOfficer__c=u.Id,ProgramManager__c=u.Id,Applicant__c=u.Id);
			paymentRequests.add(paymentRequest1);
			paymentRequests.add(paymentRequest2);

			insert paymentRequests;

	        AwardPaymentBudgetCategory__c awdPaymentBudgetCategory = new AwardPaymentBudgetCategory__c(Name='Test',Award__c=aw.Id);
	        insert awdPaymentBudgetCategory;

	        awdPaymentBudgetCategory.Name = 'Test1';
	        update awdPaymentBudgetCategory;

			FundingSource__c fundingSource = new FundingSource__c(Name='Test');
			insert fundingSource;

			FundingAccount__c fundingAccount = new FundingAccount__c(Name='Test 1',FundingSource__c=fundingSource.Id);
			insert fundingAccount;

			PaymentBudgetCategory__c paymentBudgetCategory = new PaymentBudgetCategory__c(PaymentRequest__c=paymentRequest1.Id,
																FundingAccount__c=fundingAccount.Id);
			insert paymentBudgetCategory;

			paymentBudgetCategory.AmountDue__c = 1200.00;
			update paymentBudgetCategory;

			Test.startTest();
				PaymentBudgetCategoryTriggerHelper	paymentBudgetCategoryTriggerHelper = new PaymentBudgetCategoryTriggerHelper();
			Test.stopTest();
		}
	}

	@isTest static void testMethod2() {
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
										  Program__c=ann.Program__c,Application__c=app.Id,GranteePOC__c = u.id);
			insert grant;

	        Award__c aw  = new Award__c(Grant__c = grant.Id,Name = Math.Random()+'AW13',OrganizationName__c = 'Test Org 1',
							OrganizationAddress__c = 'Test Address',FiscalYear__c = '2013',
							SupportYear__c = Decimal.valueOf('2013'),Application__c=app.Id,
							AwardedAmountthisAction__c = 10000.00,TotalObligateAmount__c = 100000.00);
	        insert aw;

	        List<PaymentRequest__c> paymentRequests = new List<PaymentRequest__c>();
			PaymentRequest__c paymentRequest1 = new PaymentRequest__c(Name='Test',Status__c='Approved',Award__c=aw.Id,Grant__c=grant.Id,
																	 FiscalOfficer__c=u.Id,ProgramManager__c=u.Id,Applicant__c=u.Id);
			PaymentRequest__c paymentRequest2 = new PaymentRequest__c(Name='Test',Status__c='Created',Award__c=aw.Id,Grant__c=grant.Id,
																	 FiscalOfficer__c=u.Id,ProgramManager__c=u.Id,Applicant__c=u.Id);
			paymentRequests.add(paymentRequest1);
			paymentRequests.add(paymentRequest2);

			insert paymentRequests;

			PaymentBudgetCategory__c paymentBudgetCategory = new PaymentBudgetCategory__c(PaymentRequest__c=paymentRequest1.Id);
			insert paymentBudgetCategory;

			paymentBudgetCategory.AmountDue__c = 1200.00;
			update paymentBudgetCategory;

			Test.startTest();
				PaymentBudgetCategoryTriggerHelper	paymentBudgetCategoryTriggerHelper = new PaymentBudgetCategoryTriggerHelper();
			Test.stopTest();
		}
	}
}