public with sharing class PreviewPackageCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID businessPackageId{get;set;}
            
    public PreviewPackageCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        businessPackageId = ApexPages.CurrentPage().getParameters().get('businessPackageId');
        if( businessPackageId != null ){
        	recordId = [select packageConfig__c from BusinessPackage__c where id=:businessPackageId].packageConfig__c;
        }
    }
    
    /*
        Method to populate the parameters for the FlexTable
    */
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('packageId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}