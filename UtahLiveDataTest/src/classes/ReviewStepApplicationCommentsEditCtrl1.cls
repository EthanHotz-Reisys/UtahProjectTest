public with sharing class ReviewStepApplicationCommentsEditCtrl1 extends GNT.MasterCtrl{
     //Properties
    public Id recordId {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String templateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    String appTitle = '';
    Boolean completedRSA = false;
    Map<String,Object> resultMap = new Map<String, Object>();
    public ReviewStepApplicationCommentsEditCtrl1(ApexPages.StandardController stdController){
        
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        system.debug('recordId is ' +recordId);
        Id revStepId = ApexPages.CurrentPage().getParameters().get('revStepId');
        system.debug('revStepId is ' +revStepId);
        templateName = 'RSAAwardWithReservationTemplate';
        savePage = Page.ReviewStepApplicationCommentsView;
        savePage.getParameters().put('id',recordId);
        //listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        
        //ReviewStepApplication__c temp = (ReviewStepApplication__c)stdController.getRecord();
        //temp.Decision__c = 'Rejected';
        //List<ReviewStepApplication__c> rsaList = [SELECT id,name,Comments__c,ReviewStep__c,Status__c,Decision__c,IsOGMPromoted__c, Application__r.Id , Application__r.Name FROM ReviewStepApplication__c WHERE ReviewStep__c = :revStepId AND id = :recordId LIMIT 1];
        //cancelPage = Page.ReviewStepApplicationCommentsView;
       // cancelPage.getParameters().put('id',recordId);
        //String decision = 'Rejected';
        //rsaList[0].Decision__c = 'Rejected';
        //GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Decision__c','Rejected',true);
        //listDefaultValues.add(dv);
        
        //GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewStep__c',revStepId,true);
        //GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ReviewStepApplication__c',recordId,true);
        //GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Decision__c','Rejected',true);
        //listDefaultValues.add(dv);
        //listDefaultValues.add(dv1);
        //listDefaultValues.add(dv2);
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
}