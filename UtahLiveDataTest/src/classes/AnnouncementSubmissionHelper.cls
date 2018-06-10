global with sharing class AnnouncementSubmissionHelper extends GNT.DynamicLayoutActionRedirect { 

   
    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint();
    List<String> errors = new List<String>();   

    try{
        Id recordId = apexpages.currentpage().getparameters().get('id');
        List<RolesAndResponsibilities__c> lstRolesResposiblities = [Select Id, BusinessRole__c, Name__c from RolesAndResponsibilities__c where Announcement__c =:recordId AND Name__c != null];
        Announcement__c announcement = [Select Id,Name,ApplicationDeadlineWithDateTime__c,AnnouncementName__c,ObligatedAmount__c,FOAReviews__c,EstimatedAmount__c,EligibleApplicantTypes__c,PointofContact__c,Status__c,PreApplicationNeeded__c,EstimatedNumberOfAwards__c,
                                EstimatedAverageSizeOfAward__c,PreApplicationDeadlineWithDateTime__c, Program__r.StartDate__c,OrganizationName__c,
                                Program__r.EndDate__c,  EstimatedProjectPeriodStartDate__c,EstimatedProjectPeriodEndDate__c,FOAPublicationDate__c, AwardCeiling__c, 
                                AwardFloor__c, IsNoReviewStepProgram__c from Announcement__c where Id =:recordId ];
        List<BudgetPeriod__c> budgetPdList = [Select Id,Name,BudgetStartDate__c,BudgetEndDate__c,Status__c from BudgetPeriod__c where FundingOpportunity__c =:recordId ];
        
        boolean approverExists = false;
        boolean keypocExists = false;
        Boolean submitRecord = false;  
        Boolean executiveExists = false;
        Boolean grantsAdmin =false;  
        Integer count = 0;   
                     
        if (announcement.OrganizationName__c != 'USBE') {
            for(RolesAndResponsibilities__c role : lstRolesResposiblities){
                if(role.BusinessRole__c.equals('Program Approver')){
                    approverExists = true;
                }
                if(role.BusinessRole__c.equals('Key POC')){  
                    keypocExists = true;
                }
                if(role.BusinessRole__c.equals('Executive Approver')){
                    executiveExists = true;
                }
                if(role.BusinessRole__c.equals('Grants Administrator')){
                    grantsAdmin = true;
                }
            }
        }
        else { //We are going to define Roles SPECIFICALLY on program level
            for(RolesAndResponsibilities__c role : lstRolesResposiblities){
                if(role.BusinessRole__c.equals('Executive Approver')){
                    executiveExists = true;
                    approverExists = true;
                }
                if(role.BusinessRole__c.equals('Grants Manager')){
                    grantsAdmin = true;
                    keypocExists = true;
                }
            }
        }
        
        

        if(budgetPdList.size()>0){
            for(BudgetPeriod__c bud: budgetPdList){
                if(bud.Status__c == 'Active'){
                    count++;
                }
            }
        }
         // Check Review Process
        List<ReviewStepTemplate__c> reviewStepList = [Select Id,IsStepMandatory__c from ReviewStepTemplate__c where Announcement__c =:recordId and IsStepMandatory__c='Mandatory'];
       
         // Check App-Review Packages 
        List<BusinessPackage__c> pkgList = [Select Id,PackageType__c from BusinessPackage__c where FundingOpportunity__c =:recordId and PackageType__c='App-Review'];
      
         // Check Pre-Application  Packages 
        List<BusinessPackage__c> preAppPkgList = [Select Id,PackageType__c from BusinessPackage__c where FundingOpportunity__c =:recordId and PackageType__c='Pre-Application'];
     
        // Check Application  Packages 
        List<BusinessPackage__c> appPkgList = [Select Id,PackageType__c from BusinessPackage__c where FundingOpportunity__c =:recordId and PackageType__c='Application'];
        
        List<BusinessPackage__c> monitoringPackages = [Select Id,PackageType__c from BusinessPackage__c where FundingOpportunity__c =:recordId and PackageType__c IN ('Risk Assessment','Site Visit','Closeout','Progress Report')];
        // Check Budget Categories
        List<FundingOpportunityBudgetCategory__c> budgetCategoryList = [Select Id, Name from FundingOpportunityBudgetCategory__c where FundingOpportunity__c = :recordId];
        Set<String> annPackages = new Set<String>();
        if(budgetCategoryList == null || budgetCategoryList.size() == 0){
            //errors.add('Funding Opportunity must have at least one budget category');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-01014'));
        }

       if(announcement.AnnouncementName__c=='Enter the Title'){
        //errors.add('Please Change the Title of Announcement.');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-13460'));
       }

       if(announcement.FOAPublicationDate__c>date.valueof(announcement.ApplicationDeadlineWithDateTime__c)){
        errors.add('Application Deadline should be greater than FOA Publication date.');

       }
      /* if(announcement.EstimatedNumberOfAwards__c==null || announcement.EstimatedNumberOfAwards__c<1){
        //errors.add('Please Change the Title of Announcement.');
        //errors.add('Please enter valid Estimated Number of Awards');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-92157'));
       }
       

       if(announcement.EstimatedAverageSizeOfAward__c==null || announcement.EstimatedAverageSizeOfAward__c<0.00){
        //errors.add('Please Change the Title of Announcement.');
        //errors.add('Please enter valid Estimated Average Size of Award');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-52741'));
       } */
       if(announcement.EligibleApplicantTypes__c==null){
        //errors.add('Please Change the Title of Announcement.');
        //errors.add('Please select applicant types');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-73029'));
       }

       if(!AppUtils.validateBudgetPeriods(announcement.EstimatedProjectPeriodStartDate__c,announcement.EstimatedProjectPeriodEndDate__c,budgetPdList)){
          errors.add (GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-79576'));
        }
     
      
     /* if(announcement.ObligatedAmount__c < announcement.EstimatedAmount__c){
        //errors.add('Please Change the Title of Announcement.');
        //errors.add('Set-Aside Amount can not be less than Estimated Amount');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-11945'));
       }       
      if(announcement.ObligatedAmount__c == null || announcement.ObligatedAmount__c < 0.00){
        //errors.add('Please Change the Title of Announcement.');
        //errors.add('Please enter valid Set-Aside Amount');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-37481'));
       }
       if(announcement.ObligatedAmount__c == null || announcement.ObligatedAmount__c < 0.00){
        //errors.add('Please Change the Title of Announcement.');
        //errors.add('Please enter valid Set-Aside Amount');
        errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-17979'));
       } */
       //if(announcement.FOAReviews__c<1){
       // //errors.add('Please Change the Title of Announcement.');
       // //errors.add('Please complete atleast one Peer Review  of Announcement in the Roles Tab');
       // errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-88590'));
       //}

         //Check Award Ceiling Amount
        //if(announcement.AwardCeiling__c == null || announcement.AwardCeiling__c<0.00){
        // //errors.add('Please fill Award Ceiling amount in Financials Tab');
        // errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-12339'));
        //}
        // //Check  Award Floor Amount
        //if(announcement.AwardFloor__c==null || announcement.AwardFloor__c<0.00){
        // //errors.add('Please fill Award Floor amount in Financials Tab');
        // errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-57480'));
        //}    
        if(keypocExists == false){
            //errors.add('Please Add Business Role with "Key POC" in Roles and Responsibilities.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-64278'));         
        }

        if(approverExists == false){
            //errors.add('A Program Approver must exist for the Announcement.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-64583'));
        }
         if(executiveExists == false){
            //errors.add('A Program Executive must exist for the Announcement.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-43868'));
        }
        if(grantsAdmin == false && announcement.OrganizationName__c == 'UOVC'){
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-43869'));
        }   
        if((reviewStepList == null || reviewStepList.size()==0) && announcement.IsNoReviewStepProgram__c != true){
            //errors.add('1 Mandatory Review Step required for the Announcement.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-21848'));
        }        
        if(budgetPdList== null || budgetPdList.size()==0){
             //errors.add('An announcement must have atleast 1 Budget Period.');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-23925'));
        }
        if((pkgList == null || pkgList.size()==0) && announcement.OrganizationName__c == 'UOVC'){
             //errors.add('Please associate a Package with App-Review Package Type with the Announcement.');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-48007'));
         }
         if(announcement.OrganizationName__c == 'UOVC' && (appPkgList == null || appPkgList.size()==0)){
             //errors.add('Please associate a Package with App-Review Package Type with the Announcement.');
             //errors.add('Please associate a Package with Application Package Type with the Announcement.');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-44635'));
         }
         //Sai Teja - Validation for monitoring packages.
         if (announcement.OrganizationName__c == 'UOVC') {
         if(monitoringPackages == null || monitoringPackages.size()==0){
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-44636'));
         }
         Set<String> requiredPackages = new Set<String>{'Site Visit','Closeout','Risk Assessment','Progress Report'};
         for(BusinessPackage__c bp : monitoringPackages){
            if(bp.PackageType__c!=null){
                annPackages.add(bp.PackageType__c);
            }
         }
         
             if(!annPackages.containsAll(requiredPackages)){
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-44636'));
             }
        }
        // if(announcement.EstimatedProjectPeriodEndDate__c>announcement.Program__r.EndDate__c){
        //    //errors.add('Estimated Project Period End Date can not be after Program End Date');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-27251'));
        //}
        //if(announcement.EstimatedProjectPeriodStartDate__c<announcement.Program__r.StartDate__c){
        //    //errors.add('Estimated Project Period Start Date can not be before Program Start Date');
        //    errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-88609'));
        //}        
        if((announcement.PreApplicationNeeded__c=='Required'|| announcement.PreApplicationNeeded__c=='Recommended')  && (preAppPkgList == null || preAppPkgList.size()==0)){
             //errors.add('Please associate a Package with Pre-Application Package Type with the Announcement.');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-15098'));
        }        
        if((announcement.PreApplicationNeeded__c=='Required'|| announcement.PreApplicationNeeded__c=='Recommended') && announcement.PreApplicationDeadlineWithDateTime__c==null){
             //errors.add('Please provide Pre-Application Deadline information.');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-63294'));
        }  
        if((announcement.PreApplicationNeeded__c=='Not Required') && announcement.PreApplicationDeadlineWithDateTime__c!=null){
             //errors.add('Please provide Pre-Application Deadline information.');
             //errors.add('Pre-Application Deadline should not be filled if Pre-Application is Not Required');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-28084'));
        }  
        if((announcement.PreApplicationNeeded__c=='Required'|| announcement.PreApplicationNeeded__c=='Recommended') && announcement.PreApplicationDeadlineWithDateTime__c<announcement.FOAPublicationDate__c){
             //errors.add('Please provide Pre-Application Deadline information.');
             //errors.add('Pre-Application Deadline must be after FOA Release Date');
             errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-59959'));
        } 
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
        }else if (keypocExists == true && approverExists == true) {
            //  GNT.TaskCreationHandler.createApprovalProcessTasks(announcement.Id, 'Review FOA Announcement', announcement.Name, null, System.TODAY() + 7,  true);
            GNT.TaskCreationHandler.createApprovalProcessTasks(announcement.Id, 'Approve Announcement', announcement.Name, null, System.TODAY() + 7, announcement.AnnouncementName__c, true); 
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Announcement has been submitted successfully.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('P01-GRNTR-48141')));
            PageReference  pageref = Page.AnnouncementView;
            pageref.getParameters().put('id',recordId);
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