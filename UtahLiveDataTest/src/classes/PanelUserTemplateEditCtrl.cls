public with sharing class PanelUserTemplateEditCtrl{

    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public PanelUserTemplateEditCtrl(ApexPages.StandardController stdController){
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        Id reviewPanelId = ApexPages.CurrentPage().getParameters().get('reviewPanelId');   
        savePage = Page.ReviewPanelTemplateView;
        savePage.getParameters().put('id', reviewPanelId);
        cancelPage = Page.ReviewPanelUserTemplateView;
        PanelUserTemplate__c panelUserTemplate = (PanelUserTemplate__c)stdController.getRecord();       
        if(stdController.getId() != null){ // Edit existing
            cancelPage.getParameters().put('id', recordId);
        }else{    //New
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewPanelTemplate__c',reviewPanelId , true);
            listDefaultValues.add(dv);
            cancelPage.getParameters().put('id', 'recordId');
        } 
        
        String reviewPanelType;
        try {
            List<ReviewPanelTemplate__c> currentReviewPanel = [SELECT Id, Name FROM ReviewPanelTemplate__c WHERE Id =: reviewPanelId];
            reviewPanelType = currentReviewPanel[0].Name;
            if (reviewPanelType == 'SME Review Panel') {
                reviewPanelType = 'SME';
            }
            else {
                reviewPanelType = 'NOTSME';
            }
            ApexPages.currentPage().getParameters().put('ReviewPanelType', reviewPanelType);
        }
        catch (Exception e) {
            System.debug('Error: ' + e);
        }
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('PanelUserId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('ReviewPanelType', ApexPages.currentPage().getParameters().get('ReviewPanelType'));
    
        return JSON.serialize(keyValueMap);
    }
}