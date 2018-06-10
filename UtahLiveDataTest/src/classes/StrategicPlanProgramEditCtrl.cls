public with sharing class StrategicPlanProgramEditCtrl {
	public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public StrategicPlanProgramEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   

        pageTemplateName = 'Strategic Plan Program';//TODO get template dynamically from sObjectConfig
        
        savePage = Page.StrategicPlanProgramView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.StrategicPlanProgramView;
            cancelPage.getParameters().put('id', recordId);   
        }

        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        Id StrategicPlanid = ApexPages.CurrentPage().getParameters().get('StrategicPlanid');
        if (StrategicPlanid != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StrategicPlan__c',StrategicPlanid,true);
            listDefaultValues.add(dv);
        }
        
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
	

}