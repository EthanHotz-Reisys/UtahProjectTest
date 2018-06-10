/**
* Edit page controller for the ProgressReport__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 09/4/2015    Davinder Singh   Created
* =============================================================================
*/

public with sharing class ProgressReportEditCtrl {

    //properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String packageId {get;set;}
    public String pageTemplateName {get;set;}
    private List<BusinessPackage__c> bizPkg;
    public List<string> formTypes {get;set;}
    private String grantId, awardId;
    //public ID orgId {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
   
    
    public ProgressReportEditCtrl(ApexPages.StandardController stdController){
        formTypes = new List<string>();
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        
                 
        List<ProgressReports__c> progRptList = [Select Id, Name, ReportType__c,Award__r.Grant__c, Award__c from ProgressReports__c where id= :recordId limit 1];
        awardId = progRptList[0].Award__c;
        grantId=progRptList[0].Award__r.Grant__c;
        //orgId = progRptList[0].Grant__r.InternalOrganization__r.Id;
        system.debug('proglist is '+progRptList[0].ReportType__c);

        if(appName=='StateAsGrantor' || appName=='Recipient'){
            bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Progress Report' and PackageConfig__r.GNT__CustomAppConfig__r.Name = 'StateAsGrantor' and Grant__c =:grantId];
        }
        else if(appName=='StateAsGrantee'){   // This logic will change, kept for now
            bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Progress Report' and PackageConfig__r.GNT__CustomAppConfig__r.Name =:appName and PackageConfig__r.GNT__CustomAppConfig__r.Name =:appName  and Grant__c =:grantId];
        }

        if(bizPkg!=null && bizPkg.size()>0) {
            packageId=bizPkg[0].PackageConfig__c;
        }

        if(progRptList!=null && progRptList.size()>0 )
        {
          if(progRptList[0].ReportType__c=='Desk Review'){
             pageTemplateName='ProgressReportTemplate';
             formTypes.add('Desk Review');
            }
            else if(progRptList[0].ReportType__c=='Program'){
                pageTemplateName='ProgramProgressReportTemplate';
                formTypes.add('Program');
            }
        } else if(progRptList[0].ReportType__c=='Progress'){
            pageTemplateName='ProgramProgressReportTemplate';
            formTypes.add('Progress');
        }
        pageTemplateName='ProgressReportTemplate';
        //system.debug('formtype is '+formTypes[0]);    


           
                    
        savePage = Page.ProgressReportView;
        savePage.getParameters().put('id', recordId);
        if(recordId != null){
            cancelPage = Page.ProgressReportView;
            cancelPage.getParameters().put('id', recordId);
            
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if(recordId != null){
            keyValueMap.put('progressReportId',recordId);
            keyValueMap.put('awardId',awardId);
        }
        return JSON.serialize(keyValueMap);
    }
}