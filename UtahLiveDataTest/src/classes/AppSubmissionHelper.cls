global with sharing class AppSubmissionHelper  extends GNT.DynamicLayoutActionRedirect{
    
    global override PageReference whenClicked(){  
        System.debug('THE APPLICATION SUBMISSION HELPER IS 000');
        Savepoint sp = Database.setSavePoint();
        try{
     
        Id recordId = layoutHolder.getPrimarySObject().Id;
        //Id recordId =   ApexPages.CurrentPage().getParameters().get('id');
        List<String> errors = new List<String>();
        System.debug('THE APPLICATION SUBMISSION HELPER IS 111'+recordId);
        Application__c application = [Select Id,Name,ApplicationCreatedOutside__c,Title__c,FormsValidated__c,NumberOfReviews__c,ProgramApprover__c,FiscalApproval__c,
                                      AwardFloor__c , AwardCeiling__c, GranteeRequestedAmount__c from Application__c where Id =:recordId ];
            System.debug('THE APPLICATION SUBMISSION HELPER IS 222'+recordId); 
         
        if(application.ApplicationCreatedOutside__c == true){   
            List<GNT__AttachmentExtension__c> lstAttachments = [Select GNT__Classification__c from GNT__AttachmentExtension__c where GNT__ParentId__c =:recordId 
                                                                            and GNT__Classification__c =:'APPLICATION FORMS']; 
            if(lstAttachments == null || lstAttachments.size()==0 ){ 
                errors.add(System.label.TheFormsAttachmentisMustWhenAppCreatedOutsidetheSystem); 
            }              
        }
        
         if(application.GranteeRequestedAmount__c    < application.AwardFloor__c){
               errors.add(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTE-29716'));                  
         }
         if(application.GranteeRequestedAmount__c > application.AwardCeiling__c){
               errors.add(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTE-16262'));             
         }
        
        
         if(application.FormsValidated__c == false){
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-63544'));    
         }
         if(application.NumberOfReviews__c < 2 || application.NumberOfReviews__c == null){
            //errors.add('One Program and Fiscal review is required for Application before it is submitted for Approval.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-55690'));    
         }
         if(application.ProgramApprover__c == null){
           //errors.add('One Program Approver is required for Application before it is submitted for Approval.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-34078'));    
         }
         if(application.FiscalApproval__c == null){
            //errors.add('One Fiscal Approver is required for Application before it is submitted for Approval.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-05108'));    
         }
         if(errors.size() > 0){
             for(String error: errors){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
               System.debug('THE APPLICATION SUBMISSION HELPER IS 888'+error); 
             } 
             System.debug('THE APPLICATION SUBMISSION HELPER IS 999'+recordId); 
         }else{  
                //GNT.TaskCreationHandler.createApprovalProcessTasks(application.Id, 'Approve Application', application.Name, null, System.TODAY() + 7, true);
                GNT.TaskCreationHandler.createApprovalProcessTasks(application.Id, 'Approve Application', application.Name, null, System.TODAY() + 7, application.Title__c, true);     
                PageReference  pageref = Page.ApplicationView; 
                pageref.getParameters().put('Id',recordId);
                pageref.setRedirect(true); 
                return pageref;
          }    
        }catch(Exception e){
            
        }
        return null;
    }     
            
}