global with sharing class WaiveApplicationUSBE extends GNT.DynamicLayoutActionRedirect{
    
    public class InternalApproverMissingException extends Exception {}
    
    global override PageReference whenClicked(){  
    
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        Id recordId = layoutHolder.getPrimarySObject().Id;
        System.debug('MANUALDEBUG >>> Application Id = ' + recordId);
        
        try{
            Application__c currentApplication = [SELECT Id, Name, Approver__c, Title__c, WaiveWithdraw__c FROM Application__c WHERE Id =: recordId]; 
            System.debug('MANUALDEBUG >>> Application: ' + currentApplication);
            if (currentApplication.WaiveWithdraw__c == null || currentApplication.WaiveWithdraw__c  == 'Not Applicable'){
                if (currentApplication.Approver__c == null) {
                    throw new InternalApproverMissingException('An internal approver is required for this action');
                }
                
                currentApplication.WaiveWithdraw__c = 'Waive';
                ApplicationTriggerHelperUSBE.skipTrigger = true;
                update currentApplication;
                ApplicationTriggerHelperUSBE.skipTrigger = false;
                
                System.debug('MANUALDEBUG >>> waivewithdraw: ' + currentApplication.WaiveWithdraw__c);
                
                //Task and email to internal approver
                GNT.TaskCreationHandler.createApprovalProcessTasks(recordId, 'Waive Application Approval Request', currentApplication.Name, null, System.TODAY() + 7, currentApplication.Title__c, true);
            }
        }
        catch(InternalApproverMissingException e) {
            Database.rollback(savestate);
            System.debug('MANUALDEBUG >>> error: ' + e);
            /*
            PageReference pageref = Page.ApplicationView; 
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true); 
            return pageref;
            */
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'An internal approver is required for this action');
            ApexPages.addMessage(errorMessage);
            return null;
        }
        catch(Exception e){
            Database.rollback(savestate);
            System.debug('MANUALDEBUG >>> error: ' + e);
        }
        
        //Add message to page saying that the waiving was successful and has been sent for internal approval
        ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'Application waiving was successfully sent for internal approval.');
        ApexPages.addMessage(successMessage);
        PageReference pageref = Page.ApplicationView; 
        pageref.getParameters().put('Id',recordId);
        pageref.setRedirect(true); 
        return pageref;
        //return null;
    }
}