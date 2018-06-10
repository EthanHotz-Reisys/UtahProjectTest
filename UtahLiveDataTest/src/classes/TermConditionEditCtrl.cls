/*
    This class executes methods for Create new / Edit term & condition
    **********************************************************
    Audit History
    **********************************************************
    2014-05-19   Nakul Kadam       Created
  
    **********************************************************  
*/
public with sharing class TermConditionEditCtrl{

    public ID recordId {get;set;}
    public ID announcementId {get;set;}
    public ID grantId {get;set;}
    public ID awardId {get;set;}
    public String recordType {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public Boolean isProgram{get;set;}
    public transient List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public String templateName{get;set;}
    private Award__c award;
     
    public TermConditionEditCtrl(ApexPages.StandardController stdController) {
        isProgram = false;
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        announcementId = ApexPages.CurrentPage().getParameters().get('announcementId');
        grantId = ApexPages.CurrentPage().getParameters().get('grantId');  
        awardId= ApexPages.CurrentPage().getParameters().get('awardId');         
        TermCondition__c termCondtion = (TermCondition__c)stdController.getRecord();
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        templateName = '';
        String siteVisitPackageId = '';
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if(awardId != null) {
             award = [select id,SiteVisitPackage__c, BudgetPeriod__r.BudgetStartDate__c,BudgetPeriod__r.BudgetEndDate__c
                                from Award__c 
                                where id =: awardId limit 1];
            siteVisitPackageId = award.SiteVisitPackage__c;
            system.debug('siteVisitPackageId: '+siteVisitPackageId);
        }
        
        if(ApexPages.CurrentPage().getParameters().get('isProgram') != null){
            isProgram = Boolean.valueOf(ApexPages.CurrentPage().getParameters().get('isProgram'));  
        }else{
            if(stdController.getId() != null){
                termCondtion = [Select Id, type__c, RecordTypeId From TermCondition__c Where Id = :stdController.getId()];
                if(termCondtion.type__c != null && termCondtion.type__c == 'Program'){
                    isProgram = true;
                }
            }
        }

        if(stdController.getId() != null){ 
       // Edit existing
            recordType =  Schema.SObjectType.TermCondition__c.getRecordTypeInfosById().get(termCondtion.RecordTypeId).getName().toLowercase();
             system.debug('REC TYPE: '+recordType);
            if(recordType == 'Payment Request' || recordType == 'paymentrequest' || recordType == 'payment request' || recordType == 'PaymentRequest') {}
            
            cancelPage = Page.TermConditionView;
            cancelPage.getParameters().put('id', recordId);
        }else{    // create New
            recordType = ApexPages.CurrentPage().getParameters().get('recordType').toLowercase();
              system.debug('REC TYPE: '+recordType);
            if(recordType != null && recordType.toLowerCase() == 'term'){
                termCondtion.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Term').getRecordTypeId();
            }else if(recordType != null && recordType.toLowerCase() == 'condition'){
                termCondtion.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Condition').getRecordTypeId();
            }else if(recordType != null && (recordType == 'reporting requirement'  || recordType == 'Reporting Requirement')){
                termCondtion.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Reporting Requirement').getRecordTypeId();
                if (award != null){
	                GNT.DynamicLayoutDefaultValueHelper dv120 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CalReportingStartDate__c',award.BudgetPeriod__r.BudgetStartDate__c,true);
	                GNT.DynamicLayoutDefaultValueHelper dv121 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CalReportingEndDate__c',award.BudgetPeriod__r.BudgetEndDate__c,true);
	                listDefaultValues.add(dv120);
	                listDefaultValues.add(dv121);
                }
              
            }else if(recordType != null && (recordType == 'paymentrequest' || recordType == 'payment request')){
                termCondtion.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Payment Request').getRecordTypeId();
                if (award != null){
	                GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper('CalReportingStartDate__c',award.BudgetPeriod__r.BudgetStartDate__c,true);
	                GNT.DynamicLayoutDefaultValueHelper dv11 = new GNT.DynamicLayoutDefaultValueHelper('CalReportingEndDate__c',award.BudgetPeriod__r.BudgetEndDate__c,true);
	                listDefaultValues.add(dv10);
	                listDefaultValues.add(dv11);
                }
            }else if(recordType != null && (recordType == 'progressreport' || recordType == 'progress report')){
                termCondtion.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Progress Report').getRecordTypeId();
            }else if(recordType != null && (recordType == 'sitevisit' || recordType == 'site visit')){
                termCondtion.RecordTypeId = Schema.SObjectType.TermCondition__c.getRecordTypeInfosByName().get('Site Visit').getRecordTypeId();
                if (award != null){
	                GNT.DynamicLayoutDefaultValueHelper dv130 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SiteVisitDateTime__c',award.BudgetPeriod__r.BudgetStartDate__c + 1,true);
	                GNT.DynamicLayoutDefaultValueHelper dv131 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'VisitEndDateTime__c',award.BudgetPeriod__r.BudgetEndDate__c + 1,true);
	                listDefaultValues.add(dv130);
	                listDefaultValues.add(dv131);
                }
            }
            
            
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('RecordTypeId',termCondtion.RecordTypeId,true);
            listDefaultValues.add(dv);
            GNT.DynamicLayoutDefaultValueHelper dv99 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SubmissionPackage__c',siteVisitPackageId,true);
            listDefaultValues.add(dv99);
            Id grantId =  ApexPages.CurrentPage().getParameters().get('grantId');
            if (announcementId != null){                
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Announcement__c',announcementId,true);
                listDefaultValues.add(dv2);
            }
            if (grantId != null){                
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
                listDefaultValues.add(dv2);
            }
            Id awardId =  ApexPages.CurrentPage().getParameters().get('awardId');
            if (awardId != null){                
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Award__c',awardId,true);
                listDefaultValues.add(dv2);                
                String isNew = ApexPages.CurrentPage().getParameters().get('isNew');
                if(isNew!=null && isNew == 'true')
                {
             
                Integer sequence;
                List<TermCondition__c> tcList = [Select Id, Name from TermCondition__c where Award__c=: awardId];
                    if(tcList!=null)
                    {
                        sequence=tcList.size()+1;
                    }
                    else
                    {
                        sequence=0;
                    }
                GNT.DynamicLayoutDefaultValueHelper dv21 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SequenceNo__c',sequence,true);
                listDefaultValues.add(dv21);
                }

                 GNT.DynamicLayoutDefaultValueHelper dv107 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Source__c','Award',false);
                listDefaultValues.add(dv107);     
            GNT.DynamicLayoutDefaultValueHelper dv108 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AutoAddToAward__c',true,false);
                listDefaultValues.add(dv108);  
              
            }
            Id programId =  ApexPages.CurrentPage().getParameters().get('programId');
            if (programId != null){                
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Program__c',programId,true);
                               
                listDefaultValues.add(dv2);

                 String isNew = ApexPages.CurrentPage().getParameters().get('isNew');
                if(isNew!=null && isNew == 'true')
                {
              
                Integer sequence;
                List<TermCondition__c> tcList = [Select Id, Name from TermCondition__c where Program__c=: programId];
                    if(tcList!=null)
                    {
                        sequence=tcList.size()+1;
                    }
                    else
                    {
                        sequence=0;
                    }
                GNT.DynamicLayoutDefaultValueHelper dv31 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'SequenceNo__c',sequence,true);
                listDefaultValues.add(dv31);
                }

                 GNT.DynamicLayoutDefaultValueHelper dv104 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Source__c','Program',false);
                listDefaultValues.add(dv104);     
            GNT.DynamicLayoutDefaultValueHelper dv105 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AutoAddToAward__c',true,false);
                listDefaultValues.add(dv105);  
              
            }

            if(isProgram){
                GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Type__c','Program',true);                
                listDefaultValues.add(dv4);
            }else{
                GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Type__c','State',true);                
                listDefaultValues.add(dv4);
            }

            List<Grant__c> grantList = new List<Grant__c>();
            grantList = [Select Id,GranteePOC__c from Grant__c where id = :grantId];
            if(grantList != null && grantList.size() > 0){
                GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GranteePOC__c',grantList[0].GranteePOC__c,false);
                listDefaultValues.add(dv2);
            }
            if(appName != null && appName != 'StateAsGrantee'){
            cancelPage = Page.GNT__FlexTableView;
            cancelPage.getParameters().put('flexTableName', 'TermConditionState');
            } else {
                cancelPage = Page.AwardView;
                cancelPage.getParameters().put('id', awardId);

            }
        }
        
        if(recordType.toLowerCase() == 'term'){
           
            String termType=ApexPages.CurrentPage().getParameters().get('termType');
            if(termType=='Master')
            {
            templateName = 'Grantor Master Terms and Conditions';
            GNT.DynamicLayoutDefaultValueHelper dv102 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Source__c','Standard',false);
                listDefaultValues.add(dv102);
            }
            else
            {
            templateName = 'Grantor Terms and Conditions';   
            
            }
            
        }else if(recordType == 'reporting requirement'){
            templateName = 'Grantee Reporting Requirements';
        }
        else if(recordType == 'site visit' && appName != null && appName == 'StateAsGrantee'){
            templateName = 'Grantee Site Visits';
        }
        else if(recordType == 'site visit' && appName != null && appName == 'StateAsGrantor'){
            templateName = 'Grantor Site Visits';
        }
        else if((recordType == 'condition' || recordType == 'reporting requirement') && isProgram == false && appName != null && appName != 'StateAsGrantee'){
            templateName = 'ConditionsTemplate';
        }else if((recordType == 'condition' || recordType == 'reporting requirement') && isProgram == true && appName != null && appName != 'StateAsGrantee'){
            templateName = 'ProgramsConditionsTemplate';
        }else if((recordType == 'paymentrequest' || recordType == 'payment request' || recordType == 'PaymentRequest') && isProgram == false){
            templateName = 'ProgramsPaymentRequestsTemplate';
        }else if((recordType.contains('payment') || recordType.contains('progress') || recordType.contains('site')) && isProgram == false){
            templateName = 'ProgramsPaymentRequestsTemplate';
            }
        system.debug('TEMPl Name: '+templateName);
        
         system.debug('recordType : '+recordType );
        
        savePage = Page.TermConditionView;
        
        savePage.getParameters().put('id', recordId);
        savePage.getParameters().put('grantId', grantId);
        
        
    }
}