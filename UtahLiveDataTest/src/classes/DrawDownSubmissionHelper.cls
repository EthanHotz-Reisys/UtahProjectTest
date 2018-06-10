/**
* This class is used for validating drawdowns before submmitting for approval process
* @author: Sarat Mahavratayajula
*/

global with sharing class DrawDownSubmissionHelper extends GNT.DynamicLayoutActionRedirect {

	private String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
	global override PageReference whenClicked() {

		Drawdown__c drawDown;

		Savepoint sp = Database.setSavepoint();
		try {

		Id recordId = ApexPages.currentpage().getParameters().get('id');

		if (recordId != null) {
			drawDown = [select Id,Name,Name__c,Title__c from Drawdown__c where Id = :recordId];
		}

		system.debug('***sarat' + drawDown.Id + ' : ' + drawDown.Title__c + ' : ' + drawDown.Name__c);

		GNT.TaskCreationHandler.createApprovalProcessTasks
                                                    (drawDown.Id,'Draw Down Request',drawDown.Title__c, null, 
                                                        System.TODAY() + 7, drawDown.Name__c, true);

        PageReference p = Page.DrawDownView;
        p.getParameters().put('Id', drawDown.Id);
        p.setRedirect(true);     
        return p; 
        }
        catch (Exception ex) {
        	Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
		
	}
}