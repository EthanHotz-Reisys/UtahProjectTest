public with sharing class FOALeadEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private Account accnt;
    public FOALeadEditCtrl(ApexPages.StandardController stdController){  
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        List<User> userlist = new List<User>();
        userlist = [Select GNT__OrganizationId__c from User where Id =:UserInfo.getUserId()];
        accnt = [Select id from Account where id=:(ID)userlist[0].GNT__OrganizationId__c];
        pageTemplateName = 'FOA Lead';//TODO get template dynamically from sObjectConfig
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(accnt.id != null){
         GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RecipientAgency__c',accnt.id,true );
            listDefaultValues.add(dv1);
        }
        savePage = Page.FOALeadView;
        savePage.getParameters().put('id', recordId); 
        
        if (!String.isEmpty(recordId)) {
            cancelPage = Page.FOALeadView;
            cancelPage.getParameters().put('id', recordId);   
        } 
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }
}