global with sharing class ServiceAreaEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private Account accnt;
      
    public ServiceAreaEditCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'ServiceArea';
        savePage = Page.ServiceAreaView;
        savePage.getParameters().put('id', recordId);
        cancelPage = Page.ServiceAreaView;
        cancelPage.getParameters().put('id', recordId); 
        
        List<User> owner = new List<User>(); 
		owner = [select GNT__OrganizationId__c from user where Id = :UserInfo.getUserId()];
		accnt = [Select id from Account where id=:(ID)owner[0].GNT__OrganizationId__c];
		
		listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
		GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Owner__c',UserInfo.getUserId(),true);
		listDefaultValues.add(dv1);
		GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Account__c',accnt.Id,true);
		listDefaultValues.add(dv2);
        // pageTemplateName = 'Service Area';
        // String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
       //  if(appName != null && appName == 'StateasGrantee'){          
       //  }   
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('serviceareaid',recordId);
        return JSON.serialize(keyValueMap);
    }
   
}