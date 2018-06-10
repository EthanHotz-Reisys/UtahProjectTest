global with sharing class DynamicViewLayoutCtrl {
    public String recordId {get; set;}
    public String templateName {get; set;}
    public String isPreview {get; set;}
    public String keyValueMapJSON {get; set;}
    public PageReference deleteURL {get; set;}
    public String expandTextCharSize{get;set;}
    public String layoutId{get;set;} //for form header in planning preview

    global DynamicViewLayoutCtrl() {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        templateName = ApexPages.CurrentPage().getParameters().get('template');
        keyValueMapJSON = ApexPages.CurrentPage().getParameters().get('keyValueMapJSON');
        if(keyValueMapJSON == null){
            Map<String,String> keyValueMap = new Map<String,String>();        
            keyValueMap.put('parentId', '');
            keyValueMap.put('recordId', '');
            keyValueMapJSON = JSON.serialize(keyValueMap);
        }
        isPreview = ApexPages.CurrentPage().getParameters().get('isPreviewLayout');
        if(String.isEmpty(templateName)){
            layoutId = ApexPages.CurrentPage().getParameters().get('layoutId');
            Id formPackageId = ApexPages.CurrentPage().getParameters().get('formPackageId');
            Id templateId  = ApexPages.CurrentPage().getParameters().get('templateId');
            if( formPackageId != null && layoutId == null){
                List<GNT__PackageFormConfig__c> packageFormList = [select id,GNT__FormConfig__r.Name from GNT__PackageFormConfig__c where Id=:formPackageId];
                if(packageFormList.size() > 0) {
                    templateName = packageFormList[0].GNT__FormConfig__r.name;
                }
            }
            if(layoutId != null){
                List<GNT__PageTemplate__c> pgTemp = [select name from GNT__PageTemplate__c where GNT__ViewLayoutConfig__c =:layoutId];
                if(pgTemp.size () > 0){
                    templateName = pgTemp[0].name;
                }
            }else if(templateId != null){
                List<GNT__PageTemplate__c> pgTemp = [select name from GNT__PageTemplate__c where id =:templateId];
                if(pgTemp.size () > 0){
                    templateName = pgTemp[0].name;
                    System.debug('template Name--->>>'+templateName);
                }   
            }
            if(templateId !=null) {
                List<GNT__PageTemplate__c> pgTemp = [SELECT GNT__ViewLayoutConfig__c,Name FROM GNT__PageTemplate__c WHERE Id =: templateId AND RecordType.Name = 'Business Form'];
                if(pgTemp.size () > 0) {
                    layoutId = pgTemp[0].GNT__ViewLayoutConfig__c;
                }
            }
            
            
        }
        expandTextCharSize = GNT.KeyValueStoreHelper.getTextValue('CollapseInstMaxChar',true);
        String deleteURLString = ApexPages.CurrentPage().getParameters().get('deleteURL');
        if (!String.isEmpty(deleteURLString)) {
            deleteURL = new PageReference(deleteURLString);
        }
    }

    /* PRIVATE METHODS */

}