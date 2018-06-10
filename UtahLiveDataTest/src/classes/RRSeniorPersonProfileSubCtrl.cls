public with sharing class RRSeniorPersonProfileSubCtrl{

    public ID recordId {get;set;}
    public Id parentId {get;set;}
    public List <GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
     
    public RRSeniorPersonProfileSubCtrl(ApexPages.StandardController stdController){
    parentId =  ApexPages.CurrentPage().getParameters().get('ParentId');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (parentId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('ParentForm__c',parentId,true);
            listDefaultValues.add(dv);            
        }
    }
}