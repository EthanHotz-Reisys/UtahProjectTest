/*
    
    ***********************************************************
    Audit History
    ***********************************************************
    03/2/2016      Davinder Singh             Created
    *********************************************************** 
*/

global with sharing class SiteVisitedHelper extends GNT.DynamicLayoutActionRedirect {
    
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
    global override PageReference whenClicked(){
 
        Savepoint sp = Database.setSavepoint();
        String errorMsg;
        Id recordId ;
        SiteVisit__c siteVisit;
        try{

            recordId = apexpages.currentpage().getparameters().get('id');
            siteVisit = [SELECT Id,Name,ReviewedGrantFile__c,Discussedobjectivesforvisit__c, DetermineIssuestoDiscuss__c
                                        FROM SiteVisit__c WHERE ID = : recordId];
    
        
        system.debug('Inside SiteVisitedHelper---'+siteVisit);
              if(siteVisit.ReviewedGrantFile__c==false || siteVisit.Discussedobjectivesforvisit__c==false  || siteVisit.DetermineIssuestoDiscuss__c==false)
             {
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please complete the details for the Visit in Step 2 (Reviewed Grant File, Discussed objectives for visit, Determine Issues to Discuss)'));
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-18582')));
               return null;
             }
              
        }
        catch(Exception e){
            Database.rollback(sp);
            errorMsg = e.getMessage();
            
        }

        try {
            siteVisit.Status__c='Visited';
            update siteVisit;

        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Site Visit has been updated.'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-57935')));
        PageReference p = Page.SiteVisitView;
        p.getParameters().put('Id',recordId);
        p.setRedirect(true);
        return p;

        }
        catch(Exception e) {
            system.debug(e.getMessage());
        }
        
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));  
     return null;
    }
    
     
    }