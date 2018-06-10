public with sharing class SectionMappingEditCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public SectionMappingEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'Application Section Mapping';
     //   savePage = Page.RolesAndResponsibilitiesView;
    //   savePage.getParameters().put('id', recordId);         
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();                
    }
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));        
        return JSON.serialize(keyValueMap);
    }
}