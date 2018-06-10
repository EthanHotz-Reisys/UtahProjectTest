public with sharing class AnnouncementDocumentEditCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public AnnouncementDocumentEditCtrl (ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        Id parentId  =  ApexPages.CurrentPage().getParameters().get('parentId');
        savePage.getParameters().put('Id', recordId);
        cancelPage.getParameters().put('Id', recordId);  
        
        
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (parentId != null){            
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',parentId,true);
            listDefaultValues.add(dv);
        }      
    }
    
}