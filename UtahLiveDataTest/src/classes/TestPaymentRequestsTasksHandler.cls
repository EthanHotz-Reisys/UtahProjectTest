/**
* @author: Sarat Mahavratayajula
*/
@isTest
private class TestPaymentRequestsTasksHandler {
	
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

			Id recordTypeId1 = TestHelper.getRecordType(Schema.Sobjecttype.Award__c,'Grantor');
	        Award__c aw  = new Award__c(Grant__c = grant.Id,Name = Math.Random()+'AW12',OrganizationName__c = 'Test Org',
							OrganizationAddress__c = 'Test Address',FiscalYear__c = '2013',
							SupportYear__c = Decimal.valueOf('2013'),Application__c=app.Id,RecordTypeId=recordTypeId1,
							AwardedAmountthisAction__c = 10000.00,TotalObligateAmount__c = 100000.00);
	        insert aw;

			Id recordTypeId = TestHelper.getRecordType(Schema.Sobjecttype.TermCondition__c,'Payment Request');
			TermCondition__c termCondition = new TermCondition__c();
	        termCondition.Award__c = aw.Id;
	        termCondition.CalReportingEndDate__c = System.today() + 7;
	        termCondition.CalReportingStartDate__c = system.today() +1;
	        termCondition.ReportName__c = 'Site Visit 1';
	        termCondition.Category__c = 'Federal Financial Report';
	        termCondition.Frequency__c = 'Fixed';
	        termCondition.SiteVisitLocation__c = 'Test location';
	        termCondition.RecordTypeId = recordTypeId;
	        insert termCondition;

	        Id recordTypeId2 = TestHelper.getRecordType(Schema.Sobjecttype.TermConditionSchedule__c,'Payment Request');
			List<SObject> lst=new List<SObject>();
	        TermConditionSchedule__c termSchedule = new TermConditionSchedule__c();
	        termSchedule.TermAndCondition__c = termCondition.Id;
	        termSchedule.EndDate__c = System.Today() + 7;
	        termSchedule.TaskCreated__c = false;
	        termSchedule.RecordTypeId = recordTypeId2;
			lst.add(termSchedule);
	        insert lst;

	        ProgressReportsConfig__c progressReportsConfig = new ProgressReportsConfig__c();
	        progressReportsConfig.Name = 'Grantor_Reports';
	        progressReportsConfig.ReportDueAge__c = 10;
	        progressReportsConfig.SiteVisitTaskCreationAge__c = 10;
	        progressReportsConfig.TaskCreationAge__c = 10;
	        progressReportsConfig.VisitDueAge__c = 10;

	        insert progressReportsConfig;

	        Test.startTest();
	        	PaymentRequestsTasksHandler paymentRequestsTasksHandler = new PaymentRequestsTasksHandler();
	        	Database.executeBatch(paymentRequestsTasksHandler);
	        Test.stopTest();
		}
	}
	
}