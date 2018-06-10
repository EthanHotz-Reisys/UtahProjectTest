public with sharing class RiskAssessmentViewCtrl {
    public ID recordId{get;set;}
    public String templateName {get;set;}
    public String packageId {get;set;}
    public List<string> formTypes {get;set;}
    private List<BusinessPackage__c> bizPkg;
    private String grantId;
    
    public RiskAssessmentViewCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        //grantId = ApexPages.CurrentPage().getParameters().get('grantid');
        String programId = ApexPages.CurrentPage().getParameters().get('programid');
        formTypes = new List<string>();

        RiskAssessment__c riskAssessment = [Select Id,Name,Grant__c,Grant__r.Program__c, Area__c from RiskAssessment__c where id =:recordId ];

        grantId = riskAssessment.Grant__c;
        
        if(programId!=null){
           bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Risk Assessment' and 
                                            Program__c =:programId];
        }
        else{
           bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Risk Assessment' and 
                                            Grant__c =:grantId];
        }
        if(bizPkg!=null && bizPkg.size()>0){
            packageId=bizPkg[0].PackageConfig__c;
            System.debug('packageId--------------->' + packageId);
         }

        if(riskAssessment.Area__c=='Fiscal') {
            formTypes.add('Finance');
        } else {
            formTypes.add('Program');
        }

        /*List<RiskAssessment__c> raList = [SELECT Id,Name,Grant__r.RiskAssessmentPackage__r.GNT__PageTemplateConfig__r.Name FROM RiskAssessment__c WHERE Id =:recordId];
      
        if(raList.size() > 0){
            templateName = raList[0].Grant__r.RiskAssessmentPackage__r.GNT__PageTemplateConfig__r.Name; 
        }*/
       // templateName='RiskAssessmentView';
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('riskAssessmentId',ApexPages.currentPage().getParameters().get('id'));        
        return JSON.serialize(keyValueMap);
    }
}