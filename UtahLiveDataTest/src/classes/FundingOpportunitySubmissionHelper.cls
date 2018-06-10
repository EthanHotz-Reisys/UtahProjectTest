global with sharing class FundingOpportunitySubmissionHelper extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){
    Savepoint sp = Database.setSavepoint(); 
    List<String> errors = new List<String>();   
    List<BusinessPackage__c> preapplicationpackage;
    try{
            Id recordId = apexpages.currentpage().getparameters().get('id');
            List<RolesAndResponsibilities__c> lstRolesResposiblities = [Select Id,BusinessRole__c from RolesAndResponsibilities__c where Announcement__c =:recordId ];
            Announcement__c announcement = [Select Id,name,AnnouncementName__c,ConstructionPackageValue__c ,ProgramApprover__c,FinancialApprover__c,EstimatedFundedAmount__c,StateProgram__c,FOAReviews__c,Status__c,HaveWeReceivedAwardFromProgram__c,PreApplicationRequired__c,
                                             EstimatedProjectPeriodStartDate__c,EstimatedProjectPeriodEndDate__c ,ProbabilityofWinningreceivingaGrant__c,ExpectedTotalAwardAmount__c from Announcement__c where Id =:recordId];
            List<BudgetPeriod__c> budPeriod = [Select Id, Status__c,FundingOpportunity__c  from BudgetPeriod__c where FundingOpportunity__c  =: recordId];
            system.debug('**announcement'+announcement.AnnouncementName__c);
            if(announcement.PreApplicationRequired__c){
                 preapplicationpackage = [Select Id,FundingOpportunity__c,PackageType__c from BusinessPackage__c where 
                                                               FundingOpportunity__c =:recordId and PackageType__c = 'Pre-Application' ];
            }
           
            List<BusinessPackage__c> applicationpackage = [Select Id,FundingOpportunity__c,PackageType__c,PackageConfig__c  from BusinessPackage__c where 
                                                               FundingOpportunity__c =:recordId and PackageType__c = 'Application' ];
        
           
            boolean programApproverExists = false;
            Boolean submitRecord = false;  
            Boolean stateProgramExists = false;   
            Boolean numberOfReviews = false;
            Boolean financialApproverExists = false;  
            Integer count = 0;
            
            if(announcement.ProgramApprover__c != null){
                programApproverExists = true;
            }
            if(announcement.FinancialApprover__c != null){
                financialApproverExists = true;
            }
            if(announcement.StateProgram__c != null){
                stateProgramExists = true;
            }
            if(announcement.FOAReviews__c != 0 ){
                numberOfReviews = true;
            }
            if(budPeriod.size()>0){
              for(BudgetPeriod__c bud: budPeriod){
                if(bud.Status__c == 'Active'){
                  count++;
                }
              }
            }

            if(announcement.Status__c == 'Reviewed' && 
                                  (announcement.HaveWeReceivedAwardFromProgram__c == null || announcement.ProbabilityofWinningreceivingaGrant__c == null || 
                                   announcement.ExpectedTotalAwardAmount__c == null) ){
                //errors.add('Evaluation tab: Please Enter Have we previously received an award from this sponsoring agency/program?,Probability of winning/receiving a Grant Award,Expected total Award Amount' );
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-51730'));
            }
            if(announcement.EstimatedProjectPeriodStartDate__c == null ){
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-78302'));
            }
            if(announcement.EstimatedFundedAmount__c == null || announcement.EstimatedFundedAmount__c == 0){
                // errors.add('Financial Tab:Please Enter Estimated Requested Amount Greater than 0');
                errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-64157'));
            }
             if(announcement.EstimatedProjectPeriodEndDate__c == null ){
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-52851'));
            }
            if(announcement.EstimatedProjectPeriodStartDate__c > announcement.EstimatedProjectPeriodEndDate__c ){
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-60652'));
            }
            
            if(programApproverExists == false){
                  //errors.add('A Program Approver must exist for the Opportunity.');
                  errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-24500'));
            }
            if(financialApproverExists == false){
                  //errors.add('A Financial Approver must exist for the Opportunity.');
                  errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-63213'));
            } 
            if(stateProgramExists == false){
                  //errors.add('A State Program must exist for the Opportunity.');
                  errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-51162'));
            }
            if(applicationpackage.size() < 1){
                  //errors.add('Application Package is needed for the Opportunity.');
                  errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-32223'));
            }
             if(announcement.PreApplicationRequired__c == true && preapplicationpackage.size()<1 ){
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P32-GRNTE-19146'));
             } 
            
            if(numberOfReviews == false){
                 //errors.add('At least one Review is required for Opportunity before it is submitted for Approval.');
                 errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-31805'));
            }
            if(count == 0){
              errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-39059'));
            }
            if(count>1){
              errors.add(GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-52534'));
            }
            if(applicationpackage.size()>0){
              List<GNT__PackageFormConfig__c > packForms = [Select Id,GNT__FormConfig__r.GNT__DisplayName__c from GNT__PackageFormConfig__c where GNT__PackageConfig__c =:applicationpackage[0].PackageConfig__c];
              for(GNT__PackageFormConfig__c pack:packForms){
                //System.debug('Package Name --->'+pack.GNT__FormConfig__r.Name);
                if(announcement.ConstructionPackageValue__c == 'Construction' && pack.GNT__FormConfig__r.GNT__DisplayName__c == 'SF 424: Budget Information Non Construction Form'){      
                  errors.add(GNT.ErrorMessageHelper.fetchMessage('P51-GRNTE-67159'));
                }
                else if(announcement.ConstructionPackageValue__c == 'Non construction' && pack.GNT__FormConfig__r.GNT__DisplayName__c == 'SF 424: Budget Information Construction Form'){        
                  errors.add(GNT.ErrorMessageHelper.fetchMessage('P31-GRNTE-86347'));
                }
              }
            }

            if(errors.size() > 0){
                for(String error: errors){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
                } 
            }
            else{
                //GNT.TaskCreationHandler.createApprovalProcessTasks(announcement.Id, 'Approve the Opportunity', announcement.AnnouncementName__c, null, System.TODAY() + 7,  true); 
                GNT.TaskCreationHandler.createApprovalProcessTasks(announcement.Id, 'Approve the Opportunity', announcement.Name, null, System.TODAY() + 7, announcement.AnnouncementName__c,true);         
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Funding Opportunity has been submitted successfully.'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-61979')));
                PageReference  pageref = Page.AnnouncementView;   
                pageref.getParameters().put('Id',recordId);
                pageref.setRedirect(true);  
                return pageref;
            }
            return null;
        }catch(Exception e){
         Database.rollback(sp);
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
         return null;   
        }
    }   
}