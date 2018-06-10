/**
* Edit page controller for the TermConditionSchedule__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 02/26/2015    Nishit Babaria   Created
* =============================================================================
*/

public with sharing class TermConditionScheduleNewCtrl{

    //properties
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public ID termConditionId {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    
    public TermConditionScheduleNewCtrl(){
        pageTemplateName = ApexPages.CurrentPage().getParameters().get('template');
        termConditionId = ApexPages.CurrentPage().getParameters().get('termConditionId'); 
        savePage = Page.TermConditionView;
        savePage.getParameters().put('id', termConditionId);
        if(termConditionId != null){
            cancelPage = Page.TermConditionView;
            cancelPage.getParameters().put('id', termConditionId);
        }
		
		listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(termConditionId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TermAndCondition__c',termConditionId,true);
            listDefaultValues.add(dv);  
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(termConditionId != null){
            keyValueMap.put('termConditionId',termConditionId);
        }
        return JSON.serialize(keyValueMap);
    }
}