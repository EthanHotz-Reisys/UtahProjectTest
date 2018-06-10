public with sharing class MatchTrackingEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pbdIds{get;set;}
    private Account accnt;
 
    public MatchTrackingEditCtrl(ApexPages.StandardController stdController){
     listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        recordId = ApexPages.CurrentPage().getParameters().get('id'); 
        Id paymentRequestID =  ApexPages.CurrentPage().getParameters().get('parentid');
        
        pageTemplateName = 'Match Tracking';//TODO get template dynamically from sObjectConfig
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('PaymentRequest__c',paymentRequestID,true);
        listDefaultValues.add(dv);
        savePage = Page.MatchTrackingView;
        savePage.getParameters().put('id', recordId); 
        
       /* if (!String.isEmpty(recordId)) {       
            cancelPage = Page.StrategicPlanView;
            cancelPage.getParameters().put('id', recordId);   
        }else{ 
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            GNT__UserPreferences__c pref = GNT__UserPreferences__c.getInstance(UserInfo.getUserId());
            Id accId = null;
            for(Account acc: [SELECT Id from Account Where Id = :pref.GNT__OrganizationAccountName__c Limit 1]){
                accId = acc.id;
            } 
             
            if(accId != null){
             GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Agency__c', accId, false);
                listDefaultValues.add(dv);
            }
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'StrategyOwner__c',UserInfo.getUserId(),true);
            listDefaultValues.add(dv1);
            GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Agency__c',accnt.Id,true);
            listDefaultValues.add(dv2);
        }  */
    }
    
    

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
     //   keyValueMap.put('StrategicPlanid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);    
    }
}