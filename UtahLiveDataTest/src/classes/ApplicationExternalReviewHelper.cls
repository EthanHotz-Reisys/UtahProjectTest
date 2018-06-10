global with sharing class ApplicationExternalReviewHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){ 
         //Savepoint sp = Database.setSavePoint();
         // try{
         //     Id recordId = layoutHolder.getPrimarySObject().Id;
         //     Application__c app = [Select Id, Name, Status__c, Title__c,PrimaryApplicant__c from Application__c where id = :recordId Limit 1];
         //     Application__Share applicationShare= new Application__Share();
         //     applicationShare.ParentId = app.Id;
         //     applicationShare.UserOrGroupId = app.PrimaryApplicant__c;
         //     applicationShare.AccessLevel = 'Edit';
         //     insert applicationShare;
         //     //TaskCreationHandler.createApprovalProcessTasks(app.Id, 'Review Application Request', app.Name, null, System.TODAY() + 7,  true);
         //     //GNT.TaskCreationHandler.createTasks(app.PrimaryApplicant__c, app.Id, 'Review Application Request',app.Name, null, false, System.TODAY() + 7, null, true);
         //     GNT.TaskCreationHandler.createTasks(app.PrimaryApplicant__c, app.Id, 'Review Application Request',app.Name, null, false, System.TODAY() + 7, null, app.Title__c, true);
         //    // app.Status__c = 'Sent for Review';
         //     update app;             
         //     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Task has been created for Primary Applicant.'));
         //     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P02-GRNTR-88947'))); 
         //     PageReference pf = Page.ApplicationView;
         //     pf.getParameters().put('id', app.Id);
         //     pf.setRedirect(true);
         //     return pf;
         // }catch(Exception ex){
         //   Database.rollback(sp);
         //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ex.getMessage())); 
         //   return null;
         // }
         return null;
    }

}