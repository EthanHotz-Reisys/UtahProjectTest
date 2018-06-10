public with sharing class SiteVisitEditCtrl {


    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}    
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public string pageTemplate {get;set;}
    public String packageId {get;set;}
    public String grantId;
    
    public SiteVisitEditCtrl (ApexPages.StandardController controller) {
        System.debug('Entered into SiteVisitEditCtrl');
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        System.debug('appName===>>'+appName);
        if(recordId != null){
            SystemContextMethodsHelper sys = new SystemContextMethodsHelper();
            SiteVisit__c siteVisit = sys.getSV(recordId);
            //SiteVisit__c siteVisit  = [select id,Grant__c,TermConditionSchedule__r.TermAndCondition__r.SubmissionPackage__r.GNT__PageTemplateConfig__r.Name 
            //                            from SiteVisit__c 
            //                            where id =: recordId limit 1];
            //                            system.debug('siteVisit: ' + siteVisit);
            //pageTemplate = siteVisit.TermConditionSchedule__r.TermAndCondition__r.SubmissionPackage__r.GNT__PageTemplateConfig__r.Name;
            grantId = siteVisit.Grant__c;
            List<BusinessPackage__c> bizPkg = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Site Visit' and PackageConfig__r.GNT__CustomAppConfig__r.Name =: appName and Grant__c =:grantId];
            if(bizPkg!=null && bizPkg.size()>0) {
                packageId=bizPkg[0].PackageConfig__c;
            }

            pageTemplate='SiteVisit';
            system.debug('pg: '+siteVisit.TermConditionSchedule__r.TermAndCondition__c);
            system.debug('pg: '+siteVisit.TermConditionSchedule__c);
            system.debug('pg: '+siteVisit.TermConditionSchedule__r.TermAndCondition__r.SubmissionPackage__c);
            system.debug('pg: '+siteVisit.TermConditionSchedule__r.TermAndCondition__r.SubmissionPackage__r.GNT__PageTemplateConfig__c);
            /*if(String.isEmpty(pageTemplate)){
                pageTemplate  = 'SiteVisitReportTemplate';
            }*/ 
            savePage = Page.SiteVisitView;
            savePage.getParameters().put('id',recordId);
            Id siteVisitScheduleId = ApexPages.CurrentPage().getParameters().get('siteVisitScheduleId');
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            if (siteVisitScheduleId != null){
                //DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SiteVisitSchedule__c',siteVisitScheduleId,true);
                //listDefaultValues.add(dv);
            }
        }else{
            String awardId = ApexPages.CurrentPage().getParameters().get('awardId');
            Award__c award = [SELECT Id, Grant__c, Grant__r.GranteePOC__r.Email, POUser__c, createdById, Grant__r.GranteePOC__c, GrantAdministrator__c FROM Award__c WHERE Id = :awardId];
            List<BusinessPackage__c> bizPkg = new List<BusinessPackage__c>([SELECT Id, Name, PackageConfig__c FROM BusinessPackage__c WHERE PackageType__c = 'Site Visit' AND PackageConfig__r.GNT__CustomAppConfig__r.Name = :appName and Grant__c = :award.Grant__c LIMIT 1]);
            if(bizPkg.size() != 0) {
                packageId=bizPkg[0].PackageConfig__c;
            }
            pageTemplate='SiteVisit';
            RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType='SiteVisit__c' AND DeveloperName ='Grantor' LIMIT 1];
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Award__c', award.Id, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Grant__c', award.Grant__c, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Frequency__c', 'Fixed', true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Status__c', 'Created', true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'RecordTypeId', rt.Id, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'ReportingFrequency__c', 'Fixed', true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'ApplicantEmail__c', award.Grant__r.GranteePOC__r.Email, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'ProgramApprover__c', award.POUser__c, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'ProjectManager__c', award.createdById, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'OwnerId', award.Grant__r.GranteePOC__c, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'GrantAdministrator__c', award.GrantAdministrator__c, true));
            listDefaultValues.add(new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Subawardee__c', award.Grant__r.GranteePOC__c, true));
            cancelPage = Page.PhaseView;
            cancelPage.getParameters().put('t','Monitoring');         
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('siteVisitId',ApexPages.CurrentPage().getParameters().get('id')); 
        return JSON.serialize(keyValueMap);
    }
}