public with sharing class PaymentRequestViewCtrl {

    //Properties
    public ID recordId {get; set;}
    public String pageTemplateName {get; set;}
    public PageReference deleteURL {get; set;}
    public String downloadAsPdf {get; set;}
    public String packageId {get; set;}
    public PaymentRequest__c payreq {get; set;}

    public PaymentRequestViewCtrl (ApexPages.StandardController stdController) {
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        payreq = [select id, Name, Award__c, Award__r.Grant__c, SpendType__c, USBEPathway__c, Grant__r.Program__c, OrganizationName__c from PaymentRequest__c where id = :recordId];
        if (payreq.USBEPathway__c == 'MSP' || payreq.USBEPathway__c == 'App12' ) {
            pageTemplateName = 'MSPPaymentRequestView';
        }

        else if(payreq.USBEPathway__c == 'Lump-Sum-App' || payreq.USBEPathway__c == 'Lump-Sum-No-App'){
            pageTemplateName = 'PaymentRequestLSA';
        }

        else {
            Grant__c grantObj = [SELECT Id, (select PackageConfig__r.Name from Business_Packages__r where PackageType__c = 'Payment Request') FROM Grant__c WHERE id = :payreq.Award__r.Grant__c LIMIT 1];
            system.debug('grantObj------>>>>' + grantObj);



            Id awardId =  ApexPages.CurrentPage().getParameters().get('awardId');
            system.debug('award id------>>>>' + ApexPages.CurrentPage().getParameters().get('awardId'));
            if (payreq.SpendType__c == 'Internal Spend' || payreq.SpendType__c == 'ISA') {
                pageTemplateName = 'InternalSpendPaymentRequests';
            } else if (payreq.OrganizationName__c == 'UOVC') {
                pageTemplateName = 'PaymentRequestUOVC';
            } else {
                //packageId = grantObj.Business_Packages__r[0].PackageConfig__c;
                pageTemplateName = 'PaymentRequestUSBE';
            }
            downloadAsPdf = '/apex/GDP__DynamicLayoutExport?id='
                            + recordId +
                            '&viewTemplateName=PaymentRequest&flexTableParam={payId:'
                            + recordId +
                            ',Id:'
                            + recordId +
                            '}&listParm=';

            deleteURL = null;
        }
    }

    public string getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        System.debug('Award Id is here ' + payreq.Award__c);
        keyValueMap.put('Id', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('awardId', payreq.Award__c);
        keyValueMap.put('payId', ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('programId', payreq.Grant__r.Program__c);
        //keyValueMap.put('downloadAsPdf',downloadAsPdf);
        return JSON.serialize(keyValueMap);
    }
    public string getListParams() {
        Map<String, List<String>> listParams = new Map<String, List<String>>();

        return JSON.serialize(listParams);
    }

}