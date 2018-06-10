/**
* View page controller for the Award__c object
*
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/13/2014    Ryan Chadwick   Created
* 08/19/2015    Shrawan Raina   Edited Added keyValueMap for Communication FlexTable
* =============================================================================
*/

public with sharing class AwardViewCtrl {

    //Properties
    public ID recordId {get; set;}
    public PageReference deleteURL {get; set;}
    public String pageTemplateName {get; set;}
    public Award__c award {get; set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get; set;}
    private Application__c applicationObj;
    public String paymentTermConditionId = '';
    public String progressTermConditionId = '';
    public String siteTermConditionId = '';
    public String organizationName = '';
    private String programId;
    private String announcementId;
    public String packageId {get; set;}
    public String formtemplate {get; set;}
    public String pathway {get; set;}

    public AwardViewCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        deleteURL = null;
        award = [SELECT SubAwardee__c, Id, Application__c, Grant__r.Program__r.fundertype__c, Application__r.Announcement__c, Grant__c, Grant__r.SpendType__c,
                 PurchaseOrderNumber__c, Grant__r.Program__c, PurchaseOrderNumber2__c, Grant__r.Program__r.ProgramPathway__c,
                 Application__r.ExternalOrganization__r.Name, Grant__r.ExternalOrganization__r.Name
                 FROM Award__c
                 WHERE id = :recordId];
        if (recordId != null) {
            List<TermCondition__c> tcList = [select id, SubmissionType__c, Award__c FROM TermCondition__c where Award__c = : recordId];
            if (tcList.size() > 0) {
                for (Integer i = 0 ; i < tcList.size(); i++) {
                    if (tcList[i].SubmissionType__c == 'Payment Request') {
                        paymentTermConditionId = tcList[i].Id;
                        system.debug(LoggingLevel.INFO, 'paymentTermConditionId: ' + paymentTermConditionId);
                    }
                    if (tcList[i].SubmissionType__c == 'Progress Report') {
                        progressTermConditionId = tcList[i].Id;
                    }
                    if (tcList[i].SubmissionType__c == 'Site Visit') {
                        siteTermConditionId = tcList[i].Id;
                    }
                }
            }
        }

        Id applicationId = ApexPages.currentPage().getParameters().get('applicationId');
        if ( applicationId != null ) {
            applicationObj = [SELECT Id, Announcement__r.Program__c, Announcement__c, ExternalOrganization__r.Name
                              FROM Application__c WHERE id = :applicationId];
            announcementId = applicationObj.Announcement__c;
            organizationName = applicationObj.ExternalOrganization__r.Name;
            deleteURL = Page.ApplicationView;
            deleteURL.getParameters().put('id', applicationObj.Id);
        } else {

            programId = award.Grant__r.Program__c;
            organizationName = award.application__r.ExternalOrganization__r.Name;
            announcementId = award.application__r.Announcement__c;
            if (award.Application__c != null) {
                deleteURL = Page.ApplicationView;
                deleteURL.getParameters().put('id', award.Application__c);
            }
        }

        System.debug('award ID should be _________________' + ApexPages.currentPage().getParameters().get('id'));

        /*if(award.Application__c != null){
            System.debug(award.Application__c);
            try {
            applicationObj = [SELECT Id, Announcement__r.Program__c
                            FROM Application__c WHERE id=:award.Application__c];
            } catch(Exception e) {
            }
        }*/

        if (announcementId != null ) {
            List<BusinessPackage__c> progRptList = [Select Id, Name, PackageConfig__c from BusinessPackage__c where PackageType__c = 'Award' and FundingOpportunity__c = :announcementId ];
            if (progRptList.size() > 0 ) {
                packageId = progRptList[0].PackageConfig__c;
            }
        }

        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');

        String programPathWay = award.Grant__r.Program__r.ProgramPathway__c;

        if (programPathWay == 'MSP' || programPathWay == 'LSNA') {
            system.debug('InsideMSPCondition');
            pageTemplateName = 'MSPAwardViewFull';
        } else if (programPathWay == 'Application 1/12th' || programPathWay == 'Fed-Formula' || programPathWay == 'Fed-Competitive' || programPathWay == 'State-Competitive' || programPathWay == 'Lump-Sum-App' || award.Grant__r.ExternalOrganization__r.Name == 'USBE') {
            pageTemplateName = 'USBEAwards';
        } else {
            if (award.Grant__r.SpendType__c == 'Sub Awards' && (appName == 'StateasGrantor' || appName == 'Recipient')) {
                pageTemplateName = 'Awards';
            }
            if (award.Grant__r.SpendType__c == 'Internal Spend' && (appName == 'StateasGrantor' || appName == 'Recipient')) {
                pageTemplateName = 'InternalSpendAwards';
            }
            if (award.Grant__r.SpendType__c == 'ISA' && (appName == 'StateasGrantor' || appName == 'Recipient')) {
                pageTemplateName = 'ISAAwards';
            }
            if (award.Grant__r.SpendType__c == 'Contracts' && (appName == 'StateasGrantor' || appName == 'Recipient')) {
                pageTemplateName = 'ContractAward';
            }

            if (appName != null && appName == 'StateasGrantee') {
                pageTemplateName = 'GranteeAwards';
            }
        }
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Application__c', applicationId, true);
        listDefaultValues.add(dv);

        String fundertype = award.Grant__r.Program__r.fundertype__c;
        if (award.Grant__r.Program__r.fundertype__c != null) {
            if (fundertype.equalsIgnoreCase('State'))
                formTemplate = 'USBE Award Letter State Form';
            if (fundertype.equalsIgnoreCase('Federal'))
                formTemplate = 'USBE Award Letter Federal Form';
        }

        System.debug('InsideMSPCondition:' + pageTemplateName);

        pathway = award.Grant__r.Program__r.ProgramPathway__c;
       /* if (pathway != null) {
            if (pathway.containsIgnoreCase('fed'))
                formTemplate = 'USBE Award Letter Federal Form';
            if (pathway.containsIgnoreCase('state'))
                formTemplate = 'USBE Award Letter State Form';
        } */

System.debug('award ID should be _________________' + ApexPages.currentPage().getParameters().get('id'));

    }

    public string getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        System.debug('award ID should be _________________' + ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('awardId', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('parentid', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('grantId', award.Grant__c);
        //keyValueMap.put('parentOwnerId',award.SubAwardee__c);
        keyValueMap.put('announcementId', announcementId);
        keyValueMap.put('paymentTermConditionId', paymentTermConditionId);
        keyValueMap.put('progressTermConditionId', progressTermConditionId);
        keyValueMap.put('siteTermConditionId', siteTermConditionId);
        keyValueMap.put('organizationName', organizationName);
        keyValueMap.put('programId', programId);
        keyValueMap.put('formTemplate', formTemplate);
        return JSON.serialize(keyValueMap);
    }
}