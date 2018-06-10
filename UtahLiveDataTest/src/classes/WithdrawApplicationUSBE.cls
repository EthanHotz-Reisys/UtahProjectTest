global with sharing class WithdrawApplicationUSBE extends GNT.DynamicLayoutActionRedirect{
    
    public class InternalApproverMissingException extends Exception {}
    
    global override PageReference whenClicked(){  
    
        Savepoint savestate = Database.setSavepoint();
        Map<String,Object> retVal = new Map<String,Object>();
        Id recordId = layoutHolder.getPrimarySObject().Id;
        System.debug('MANUALDEBUG >>> Application Id = ' + recordId);
        
        try{
            Application__c currentApplication = [SELECT Id, Name, Approver__c, Status__c FROM Application__c WHERE Id =: recordId]; 
            System.debug('MANUALDEBUG >>> Application: ' + currentApplication);
            
            if (currentApplication.Approver__c == null) {
                throw new InternalApproverMissingException('An internal approver is required for this action');
            }
            
            currentApplication.WaiveWithdraw__c = 'Withdraw';
            currentApplication.PreWithdrawlStatus__c = currentApplication.Status__c; 
            ApplicationTriggerHelperUSBE.skipTrigger = true;
            update currentApplication;
            ApplicationTriggerHelperUSBE.skipTrigger = false;
            
            //Task and email to internal approver
            GNT.TaskCreationHandler.createApprovalProcessTasks(recordId, 'Withdraw Application Approval Request', currentApplication.Name, null, System.TODAY() + 7, currentApplication.Name, true);
                 
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
            PageReference pageref = Page.ApplicationView; 
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true); 
            return pageref;
        }
        //Add message to page saying that the waiving was successful and has been sent for internal approval
        ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.WARNING, 'Application withdrawal was successfully sent for internal approval.');
        ApexPages.addMessage(successMessage);
        return null;
        //return null;
    }
}