/*
  <Purpose of this class>    
    *******************************************************************************************************************
    Audit History
    ********************************************************************************************************************
    2017-04-01  Shah Kadirmohideen  Code Reviewed
    **********************************************************************************************************************  
*/ 
global with sharing class CaseCloseCtrl extends GNT.DynamicLayoutActionRedirect {
  
    global override Pagereference whenClicked()
    {
        //Shah 4/28/2017 Commenting out since we should not be using native Case object
        /*
    try{
       Map<String, SObject> recordMp= layoutHolder.recordMap;
       
       Case caseObj=(Case) recordMp.get('Case');
        
          caseObj.Status='Closed';
        caseObj.Status__c='Closed';
        caseObj.Detailed_Comments__c='Closed by the Requester';
      
        //Shah CRF: hardcoded error message
        ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,'The case has been closed' );
        //ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.INFO,GNT.ErrorMessageHelper.fetchMessage('P17-GRNTE-80225') );
        ApexPages.addmessage(msg);
        Update caseObj;
       
        }catch(Exception e)
        {
        //Shah CRF: exception is ignored which is dangerous
        system.debug(e.getMessage());
        }
         Pagereference pg = new Pagereference('/apex/FlexTableView?flexTableName=ExternalCaseDetails');
        pg.setRedirect(true);
        return pg;
        */
        return null;
    }
    
    
}