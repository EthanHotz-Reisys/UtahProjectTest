public with sharing class SiteVisitPersonAddCtrl{
    
    //Properties
    public String siteVisitId{get;set;}
    public String userType {get;set;}
    public ReviewPanel__c reviewPanel {get;set;}
    public ID organizationId {get;set;}
    public ID recordId{get;set;}
  //  public String flexTableHeader {get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public SiteVisitPersonAddCtrl(){
          recordId = ApexPages.CurrentPage().getParameters().get('id');
          siteVisitId = ApexPages.CurrentPage().getParameters().get('siteVisitId'); 
          String userType=ApexPages.CurrentPage().getParameters().get('userType'); 
     //   userType = ApexPages.CurrentPage().getParameters().get('userType');
         organizationId= ApexPages.CurrentPage().getParameters().get('orgId');

     if(userType=='Internal'){

         pageTemplateName = 'Site Visit Person';
     }
     else
     {
         pageTemplateName = 'Site Visit External Person';
     }
        
          savePage = Page.SiteVisitView;
     //  savePage.getParameters().put('id', recordId); 
         cancelPage = Page.SiteVisitView;
     //   cancelPage.getParameters().put('id', recordId); 

           listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();     

         GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SiteVisit__c',siteVisitId,true);
         listDefaultValues.add(dv);
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();   
   //     keyValueMap.put('id', recordId);   
        system.debug('**organizationId--'+organizationId); 
        keyValueMap.put('orgId',organizationId);   
        keyValueMap.put('email','pankaj.hingane@reisystems.in');   
        return JSON.serialize(keyValueMap);
    }

 

   
    
}