global with sharing class ApproveProgressReportCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
        String recordId = ApexPages.CurrentPage().getParameters().get('id');
        Pagereference pg = null;
        Id rptId;
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        List<ProgressReports__c> listReport = [SELECT Id, Name,FormsValidated__c, SubmittedBy__c,SubmittedOn__c,Status__c FROM ProgressReports__c WHERE Id=:recordId  LIMIT 1];   
        
        if(listReport!=null && listReport.size()>0){
            ProgressReports__c rpt = listReport[0];
        
            if(rpt.FormsValidated__c == false){
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Forms needs to be validated before the Progress Report can be submitted.')); 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-55105')));
                return null;
            }            
        
            
            rptId=rpt.Id;
            
            if(appName == 'StateasGrantee' || appName == 'Recipient'){    
                rpt.Status__c = 'Submitted for Approval';
                update rpt;     
                GNT.TaskCreationHandler.createApprovalProcessTasks(rpt.Id, 'Internal Approval', rpt.Name, null, System.TODAY() + 7, rpt.Name, true);
                
                // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Progress Report has been submitted for Approval successfully.')); 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-72631')));                   
            }
            else if(appName == 'StateasGrantor'){
                rpt.SubmittedBy__c=UserInfo.getUserId();
                rpt.SubmittedOn__c=System.Today();
                rpt.DateReportSubmitted__c=System.Today();
                update rpt;
            }
       }
        PageReference p = Page.ProgressReportView;
        p.getParameters().put('Id', rptId);
        p.setRedirect(true);
        return p; 
    }
 }