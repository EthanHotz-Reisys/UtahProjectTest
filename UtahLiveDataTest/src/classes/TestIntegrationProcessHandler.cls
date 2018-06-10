/*
* @author: SMahavratayajula - 07/26/2016
* Note: Actual class(IntegrationProcessHandler) is actively used in DCDOH code and 
* Tray is POC for this class. Assuming this class belongs to DOH, all related 
* classes are considered for deletion. To get samplet data from DB, check with Tray.
* IntegrationProcessDetailRedirectCtrl, IntegrationProcessRedirectCtrl and
* IntegrationProcessHandler. This test class can be used when we decide that we require
* this class in GovGrants
*/
@isTest
private class TestIntegrationProcessHandler {
	
	/*@isTest static void test_method_one() {

		IntegrationConfig__c integrationConfig = new IntegrationConfig__c(ProcessName__c='Test',
													Delimiter__c='Tab');
		insert integrationConfig;

		IntegrationDetailConfig__c integrationDetailConfig = new IntegrationDetailConfig__c(
																IntegrationConfig__c=integrationConfig.Id,
																SortOrder__c=1.0,TargetObject__c='Test',
																FieldConfig__c='{"<InputFieldName>":{"targetFieldName":"<outputFileName>"}'
																);
		insert integrationDetailConfig;

		IntegrationHeader__c integrationHeader = new IntegrationHeader__c(FileName__c='User Registration',
													Status__c='New',HeaderRecord__c='sometext area',
													IntegrationConfig__c=integrationConfig.Id);
		insert integrationHeader;

		IntegrationDetail__c integrationDetail = new IntegrationDetail__c(
													IntegrationHeader__c=integrationHeader.Id,
													DetailRecord__c='Some test detail');
		insert integrationDetail;

		Test.startTest();
			IntegrationProcessHandler integrationProcessHandler = new IntegrationProcessHandler(integrationHeader.Id,null);
			Database.executeBatch(integrationProcessHandler);
		Test.stopTest();

	}	*/
}