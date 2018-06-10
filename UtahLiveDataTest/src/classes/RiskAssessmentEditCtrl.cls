global with sharing class RiskAssessmentEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID grantId{get;set;}
    public ID programId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String templateName {get;set;}
    public Boolean hideCancelBtn {get;set;}
    public String packageId {get;set;}
    private  RiskAssessment__c riskObj;
    
    public RiskAssessmentEditCtrl (ApexPages.StandardController stdController){
        
        recordId  = ApexPages.CurrentPage().getParameters().get('id');  
        grantId   = ApexPages.CurrentPage().getParameters().get('grantid');  
        programId = ApexPages.CurrentPage().getParameters().get('programId');         
        String requestType= ApexPages.CurrentPage().getParameters().get('requestType');  
        savePage = Page.RiskAssessmentView; 
        savePage.getParameters().put('id', recordId);
       // hideCancelBtn = true;
        cancelPage = Page.GrantView;
        if(grantId!=null){
        cancelPage = Page.GrantView;
        cancelPage.getParameters().put('id', grantId);
        }        
        else{
        cancelPage = Page.RiskAssessmentView;
        cancelPage.getParameters().put('id', recordId);    
        }        
        List<BusinessPackage__c> bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Risk Assessment' and Grant__c=:grantId limit 1];
        if(bizPkg!=null && bizPkg.size()>0){
            packageId=bizPkg[0].PackageConfig__c;            
        }
 
        if(recordId!=null){
        savePage.getParameters().put('id', recordId);       
            List<RiskAssessment__c> raList = [SELECT Id,Name,Grant__r.RiskAssessmentPackage__r.GNT__PageTemplateConfig__r.Name,CreatedDate,LastModifiedDate 
                                                FROM RiskAssessment__c  WHERE Id =:recordId];
            System.debug('raList ---'+raList );
            if(raList.size() > 0){
                templateName = raList[0].Grant__r.RiskAssessmentPackage__r.GNT__PageTemplateConfig__r.Name;       
        }
        
      }
      listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (grantId != null){
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);            
            listDefaultValues.add(dv);            
            savePage.getParameters().put('grantid', grantId);
            savePage.getParameters().put('programId', programId);
            checkCloseout(grantId);
        }
        if (programId != null){
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);            
            listDefaultValues.add(dv1);            
            savePage.getParameters().put('programId', programId);
        }        
        GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('Type__c',requestType,true);
            listDefaultValues.add(dv2);
             
            templateName='Risk Assessment Report';
             
    }
    
    private void checkCloseout(Id grantId){
        List<Closeout__c> closeout = new List<Closeout__c>([SELECT Id, Grant__c, Grant__r.isClosedOut__c FROM Closeout__c WHERE Grant__c =: grantId LIMIT 1]);
        if(!closeout.isEmpty() && closeout[0].Grant__r.isClosedOut__c != null && closeout[0].Grant__r.isClosedOut__c){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The selected Grant has been Closed Out. Please return to the previous screen.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-56207')));                                
        }
        else if(closeout.size() > 0){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Closeout is in process for the Grant. Please return to the previous screen.'));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, GNT.ErrorMessageHelper.fetchMessage('M01-GRNTR-95188')));                
        }
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('id',recordId);
        if (grantId != null){
            keyValueMap.put('grantid',grantId);
        }
        if (programId != null){
            keyValueMap.put('programId',programId);
        }

        keyValueMap.put('riskAssessmentId',ApexPages.currentPage().getParameters().get('Id'));  
        
        return JSON.serialize(keyValueMap);
    }

    public PageReference redirect(){

        PageReference pageRef = null;
        RiskAssessment__c riskObj = [Select Status__c from RiskAssessment__c where id=:recordId];
        if(riskObj.Status__c.equalsIgnorecase('In Progress') ){
            //pageRef = new PageReference('/apex/'+AppUtils.getNamespacePrefix()+'RiskAssessmentView?id='+recordId);

        }else{
            pageRef = new PageReference('/apex/'+AppUtils.getNamespacePrefix()+'RiskAssessmentView?id='+recordId);            
        }
        return pageRef;
    }
}