public with sharing class CloseoutRequestEditCtrl {
    public ID recordId{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public String packageId {get;set;}
    public ID grantId{get;set;}
    public ID awardId{get;set;}    
    
    public CloseoutRequestEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        savePage = Page.CloseoutRequestView;
        savePage.getParameters().put('id', recordId);
        pageTemplateName='CloseoutRequest';               
        Closeout__c cr;
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(recordId != null){
            cancelPage = Page.CloseoutRequestView;
            cancelPage.getParameters().put('id', recordId);
             cr = [select id, grant__c, award__c from Closeout__c where id=:recordId];
            grantId = cr.grant__c;
            awardId = cr.award__c;
            List<BusinessPackage__c> bc = [select PackageConfig__c from BusinessPackage__c where PackageType__c='Closeout' and Grant__c=:grantId];
            if(bc.size() > 0)
            packageId = bc[0].PackageConfig__c;
        }else{
            grantId = ApexPages.CurrentPage().getParameters().get('grantId');
          //  cancelPage = Page.GrantView;
         //   cancelPage.getParameters().put('id', grantId);
            if (grantId != null){  
                //TODO get template dynamically from sObjectConfig
                system.debug('**grantId '+grantId);
                List<Award__c> awardList = [Select Id, Name, Comptroller__c, GrantAdministrator__c from Award__c where Grant__c=:grantId and Status__c='Activated'];
                system.debug('**awardList '+awardList);

                if(awardList==null || awardList.size()==0){
                     // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Active Award found')); 
                     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('GEN-GRNTR-21745'))); 
                }
                else{
                    Award__c award = awardList[0];
                      awardId = award.Id;
                     GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);                         
                     GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Status__c','Created',true);
                     GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Title__c','',true);
                     GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'POApprover__c',award.Comptroller__c,true);
                     GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FOApprover__c',award.GrantAdministrator__c,true);
                     List<BusinessPackage__c> bc = [select PackageConfig__c from BusinessPackage__c where PackageType__c='Closeout' and Grant__c=:grantId];
                     if(bc.size() > 0)
                     packageId = bc[0].PackageConfig__c;
                        if(awardId <> null){
                    
                }                
                listDefaultValues.add(dv);
                listDefaultValues.add(dv1);
                listDefaultValues.add(dv2);
                listDefaultValues.add(dv3);
                listDefaultValues.add(dv4);

                if(awardId <> null){
                 GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
                    listDefaultValues.add(dv5);
                }
                }
            }  
        } 
    } 
    
      public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('closeOutId',ApexPages.currentPage().getParameters().get('id'));
        }
        keyValueMap.put('grantId',grantId);
        if(awardId <> null){
            keyValueMap.put('awardId',awardId); 
        }       
        return JSON.serialize(keyValueMap);
    }
    
}