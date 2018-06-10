/**
*   EIN Check Button Helper class
*
*   CHANGE HISTORY
*   ===================================================
    ===================================================
*   Date            Name                Description
*   07/07/2015      Shrawan Raina       Created
*/
public with sharing class Validate501cHelper extends GNT.DynamicLayoutActionStay{
    public override String whenClicked() {
        try{
            Id recordId = ApexPages.CurrentPage().getParameters().get('id');
            String ein = [SELECT EmployerIdentificationNumber__c FROM Application__c WHERE Id =: recordId LIMIT 1].EmployerIdentificationNumber__c; 
            if(ein == null) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value for Employer Identification Number'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-47713')));
                return '';
            }
            ExternalInterfaceCtrl obj = new ExternalInterfaceCtrl();
            if(1 == 2){
                  return 'The organization is a valid 501 (c) (3) tax exempt organization';
            }
            else {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The organization is NOT a valid 501(c)(3) tax exempt organization'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-30106')));
                return '';
            }
        }
        catch(Exception e){
            if(e.getMessage() == '404')
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No record was found with 501(c)(3) database'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-89802')));
            else if(e.getMessage() == 'Interface')
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to connect to External Interface'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79489')));
            else if(e.getMessage() == 'Invalid EIN')
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Employer Identification Number - EIN must be 9 digits'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-13985')));
            else
                System.Debug('The following Exception has occured : ' + e.getMessage());
            return '';
        }
    }

}