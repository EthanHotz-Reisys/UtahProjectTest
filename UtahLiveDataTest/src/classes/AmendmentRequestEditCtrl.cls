/*
    This class has methods to execute methods related to account trigger
    **********************************************************
    Audit History
    **********************************************************
    2014-08-08  Ryan Chadwick           create
    8/10/2015   William Moore           modified
    09/23/2015  Shrawan Raina           Modified --  Added error message for Closeout
    **********************************************************
*/


public with sharing class AmendmentRequestEditCtrl extends GNT.MasterCtrl {

    public ID recordId {get; set;}
    public PageReference savePage {get; set;}
    public PageReference cancelPage {get; set;}
    public String pageTemplateName {get; set;}
    public ID awardId {get; set;}
    public Id orgId{get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get; set;}
    String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');

    public AmendmentRequestEditCtrl(ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        AmendmentRequest__c amendmentRequest = null;
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        Id pageDataHolder = ApexPages.CurrentPage().getParameters().get('pageDataHolder');
        if (pageDataHolder != null) {
            amendmentRequest = (AmendmentRequest__c)AppUtils.getSObjectFromJSON(); 
        }
        else{
            List<AmendmentRequest__c> amendmentList = [Select Award__r.Grant__c,Award__r.Grant__r.InternalOrganization__r.Id, Award__c, GrantIntOrgName__c,RecordTypeId, Award__r.Grant__r.ExternalOrganization__r.Name,Impact__c,Purpose__c from AmendmentRequest__c where id=:recordId limit 1];
            
            if(amendmentList.size()>0){
                amendmentRequest=amendmentList[0];
                orgId = amendmentList[0].Award__r.Grant__r.InternalOrganization__r.Id;
            }
        }

        Map<Id, String> recordTypeMap = new Map<Id, String>();

        List<RecordType> amendmentRecordTypes = [select Id, Name, DeveloperName
                                                FROM RecordType
                                                where SobjectType = :AppUtils.getNamespacePrefix() + 'AmendmentRequest__c'];

        for (RecordType recordType : amendmentRecordTypes) {
            recordTypeMap.put(recordType.Id, recordType.DeveloperName);
        }
        system.debug('New Amendment Request -->' + amendmentRequest);
         GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('Award__c',amendmentRequest.Award__c,true);
         GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('Impact__c',amendmentRequest.Impact__c,true);
         GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper('Purpose__c',amendmentRequest.Purpose__c,true);
         listDefaultValues.add(dv1);
         listDefaultValues.add(dv2);
         listDefaultValues.add(dv3);


        system.debug('Sarat Page Data Holder' + pageDataHolder);
        //string requestType = ApexPages.CurrentPage().getParameters().get('type');
        system.debug('Record Type --> ' + recordTypeMap.get(amendmentRequest.RecordTypeId));
        string requestType = recordTypeMap.get(amendmentRequest.RecordTypeId);
        //string awardIdInUrl = ApexPages.CurrentPage().getParameters().get('awardId');
        string awardIdInUrl = amendmentRequest.Award__c;
        awardId=awardIdInUrl;
        System.debug('***Entered into my class');
        System.debug('***Award Id from URL' + awardIdInUrl);
        List<AmendmentRequest__c> amendmentrequestlist = new List<AmendmentRequest__c>();
        String recType = requestType;
        String spendType;
        
        /*if(recordId != null){
            amendmentrequestlist = [select id,name,Award__r.Grant__r.SpendType__c,
                                    RecordTypeId,recordtype.DeveloperName
                                    FROM AmendmentRequest__c
                                    WHERE id=:recordId];
            recType = amendmentrequestlist[0].recordtype.DeveloperName;
            spendType = amendmentrequestlist[0].Award__r.Grant__r.SpendType__c;
        }*/

        if (appName == 'StateAsGrantee') {
            if (recType == null) {
                pageTemplateName = 'New Amendment';
            }

            if (recType == 'FormalAmendments') {
                pageTemplateName = 'Formal Amendment';
            }

            if (recType == 'PriorApproval') {
                pageTemplateName = 'Amendment Prior Approval';
            }
        }

        if (appName == 'StateAsGrantor' || appName == 'Recipient') {
            /*if(recType == null ) {
                pageTemplateName = 'GrantorAmendmentRequest';
            }*/

            if (recType == 'FormalAmendments') {
                if (spendType == 'Sub Awards'|| spendType == null ) {
                    pageTemplateName = 'GrantorFormalAmendment';
                } else if (spendType == 'ISA') {
                    pageTemplateName = 'GrantorISTVFormalAmendment';
                } else if (spendType == 'Internal Spend') {
                    pageTemplateName = 'GrantorIntSpendFormalAmendment';
                } else if (spendType == 'Contracts') {
                    pageTemplateName = 'GrantorContractsFormalAmendment';
                }
            }

            if (recType == 'PriorApproval') {
                pageTemplateName = 'GrantorPriorApproval';
            }

            if (recType == 'PeriodicAnnualRenewal') {
                pageTemplateName = 'GrantorPeriodicRenewal';
            }

            if (recType == 'BudgetRevision') {
                pageTemplateName = 'GrantorBudgetRevisionAmendment';
            }
        }

        system.debug('*** Record Type : ' + recType + ' - spendType - ' + spendType);
        system.debug('*** record id ' + recordId);
        system.debug('*** Page Template name : ' + pageTemplateName);

        Id awardId;
        Id grantId;

       /* if (recordId != null) {
            cancelPage = Page.AmendmentRequestView;
            cancelPage.getParameters().put('id', recordId);
        }
        if (ApexPages.currentPage().getParameters().containsKey('awardId')) {
            awardId = ApexPages.CurrentPage().getParameters().get('awardId');
            if (cancelPage == null) {
                cancelPage = Page.AwardView;
                cancelPage.getParameters().put('id', awardId);
            }
        } else if (ApexPages.currentPage().getParameters().containsKey('grantId')) {
            grantId = ApexPages.currentPage().getParameters().get('grantId');
            List<Award__c> awardList = [SELECT Id, Grant__c FROM Award__c WHERE Status__c = 'Issued' AND Grant__c = : grantId ORDER BY CreatedDate DESC LIMIT 1];
            if (awardList.size() > 0) {
                awardId = awardList[0].Id;
                grantId = awardList[0].Grant__c;
            }
            if (cancelPage == null) {
                cancelPage = Page.GrantView;
                cancelPage.getParameters().put('id', grantId);
            }
        }*/

       /* savePage = Page.AmendmentRequestView;
        savePage.getParameters().put('id', recordId);
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();*/
        /*if (recordId == null) {
            if (!String.isEmpty(requestType)) {
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix() + 'Type__c', requestType, true);
                listDefaultValues.add(dv);
            }
            System.debug('awardId------------------->' + awardId);
            if(awardId != null){
                    GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
                    listDefaultValues.add(dv);
                } else if (grantId != null) {
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The selected grant has no issued awards on which to place a change request.  Please return to the previous screen.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTE-50016')));
            }/*else{
                       System.debug('awardId------------------->flag1');
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No grant or award to issue this amendment request on has been detected.  Please return to the previous screen.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTE-36277')));
                    System.debug('awardId------------------->flag2');
                }
            }
            if(grantId != null){
                List<Closeout__c> closeout = [SELECT Id, Grant__c, Grant__r.isClosedOut__c FROM Closeout__c WHERE grant__c =: grantId AND Status__c IN ('Initiated By PM', 'Approved By PM', 'Under PM Review') LIMIT 1];
                if(closeout != null && closeOut.size() >0 && closeout[0].Grant__r.isClosedOut__c != null && closeout[0].Grant__r.isClosedOut__c){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The selected Grant has been Closed Out. Please return to the previous screen.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTE-16772')));
                }
                else if(closeout.size () > 0){
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Closeout is in process for the Grant. Please return to the previous screen.'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,GNT.ErrorMessageHelper.fetchMessage('M01-GRNTE-33319')));
                }
            }
        }*/
    }

        public string getKeyValueMap() {
            Map<String, String> keyValueMap = new Map<String, String>();
            System.debug('RecordId:-- ' + recordId);
            if (recordId != null) {
                Id tmp = ID.valueOf(recordId);
                System.debug(tmp.getSobjectType().getDescribe().getName());
                keyValueMap.put('amendmentId', recordId);
                AmendmentRequest__c ar = [SELECT Award__r.Grant__c, Award__c, GrantIntOrgName__c, Award__r.Grant__r.ExternalOrganization__r.Name
                                          FROM AmendmentRequest__c
                                          WHERE Id = : recordId];
                keyValueMap.put('grantId', ar.Award__r.Grant__c);
                keyValueMap.put('awardId', ar.Award__c);
                keyValueMap.put('orgId', orgId);
                keyValueMap.put('orgName', ar.GrantIntOrgName__c);
                keyValueMap.put('grantorOrgName', ar.Award__r.Grant__r.ExternalOrganization__r.Name);                
            }
            else{
                keyValueMap.put('awardId', awardId);
                System.debug('awardId:-- ' + awardId);
            }
            return JSON.serialize(keyValueMap);
        }
    }