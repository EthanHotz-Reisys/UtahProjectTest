public with sharing class FINETProgramRolesandRespCtrl{
    
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    //public String savePage{get;set;}
    //public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public FINETProgramRolesandRespCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'Roles and Responsibilities 12';
        String recordTypeName = ApexPages.CurrentPage().getParameters().get('RecordType');
        System.debug('recordTypeName = '+recordTypeName);
        RecordType recordType = [
                    SELECT Id, DeveloperName 
                    FROM RecordType 
                    WHERE DeveloperName =: recordTypeName AND sObjectType =: AppUtils.getNamespacePrefix()+'RolesAndResponsibilities__c'];
         System.debug('recordType = ' + recordType);
                
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
         
        Id finetprogID = ApexPages.CurrentPage().getParameters().get('finetprogramid');
              
        if (finetprogID != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FINETProgram__c',finetprogID,true);            
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',recordType.Id,true);  
            listDefaultValues.add(dv);
            listDefaultValues.add(dv1);
        }
            
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>(); 
        return JSON.serialize(keyValueMap);
    }
}