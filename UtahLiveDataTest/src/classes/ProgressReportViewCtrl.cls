/**
* View page controller for ProgressReports__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 09/04/2015    Davinder Singh    Created
* =============================================================================
*/

public with sharing class ProgressReportViewCtrl {
    //Properties
    public ID recordId{get;set;}
    public PageReference deleteURL{get;set;}
    public String pageTemplateName {get;set;}
    public String packageId {get;set;}
    public List<string> formTypes {get;set;}
    private String grantId,awardId;
    private List<BusinessPackage__c> bizPkg;
      
    
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    
    public ProgressReportViewCtrl(ApexPages.StandardController controller){
        formTypes = new List<string>();
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        System.debug('recordId------------------->' + recordId); //ApexPages.CurrentPage().getParameters());
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        ProgressReports__c progReport = [Select Award__r.Announcement__c ,Award__c,ReportType__c,Grant__c from ProgressReports__c where id =:recordId ];
        grantId=progReport.Grant__c;
        awardId=progReport.Award__c;        
        if(appName=='StateAsGrantor' || appName=='Recipient'){
           bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Progress Report' and PackageConfig__r.GNT__CustomAppConfig__r.Name = 'StateAsGrantor' and Grant__c =:grantId];
        }else if(appName=='StateAsGrantee'){   // This logic will change, kept for now
           bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Progress Report' and PackageConfig__r.GNT__CustomAppConfig__r.Name =:appName and PackageConfig__r.GNT__CustomAppConfig__r.Name =:appName  and Grant__c =:grantId];
          }
     
        if(bizPkg!=null && bizPkg.size()>0) {
            packageId=bizPkg[0].PackageConfig__c;
        }

        system.debug('--packageId--'+packageId);
      //  if(progReport!=null ) {
            if(progReport.ReportType__c=='Desk Review') {
                pageTemplateName='DeskReviewForm';
                formTypes.add('Desk Review');
            } else if(progReport.ReportType__c=='Program'){
                pageTemplateName='Program Report Form';
                formTypes.add('Program');
            } else if(progReport.ReportType__c=='Progress'){
                pageTemplateName='ProgressReportTemplate';
                formTypes.add('Progress');
            }
     //   } else  
            pageTemplateName='ProgressReportTemplate';
        deleteURL = null; 
     }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('progressReportId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('awardId',awardId);
        return JSON.serialize(keyValueMap);
    }
}