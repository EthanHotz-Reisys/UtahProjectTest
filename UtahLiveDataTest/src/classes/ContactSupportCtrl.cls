public with sharing class ContactSupportCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public transient String previousTabName {get; set;}
 
   
    public ContactSupportCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');       
        GNT.AppUtils.setTabCookie();  
        previousTabName = GNT.AppUtils.getSelectedTabName();     
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('recordId',ApexPages.currentPage().getParameters().get('id'));      
        return JSON.serialize(keyValueMap);
    }
}