public with sharing class StrategicPlanEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String pbdIds{get;set;}
    private Account accnt;
 
    public StrategicPlanEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');  
        List<User> strategicOwner = new List<User>(); 
        strategicOwner = [select GNT__OrganizationId__c from user where Id = :UserInfo.getUserId()];
        accnt = [Select id from Account where id=:(ID)strategicOwner[0].GNT__OrganizationId__c];

        pageTemplateName = 'Strategic Planning';//TODO get template dynamically from sObjectConfig
        savePage = Page.StrategicPlanView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {       
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
        }
    }
    
    public PageReference redirectForExtUsers(){
       if(GNT.AppUtils.isSite()){ 
            PageReference loginPage=  Page.CommunitiesLanding;
            loginPage.setRedirect(true);
            loginPage.getParameters().put('announcementId', ApexPages.CurrentPage().getParameters().get('announcementId'));
            loginPage.getParameters().put('preApplication', 'true');
            return loginPage;
       } 
        return null;
    } 

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('StrategicPlanid',ApexPages.currentPage().getParameters().get('id'));
        return JSON.serialize(keyValueMap);    
    }
}