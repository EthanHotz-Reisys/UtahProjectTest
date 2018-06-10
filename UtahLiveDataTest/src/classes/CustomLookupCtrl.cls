public with sharing class CustomLookupCtrl {

    public String tableId { get; set; }
    public String displayFields { get; set; }
    public String sobjectName { get; set; }
    
    public CustomLookupCtrl(){
        String objectType = ApexPages.currentPage().getParameters().get('lookupType');
        String emptyId = '000000000000AAA';
        String objectName;
        if(objecttype.containsIgnoreCase('user')){
                objectName = 'User';    
        }else{
            Id objectId = objectType + emptyId;
            objectName =  objectId.getSObjectType().getDescribe().getName();
        }
        String pageBlockDetailId = ApexPages.currentPage().getParameters().get('pageBlockDetailId');
        if(String.isNotEmpty(pageBlockDetailId)){
            List<GNT__PageBlockDetailConfig__c> pbdList = [SELECT Id,Name,GNT__DisplayLookupFieldNames__c FROM GNT__PageBlockDetailConfig__c WHERE Id = :pageBlockDetailId];
            if(pbdList.size() > 0){
                String displayFieldsTemp = pbdList[0].GNT__DisplayLookupFieldNames__c;
                if(String.isNotEmpty(displayFieldsTemp)){
                    displayFields = displayFieldsTemp;
                    sobjectName = objectName;
                }else{
                    String query = 'select GNT__DisplayFieldsAPIName__c,Name from GNT__SobjectConfig__c where Name =\'' +objectName  + '\'' ; 
                    List<GNT__SobjectConfig__c> sobjectConfig = Database.query(query);
                    if(sobjectConfig . size () > 0){
                        displayFields = sobjectConfig[0].GNT__DisplayFieldsAPIName__c;
                        sobjectName = sobjectConfig[0].Name; 
                    }else{
                        displayFields = 'Id,Name';
                        sobjectName = objectName;
                    }
                }
            }
        }
        else {
            displayFields = 'Id,Name';
            sobjectName = 'Account';
        }
         
    }
}