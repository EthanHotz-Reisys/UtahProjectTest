//Leon 

global with sharing class ProgramSubmissionHelper extends GNT.DynamicLayoutActionRedirect { 

    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();  
    try{
        Id recordId = apexpages.currentpage().getparameters().get('id');
        List<RolesAndResponsibilities__c> lstRolesResposiblities = [Select Id,BusinessRole__c from RolesAndResponsibilities__c where Program__c =:recordId ];
        Program__c program = [Select Id,Name,RecordType.Name,AttachmentsRequired__c,FunderType__c,StartDate__c,EndDate__c,IsProjectServiceAreaneeded__c,ProgramName__c, Account__r.Name, ProgramBudgetTypeUSBE__c, IsNoReviewStepProgram__c from Program__c where Id =:recordId ];
        List<ProgramServiceArea__c> programService = [Select Id from ProgramServiceArea__c where Program__c =:recordId];
        //List<JXPrograms__c> FederalPrograms = [Select Id from JXPrograms__c where StateProgram__c =:recordId];
        List<BudgetPeriod__c> budPeriod = [Select Id,BudgetStartDate__c,BudgetEndDate__c, Status__c,Program__c from BudgetPeriod__c where Program__c =: recordId order by BudgetStartDate__c asc];
        List<ProgramBudgetCategory__c> programBudgetCategory = [Select Name from ProgramBudgetCategory__c where Program__c = :recordId];
        List<ProgramFundingAccount__c> programFundingAccount = [Select Name from ProgramFundingAccount__c where Program__c = :recordId];
        List<ProgramContacts__c> programContactList = [Select Id, Name from ProgramContacts__c where Program__c=: recordId];
        Integer count = 0;
        boolean approverExists = false;
        boolean keypocExists = false;
        boolean fiscalAppoverExists = false;
        boolean executiveApproverExists = false;
 
 
        for(RolesAndResponsibilities__c role : lstRolesResposiblities){
            if(role.BusinessRole__c!= null && role.BusinessRole__c.equals('Program Approver')){
                approverExists = true;
            }
            if(role.BusinessRole__c!= null && role.BusinessRole__c.equals('Fiscal Approver')){
                fiscalAppoverExists = true;
            }
            if(role.BusinessRole__c!= null && role.BusinessRole__c.equals('Key POC')){  
                keypocExists = true;
            }
            if(role.BusinessRole__c!=null && role.BusinessRole__c.equals('Executive Approver')){
              executiveApproverExists=true;
            }
            // Leon: added Executive approver for both USBE AND UOVC programs
        }

        if(budPeriod.size()>0){
          for(BudgetPeriod__c bud: budPeriod){
            if(bud.Status__c == 'Active'){
              count++;
            }
          }
        }
        //Check to make sure 'Other' is a type of attachment; and adding it, if it is not there. 
        String listOfAttachments=program.AttachmentsRequired__c;
        if (listOfAttachments!=null){
        if (!listOfAttachments.containsIgnoreCase('other'))
          //errors.add ('Must have attachment type ' +'other'); 
          program.AttachmentsRequired__c+=';Other';
          update program;
        }
        else{
          program.AttachmentsRequired__c='Other';
          update program;
        }


        //Checking for financial and programmatic contacts. 

        
        // Check Review Process
        List<ReviewStepTemplate__c> reviewStepList = [Select Id,IsStepMandatory__c from ReviewStepTemplate__c where Program__c =:recordId and IsStepMandatory__c='Mandatory'];
       
         // Check App-Review Packages 
        //List<BusinessPackage__c> pkgList = [Select Id,PackageType__c from BusinessPackage__c where Program__c =:recordId and PackageType__c='Application'];
        
        AggregateResult[] aggs = [SELECT PackageType__c packageType FROM BusinessPackage__c WHERE Program__c =:recordId GROUP BY PackageType__c];
        Set<String> packageTypeSet = new Set<String>();
        for(AggregateResult agg : aggs){
          packageTypeSet.add(String.valueOf(agg.get('packageType')));
        }

        if(!packageTypeSet.contains('Risk Assessment')){
          errors.add ('Please associate a Package with Risk Assessment under attachments.');
        }

        if(!packageTypeSet.contains('Progress Report')){
          errors.add ('Please associate a Package with Progress Report under attachments.');
        }

        if(!packageTypeSet.contains('Site Visit')){
          errors.add ('Please associate a Package with Site Visit under attachments.');
        }

        if(!packageTypeSet.contains('Closeout')){
          errors.add ('Please associate a Package with Closeout under attachments.');
        }

        if(programBudgetCategory == null || programBudgetCategory.size() == 0){
            //errors.add ('Program must have at least one budget category');
            errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-31605'));
        }
        //Shivankar: Commented this validation out based on BA's request. 
      //  if(programFundingAccount == null || programFundingAccount.size() == 0){ 
      //    //errors.add ('Program must have at least one funding account associated'); 
      //  errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-16024')); 
      //}
    
        if(!AppUtils.validateBudgetPeriods(program.StartDate__c,program.EndDate__c,budPeriod)){
          errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79576'));
        }
        if(keypocExists == false){
            //errors.add ('A Key POC (under Roles & Responsibilities section of Review Tab) is a required field for a program');
            errors.add (GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-54930'));
        }
        if(approverExists == false){
            //errors.add( ' An Approver (under Roles & Responsibilities section of Review Tab) is a required field for a program');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-99971'));
        }
        if(fiscalAppoverExists == false){
            errors.add('A Fiscal Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program');
        }
        if(executiveApproverExists == false){
          errors.add('A Executive Approver (under Roles & Responsibilities section of Roles Tab) is a required field for a program');
        }        

        if(programContactList.isEmpty()){
        //errors.add('Please add atleast one Program Contact');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-75625'));     
        }
    
        //if(pkgList == null || pkgList.size()==0){
             //errors.add(' Please associate a Package with Application Package Type with the Program.');
            //errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-52018'));
        //}
        if((program.IsProjectServiceAreaneeded__c =='Yes') && (programService == null || programService.size()==0)){
            //errors.add('Please associate atleast one Service Area with the Program.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-83669'));
        }
        if((program.IsProjectServiceAreaneeded__c =='No') && (programService.size() > 0)){
            //errors.add('Please do not associate Service Area, if Project Service Area is not needed');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-39325'));
            //errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-83669'));
        }
        //if((program.FunderType__c == 'Federal') && (FederalPrograms == null || FederalPrograms.size()==0)){
        //    //errors.add('Please associate atleast one Federal Program with the Program.');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-65888'));
        //}
        
       /* if (program.Account__r.Name == 'USBE' && program.ProgramBudgetTypeUSBE__c == null) {
            errors.add('USBE programs must specify their program type');
        } */
        
        if(count == 0){
          errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-39059'));
        }
        if(count>1){
          errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-52534'));
        }
        if(errors.size() > 0){
                 for(String error: errors){
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                 }
              }
        
        else if(keypocExists == true && approverExists == true){
             ProgramTriggerHelper.skipTrigger = true;
             System.debug('***entered here *** ');
             GNT.TaskCreationHandler.createApprovalProcessTasks(program.Id, 'Approve Program', program.Name, null, System.TODAY() + 7, program.ProgramName__c, true);
             //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Program has been submitted successfully.'));
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-12057')));
             PageReference p = Page.ProgramView;
             p.getParameters().put('Id', program.Id);
             p.setRedirect(true);
             return p; 
        }
           return null; 
       } catch(Exception e){
            Database.rollback(sp);
            System.debug('***exception caught' + e.getCause());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    
}