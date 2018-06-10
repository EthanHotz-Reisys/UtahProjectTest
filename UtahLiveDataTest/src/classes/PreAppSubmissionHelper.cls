global with sharing class PreAppSubmissionHelper extends GNT.DynamicLayoutActionRedirect {
    
    global override PageReference whenClicked(){  
        System.debug('>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<');
        Savepoint sp = Database.setSavePoint();
        try{
        Id recordId = layoutHolder.getPrimarySObject().Id;
        List<String> errors = new List<String>();  
        System.debug('THE APPLICATION SUBMISSION HELPER IS 111'+recordId);
        PreApplication__c preApp = [Select Id,Name,Status__c,ApplicationCreatedOutside__c,Title__c,FormsValidated__c,ProgramApprover__c,RecordComplete__c,
                                      AwardFloor__c , AwardCeiling__c, RequestedAmount__c from PreApplication__c where Id =:recordId ];
            System.debug('THE APPLICATION SUBMISSION HELPER IS 222'+recordId); 
        List<ApplicationReview__c> lstAppReview = [Select Id from ApplicationReview__c where PreApplication__c =:recordId];   
        System.debug('the application created is --->'+preApp.ApplicationCreatedOutside__c);
         
        if(preApp.ApplicationCreatedOutside__c == true){   
            List<GNT__AttachmentExtension__c> lstAttachments = [Select GNT__Classification__c from GNT__AttachmentExtension__c where GNT__ParentId__c =:recordId 
                                                                            and GNT__Classification__c =:'APPLICATION FORMS']; 
            if(lstAttachments == null || lstAttachments.size()==0 ){ 
                errors.add(System.label.TheFormsAttachmentisMustWhenAppCreatedOutsidetheSystem); 
            }              
        }
        
         if(preApp.RequestedAmount__c < preApp.AwardFloor__c){
               errors.add(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTE-29716'));                 
         }
         if(preApp.RequestedAmount__c > preApp.AwardCeiling__c){ 
               errors.add(GNT.ErrorMessageHelper.fetchMessage('P02-GRNTE-16262'));             
         }        
         
         if(preApp.Status__c == 'Created'){
                errors.add(GNT.ErrorMessageHelper.fetchMessage('P32-GRNTE-93100'));
         }

         if(preApp.ApplicationCreatedOutside__c == false && preApp.FormsValidated__c == false){
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-63544'));    
         } 
         if(lstAppReview.size()<1 ){
            //errors.add('One Program and Fiscal review is required for Application before it is submitted for Approval.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-97215'));    
         } 
         if(preApp.ProgramApprover__c == null){
           //errors.add('One Program Approver is required for Application before it is submitted for Approval.');
            errors.add(GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTE-34078'));    
         }
         
          System.debug('>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<');
          System.debug('>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<'+errors);
        
         if(errors.size() > 0){
             for(String error: errors){
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
               System.debug('THE APPLICATION SUBMISSION HELPER IS 888'+error); 
             } 
             System.debug('THE APPLICATION SUBMISSION HELPER IS 999'+recordId); 
         }else{  
                //GNT.TaskCreationHandler.createApprovalProcessTasks(application.Id, 'Approve Application', application.Name, null, System.TODAY() + 7, true);
                GNT.TaskCreationHandler.createApprovalProcessTasks(preApp.Id, 'Approve Pre-Application', preApp.Name, null, System.TODAY() + 7, preApp.Title__c, true);     
                PageReference  pageref = Page.PreApplicationView;   
                pageref.getParameters().put('Id',recordId); 
                pageref.setRedirect(true); 
                return pageref;
          }     
        }catch(Exception e){
            
        }
        return null;
    }     
         
}