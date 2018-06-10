global with sharing class PaymentRequestEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public ID grantId{get;set;}
    public Id awardId{get;set;}
    public String type{get;set;}
    public PageReference savePage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private String ns{get;set;}
    public String pageTemplateName {get;set;}
    public PageReference cancelPage {get;set;}
    public PaymentRequest__c payreq {get;set;}
    public String orgName{get;set;}
    public Id orgId{get;set;}
    public Date startDate{get;set;}
    public Date endDate{get;set;}
    public String year0{get;set;}
    public String year1{get;set;}
    public String year2{get;set;}
    public PaymentRequestEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        if(recordId!=null){
            payreq = [select id,Name,Award__c,Award__r.Grant__c,SpendType__c,Grant__r.InternalOrganization__r.Id,Grant__r.ExternalOrgName__c,BillingStartDate__c,BillingEndDate__c from PaymentRequest__c where id=:recordId];
            orgId = payreq.Grant__r.InternalOrganization__r.Id;
            orgName = payreq.Grant__r.ExternalOrgName__c;
            startDate = payreq.BillingStartDate__c;
            endDate = payreq.BillingEndDate__c;
        }
        type =    ApexPages.CurrentPage().getParameters().get('type');
        grantId = ApexPages.CurrentPage().getParameters().get('grantid');
        Award__c awd;
        User approver;
        //below line commented by YST sai
        
        if(payReq!=null){
            awardId =  payReq.Award__c;
        }else{
            awardId =  ApexPages.CurrentPage().getParameters().get('awardId');
        }
        if(awardId != null){
            awd =[select id,FOUser__c,SpendType__c,Grant__c,POUser__c,Grant__r.GranteePOC__c,Grant__r.GrantNumber__c,Grant__r.Program__r.PaymentRequestSetting__c,Grant__r.ProjectPeriodStartDate__c,Grant__r.ProjectPeriodEndDate__c,
                  Grant__r.InternalOrganization__r.Id,Grant__r.ExternalOrgName__c,GrantorOrganization__c from Award__c where id=:awardId];
            orgId = awd.Grant__r.InternalOrganization__r.Id;
            if(orgId!=null){
                approver = [SELECT Id FROM User WHERE Organization__c =: orgId AND IsKeyContact__c = true AND ProfileName__c = 'SPI' LIMIT 1];
            }
            
            if(awd.SpendType__c == 'Internal Spend' || awd.SpendType__c == 'ISA'){
            pageTemplateName='InternalSpendPaymentRequests';
            }
            else if (awd.GrantorOrganization__c == 'UOVC'){
                pageTemplateName='PaymentRequestUOVC';
            }
            else{
            pageTemplateName='PaymentRequestUSBE';
            }
         }
         else{
            pageTemplateName='PaymentRequestUSBE';
            if(payreq != null && (payreq.SpendType__c == 'Internal Spend' || payreq.SpendType__c == 'ISA')){
            pageTemplateName='InternalSpendPaymentRequests';
           }
         }
        
        ns=AppUtils.getNameSpacePrefix();
        savePage = Page.PaymentRequestView;
        savePage.getParameters().put('id', recordId); 
        if (!String.isEmpty(recordId)){
            cancelPage = Page.PaymentRequestView;
            cancelPage.getParameters().put('id', recordId);
        }
        
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,false);
        listDefaultValues.add(dv);
        if(type!=null && awardId != null){
         GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Type__c',type,true);
         listDefaultValues.add(dv2);
         GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'FiscalOfficer__c',awd.FOUser__c,true);
         listDefaultValues.add(dv3);
        }
        
        if (awardId != null){
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
            listDefaultValues.add(dv1);
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',awd.Grant__c,true);
            listDefaultValues.add(dv4);
            GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgramManager__c',awd.POUser__c,true);
            listDefaultValues.add(dv5);
            GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Applicant__c',awd.Grant__r.GranteePOC__c,true);
            listDefaultValues.add(dv6);
            GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'RecipientsAccountNumber__c',awd.Grant__r.GrantNumber__c,true);
            listDefaultValues.add(dv7);
            GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'PaymentRequestSetting__c',awd.Grant__r.Program__r.PaymentRequestSetting__c,true);
            listDefaultValues.add(dv8);
            /*GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'BillingStartDate__c',awd.Grant__r.ProjectPeriodStartDate__c,true);
            listDefaultValues.add(dv9);
            GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'BillingEndDate__c',awd.Grant__r.ProjectPeriodEndDate__c,true);
            listDefaultValues.add(dv10);*/
            GNT.DynamicLayoutDefaultValueHelper dv11 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ExternalOrgName__c',String.valueOf(awd.Grant__r.ExternalOrgName__c),true);
            listDefaultValues.add(dv11);
            if(approver!=null){
                GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Approver__c',approver.Id,true);
                listDefaultValues.add(dv12);
            }
            
            GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TermsAgreement__c','',true);
            listDefaultValues.add(dv13);
            orgName = awd.Grant__r.ExternalOrgName__c;
            startDate = awd.Grant__r.ProjectPeriodStartDate__c;
            endDate = awd.Grant__r.ProjectPeriodEndDate__c;
        }
        
        if (startDate != null && endDate != null && orgId != null){
            List<USBELEACostRate__c> availableFiscalYears = new List<USBELEACostRate__c>();
            List<USBELEACostRate__c> fiscalYears = [SELECT Id,Year__r.StartDate__c,Year__r.EndDate__c FROM USBELEACostRate__c WHERE Account__c =: orgId];
            for (USBELEACostRate__c fiscalYear : fiscalYears){
                if ((fiscalYear.Year__r.StartDate__c > startDate && fiscalYear.Year__r.StartDate__c < endDate) || (fiscalYear.Year__r.EndDate__c > startDate && fiscalYear.Year__r.StartDate__c < endDate)){
                    availableFiscalYears.add(fiscalYear);
                }
            }
            
            if (availableFiscalYears.size() > 0){
                year0 = availableFiscalYears[0].Id;
                if (availableFiscalYears.size() > 1){
                    year1 = availableFiscalYears[1].Id;
                } else{
                    year1 = year0;
                }
                if (availableFiscalYears.size() > 2){
                    year2 = availableFiscalYears[2].Id;
                } else{
                    year2 = year0;
                }
            }
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();  
        keyValueMap.put('grantid',ApexPages.currentPage().getParameters().get('grantid')); 
        keyValueMap.put('awardId',ApexPages.currentPage().getParameters().get('awardId'));
        keyValueMap.put('Id',ApexPages.currentPage().getParameters().get('id'));   
        keyValueMap.put('payId',ApexPages.currentPage().getParameters().get('id'));
        keyValueMap.put('orgId',orgId);
        keyValueMap.put('orgName',orgName);
        keyValueMap.put('year0',year0);
        keyValueMap.put('year1',year1);
        keyValueMap.put('year2',year2);
        return JSON.serialize(keyValueMap);
    }

    public PageReference redirect(){
            PaymentRequest__c payReq = [Select Status__c from PaymentRequest__c where id = : recordId];

            if(payReq.Status__c == 'Approved by Program Manager'){
                PageReference pageRef= new PageReference('/apex/'+ns+'PaymentRequestView?id='+recordId);
                pageRef.setRedirect(true);  
                return pageRef;
            }
            else{
                return null;
            }
    }
}