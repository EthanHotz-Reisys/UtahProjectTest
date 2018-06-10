public with sharing class ReviewerContactCtrl {
    //Properties
    public ID recordId{get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ReviewerContactCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        pageTemplateName = 'Reviewer Contact';
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();    
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        return JSON.serialize(keyValueMap);
    }

}