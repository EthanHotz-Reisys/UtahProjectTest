public with sharing class AssignCaseCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public String recordType {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    
    public AssignCaseCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');           
        savePage = New PageReference('/apex/CasesMaster');
        cancelPage = New PageReference('/apex/CasesMaster'); 
    }
          
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));      
        return JSON.serialize(keyValueMap);
    }
}