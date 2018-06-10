global with sharing class RiskAssessmentRatingEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID grantId{get;set;}
    public PageReference savePage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
     
    public RiskAssessmentRatingEditCtrl (ApexPages.StandardController stdController){

        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        grantId = ApexPages.CurrentPage().getParameters().get('grantid'); 
        savePage = Page.RiskAssessmentView;  
      
        savePage.getParameters().put('id', recordId);
        
        
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (grantId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
            //DynamicLayoutDefaultValueHelper accountDv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__r.'+AppUtils.getNamespacePrefix()+'ExternalOrganization__c',accountId,false);
            listDefaultValues.add(dv);
            //listDefaultValues.add(accountDv);
            savePage.getParameters().put('grantid', grantId);
        }

       
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',recordId);
        if (grantId != null){
            keyValueMap.put('grantid',grantId);
        }
        
        return JSON.serialize(keyValueMap);
    }
}