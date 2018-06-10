global with sharing class FINETProgCreatHelper extends GNT.DynamicLayoutActionRedirect {
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    global override PageReference whenClicked(){
        Savepoint sp = Database.setSavepoint();
        Boolean isError = false;
        
        try{
                    Id recordId = apexpages.currentpage().getparameters().get('id');
                    r_prog__c prog=[SELECT Id,PROG_NM__c,BILL_AGREE_DT__c,EFBGN_DT__c,EFEND_DT__c,FINETMajorProgram__c FROM r_prog__c WHERE Id =: recordId LIMIT 1 ];
                
                      if ((prog.BILL_AGREE_DT__c<prog.EFBGN_DT__c)||(prog.BILL_AGREE_DT__c>prog.EFEND_DT__c))
                    {
                        isError=true;
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The Billing agreement date should be between the Effective From and Effective To dates under General information tab'));
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-56125')));
                    }

                    if (iserror==false){
                    GNT.TaskCreationHandler.createApprovalProcessTasks(prog.Id, 'Create FINET Program', prog.PROG_NM__c, null, System.TODAY() + 7, prog.PROG_NM__c, true); 
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-57523')));
                    
                    
                    PageReference p = Page.FINETProgramView;
                    p.getParameters().put('Id', prog.Id);
                    p.setRedirect(true);
                    return p;
                }
                else
                return null;
                   
                
              } 
              catch(Exception e){
                Database.rollback(sp);
                 
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                return null;
            }
            
      
       
        } 
    

     }