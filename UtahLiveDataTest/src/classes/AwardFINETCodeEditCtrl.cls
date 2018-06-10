public with sharing class AwardFINETCodeEditCtrl {
    
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public AwardFINETCodeEditCtrl (ApexPages.StandardController stdController) {
        String awardId = ApexPages.CurrentPage().getParameters().get('awardId');
        pageTemplateName = 'AwardFINETCodeEdit';
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Award__c',awardId,true);
        listDefaultValues.add(dv);
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
}