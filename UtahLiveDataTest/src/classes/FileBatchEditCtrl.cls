public with sharing class FileBatchEditCtrl {
    
    public String recordId{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference savePage{get;set;}
    public String cancelPage{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public Set<Id> finops;
    public Boolean isFinops{get;set;}
    public String profileType{get;set;}

    public FileBatchEditCtrl (ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        pageTemplateName = 'FileBatchEdit';
        Id batchRecordTypeId = Schema.SObjectType.FileBatch__c.getRecordTypeInfosByName().get(ApexPages.CurrentPage().getParameters().get('batchType')).getRecordTypeId();
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',batchRecordTypeId,true);
        listDefaultValues.add(dv);
        finops = new Set<Id>();
        //Group finopGroup = [SELECT Id, Name FROM Group WHERE Type = 'Regular' AND Name = 'USBEFINOPS'];
        //List<GroupMember> finopGroupMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE GroupId = :finopGroup.Id];
        List<User> finopGroupMembers = [SELECT Id FROM User WHERE ProfileName__c = 'EXE'];
        for(User gm : finopGroupMembers){
            //finops.add(gm.UserOrGroupId);
            finops.add(gm.Id);
        }

        isFinops = finops.contains(UserInfo.getUserId());
        profileType = 'EXE';
    }

    public String getKeyValueMap(){
        Map<String,Object> keyValueMap = new Map<String,Object>();
        keyValueMap.put('finops', finops); 
        keyValueMap.put('profileType', profileType);
        keyValueMap.put('isFinops', isFinops);
        return JSON.serialize(keyValueMap);
    }

}