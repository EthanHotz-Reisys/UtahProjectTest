public with sharing class FormEdit {

    public ID recordId{get;set;}
    public ID pkId {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public String templateName {get; set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}

    public FormEdit(ApexPages.StandardController stdController) {
         recordId = ApexPages.CurrentPage().getParameters().get('id');
         System.debug(' RECORD ID VALUE IS 00 '+ recordId);  
         pkId = ApexPages.CurrentPage().getParameters().get('pkId');   
         pageTemplateName = ApexPages.CurrentPage().getParameters().get('template'); 
 
         List<GNT__PackageFormConfig__c> form = [Select GNT__FormConfig__c ,GNT__ObjectAPIName__c ,GNT__PackageConfig__c from  GNT__PackageFormConfig__c where  GNT__PackageConfig__c=: pkId and GNT__FormConfig__r.Name =: pageTemplateName ];
         
         if(form != null && form.size()> 0){ 
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
              GNT.DynamicLayoutDefaultValueHelper dv0 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PackageConfig__c',pkId,true);

         }
         else{
              listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
              GNT.DynamicLayoutDefaultValueHelper dv0 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PackageConfig__c',pkId,true);
         }
    } 
}