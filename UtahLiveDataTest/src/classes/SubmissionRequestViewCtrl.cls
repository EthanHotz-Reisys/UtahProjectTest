public with sharing class SubmissionRequestViewCtrl{
    //Properties
    public ID recordId{get;set;}
    //public String save;
    public PageReference savePage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public SubmissionRequestViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        //save= ApexPages.CurrentPage().getParameters().get('save');
        
    }


     public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',ApexPages.currentPage().getParameters().get('id')); 
        return JSON.serialize(keyValueMap);
    }

   
}