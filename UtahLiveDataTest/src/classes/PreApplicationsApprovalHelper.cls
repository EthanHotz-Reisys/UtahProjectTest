global with sharing class PreApplicationsApprovalHelper extends GNT.DynamicLayoutActionRedirect { 

   
    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();   

    try{
        Id recordId = apexpages.currentpage().getparameters().get('id');
        Announcement__c ann = [Select Id,Name,ProgramApprover__c, AnnouncementName__c from Announcement__c where Id =:recordId ];
           
       

      
       if(ann.ProgramApprover__c==null)
       {
        //errors.add('Funding Allocation Plans can not be submitted for approval.');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-10913'));
       }


         if(errors.size() > 0){
            for(String error: errors){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
        }else  {
            //GNT.TaskCreationHandler.createApprovalProcessTasks(ann.Id, 'Approve Grantor PreApplication', ann.Name, null, System.TODAY() + 7,  true); 
            GNT.TaskCreationHandler.createApprovalProcessTasks(ann.Id, 'Approve Grantor PreApplication', ann.Name, null, System.TODAY() + 7, ann.AnnouncementName__c,true); 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Funding Allocation Plans has been submitted successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-37455')));
            PageReference  pageref = Page.FundingAllocationPlan;
            pageref.getParameters().put('Id',recordId);
            pageref.setRedirect(true);
            return pageref;   
        }

            return null;               
      } catch(Exception e){
        
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}