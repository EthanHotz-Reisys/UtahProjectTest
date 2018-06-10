/**
* Edit page controller for the ProgressReportResult__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 08/4/2015    Nishit Babaria   Created
* =============================================================================
*/

public with sharing class SiteVisitActivityAddEditCtrl {

    //properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String resultType {get;set;}
   
    public SiteVisitActivityAddEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String siteVisitId = ApexPages.CurrentPage().getParameters().get('siteVisitId');
        String requestType = ApexPages.CurrentPage().getParameters().get('requestType');
        String recType  = ApexPages.CurrentPage().getParameters().get('recType');
        
        savePage = Page.SiteVisitActivityAddView;
        savePage.getParameters().put('id', recordId);
        if(recordId != null){
            cancelPage = Page.SiteVisitActivityAddView;
            cancelPage.getParameters().put('id', recordId);
            
        }

        
        if(requestType=='External')
        {
             pageTemplateName= 'SiteVisitFindingTemplate';
        }
        else
        {
           pageTemplateName= 'SiteVisitActivityTemplate';
        }


        RecordType recordType = [Select Id,DeveloperName from RecordType where DeveloperName =:requestType and sObjectType =: AppUtils.getNamespacePrefix()+'SiteVisitActivity__c'];
        system.debug('--recordType--'+recordType);
       	listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SiteVisit__c',siteVisitId,true);
       	listDefaultValues.add(dv1);
        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);
        listDefaultValues.add(dv2);
      	
              
    }
    
    public string getKeyValueMap() {
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('siteVisitActivityId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}