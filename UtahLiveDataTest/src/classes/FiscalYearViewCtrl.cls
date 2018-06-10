public with sharing class FiscalYearViewCtrl {

    public ID recordId {get;set;}
    public String templateName{get;set;} 
    public PageReference cancelPage {get;set;}
    
    public FiscalYearViewCtrl(ApexPages.StandardController stdController) {
          System.debug(' -------------------the recordId Log is <<<< ');
        recordId = ApexPages.CurrentPage().getParameters().get('id');
   
              templateName = 'FiscalYearView';   
    } 
        
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        System.debug(' >>>the Debug Log is <<<< '+recordId);
       /* keyValueMap.put('orgId', recordId); */
        return JSON.serialize(keyValueMap);
    }
}