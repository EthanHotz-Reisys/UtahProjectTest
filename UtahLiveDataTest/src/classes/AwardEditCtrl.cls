/**
* Edit page controller for the Award__c object
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 05/13/2014    Ryan Chadwick   Created
* =============================================================================
*/

public with sharing class AwardEditCtrl {

    //properties
    public ID recordId{get;set;}
    public String packageId{get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public Award__c award {get;set;}
    public Grant__c grantObj {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    private Application__c applicationObj;
    private Id grantId;
    private Id budgetGrantId;
    private Id applicationId; 
    public Id orgId{get;set;}
    public Id programId{get;set;}
    Award__c awd;
    public AwardEditCtrl(ApexPages.StandardController stdController){
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c'); 
        recordId = ApexPages.CurrentPage().getParameters().get('id');
        Id BudgetPeriodid = ApexPages.currentPage().getParameters().get('BudgetPeriodid');
        if(recordId!=null){ 
         awd = [select id,name,Grant__c, Grant__r.InternalOrganization__c,Grant__r.InternalOrganization__r.Id, Grant__r.SpendType__c, Grant__r.Program__c, Grant__r.Program__r.ProgramPathway__c, Grant__r.Program__r.OrganizationName__c from Award__c where id=:recordId]; 
         budgetGrantId = awd.Grant__c;
         orgId = awd.Grant__r.InternalOrganization__r.Id;
         String programPathWay = awd.Grant__r.Program__r.ProgramPathway__c;
        if(programPathWay == 'Application 1/12th' || programPathWay == 'Fed-Formula' || programPathWay == 'Fed-Competitive' || programPathWay == 'State-Competitive' || programPathWay == 'Lump-Sum-App' || awd.Grant__r.Program__r.OrganizationName__c == 'USBE'){
            pageTemplateName = 'USBEAwards';
        }else{
             if(awd.Grant__r.SpendType__c == 'Sub Awards' && appName == 'StateasGrantor'){     
                pageTemplateName = 'Awards';
                }
                if(awd.Grant__r.SpendType__c == 'Internal Spend' && appName == 'StateasGrantor'){     
                pageTemplateName = 'InternalSpendAwards';
                }
                if(awd.Grant__r.SpendType__c == 'ISA' && appName == 'StateasGrantor'){     
                pageTemplateName = 'ISAAwards';
                }
                if(awd.Grant__r.SpendType__c == 'Contracts' && appName == 'StateasGrantor'){     
                pageTemplateName = 'ContractAward';
                }
            }
        }   
        Id applicationId = ApexPages.currentPage().getParameters().get('applicationId');
        grantId = ApexPages.currentPage().getParameters().get('grantId');
        if(grantId != null){

        grantObj = [SELECT ID,Application__r.Announcement__c,ProjectTitle__c,IssueDate__c,SpendType__c,Program__c,Program__r.PointOfContact__c,
                        InternalOrganization__c, InternalOrganization__r.BillingStreet,InternalOrganization__r.BillingCity, Program__r.ProgramPathway__c,
                        InternalOrganization__r.BillingState,InternalOrganization__r.BillingPostalCode,InternalOrganization__r.BillingCountry, Program__r.OrganizationName__c
                        FROM Grant__c WHERE ID = : grantId];
        }
        if(grantId != null){            
            String programPathWay = grantObj.Program__r.ProgramPathway__c;
            if(programPathWay == 'Application 1/12th' || programPathWay == 'Fed-Formula' || programPathWay == 'Fed-Competitive' || programPathWay == 'State-Competitive' || programPathWay == 'Lump-Sum-App' || grantObj.Program__r.OrganizationName__c == 'USBE'){
                pageTemplateName = 'USBEAwards';
            }else{
                if(grantObj.SpendType__c == 'Sub Awards' && appName == 'StateasGrantor'){     
                pageTemplateName = 'Awards';
                }
                if(grantObj.SpendType__c == 'Internal Spend' && appName == 'StateasGrantor'){     
                pageTemplateName = 'InternalSpendAwards';
                }
                if(grantObj.SpendType__c == 'ISA' && appName == 'StateasGrantor'){     
                pageTemplateName = 'ISAAwards';
                }
                if(grantObj.SpendType__c == 'Contracts' && appName == 'StateasGrantor'){     
                pageTemplateName = 'ContractAward';
                }
            }
         }
          
        savePage = Page.AwardView;
        System.debug('>>>>>>>>>>>>>>>><<<<<<<<<'+savePage);
        savePage.getParameters().put('id', recordId);
        if(recordId != null){
            cancelPage = Page.AwardView;
            cancelPage.getParameters().put('id', recordId);
        }
        
        String announcementId = null;
        if(applicationId != null){
            applicationObj = [SELECT Id, Announcement__c,Title__c,CFDANumber__c,
                           ProjectAbstract__c,RequestedAmount__c FROM Application__c WHERE id=:applicationId];
               announcementId = applicationObj.Announcement__c;
        } else if( grantId != null && appName == 'StateasGrantor'){     
            
                announcementId = grantObj.Application__r.Announcement__c;
                
        } else
            
            
            if(appName != null && appName == 'StateasGrantee'){
                if(grantId!= null){
                        grantObj = [SELECT ID,Application__r.Announcement__c,InternalOrganization__r.BillingStreet,InternalOrganization__r.BillingCity,
                                     InternalOrganization__r.BillingState,InternalOrganization__r.BillingPostalCode,InternalOrganization__r.BillingCountry,ProjectTitle__c,
                                     IssueDate__c,Program__c,Program__r.PointOfContact__c
                                    FROM Grant__c WHERE ID = : grantId];
                        announcementId = grantObj.Application__r.Announcement__c;
                }
              pageTemplateName = 'GranteeAwards';
            }
        
        
        if( announcementId != null ) {
            List<BusinessPackage__c> progRptList = [Select Id,Name,PackageConfig__c from BusinessPackage__c where PackageType__c ='Award' and FundingOpportunity__c =:announcementId ];
            if(progRptList.size() > 0 ){
                packageId = progRptList[0].PackageConfig__c;
            }
        }
        
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        GNT.DynamicLayoutDefaultValueHelper dv;
        if(applicationId != null && recordId == null && appName == 'StateasGrantor'){
            Application__c app = [SELECT ProjectOfficer__c, DataEvaluator__c, GrantMonitor__c,
                                        Announcement__r.EstimatedBudgetPeriodStartDate__c, 
                                        Announcement__r.EstimatedBudgetPeriodEndDate__c, 
                                        Announcement__r.EstimatedProjectPeriodStartDate__c, 
                                        Announcement__r.EstimatedProjectPeriodEndDate__c,
                                        Announcement__r.Program__c,
                                        Announcement__r.MatchRequired__c,
                                        AuthorizedRepresentativeEmail__c,
                                        AuthorizedRepresentativeName__c,
                                        AuthorizedRepresentativePhone__c,
                                        AuthorizedRepresentativeTitle__c,
                                        Announcement__r.PointOfContact__c
                                        FROM Application__c WHERE Id =: applicationId LIMIT 1];
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgramCode__c',app.Announcement__r.Program__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodStartDate__c',app.Announcement__r.EstimatedProjectPeriodStartDate__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'BudgetPeriodEndDate__c',app.Announcement__r.EstimatedBudgetPeriodEndDate__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'BudgetPeriodStartDate__c',app.Announcement__r.EstimatedBudgetPeriodStartDate__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectPeriodEndDate__c',app.Announcement__r.EstimatedProjectPeriodEndDate__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProjectOfficer__c',app.ProjectOfficer__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'DataEvaluator__c',app.DataEvaluator__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GrantMonitor__c',app.GrantMonitor__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationId,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'ProgramManager__c',app.Announcement__r.PointOfContact__c,true);
            listDefaultValues.add(dv); 
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'IsStateMatchRequired__c',app.Announcement__r.MatchRequired__c,true);
            listDefaultValues.add(dv);
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AuthorizedRepresentativeEmail__c',app.AuthorizedRepresentativeEmail__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AuthorizedRepresentativeName__c',app.AuthorizedRepresentativeName__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AuthorizedRepresentativePhone__c',app.AuthorizedRepresentativePhone__c,true);
            listDefaultValues.add(dv);  
            dv = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AuthorizedRepresentativeTitle__c',app.AuthorizedRepresentativeTitle__c,true);
            listDefaultValues.add(dv);  
        }
        if(applicationId != null && appName == 'StateasGrantee'){
            GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',applicationId,true);
            listDefaultValues.add(dv7);
            GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GrantAwardName__c',applicationObj.Title__c,true);
            listDefaultValues.add(dv6);
            GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'CFDANumber__c',applicationObj.CFDANumber__c,true);
            listDefaultValues.add(dv8); 
            GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GrantAwardDescription__c',applicationObj.ProjectAbstract__c,true);
            listDefaultValues.add(dv9);
            GNT.DynamicLayoutDefaultValueHelper dv10 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'TotalObligateAmount__c',applicationObj.RequestedAmount__c,true);
            listDefaultValues.add(dv10);
        }
        
        if(grantId != null && applicationId == null){
            GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Grant__c',grantId,true);
            listDefaultValues.add(dv1);
            GNT.DynamicLayoutDefaultValueHelper dv11 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Addressline1__c',grantObj.InternalOrganization__r.BillingStreet,true);
            GNT.DynamicLayoutDefaultValueHelper dv12 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'City__c',grantObj.InternalOrganization__r.Billingcity,true);
            GNT.DynamicLayoutDefaultValueHelper dv13 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'State__c',grantObj.InternalOrganization__r.BillingState,true);
            GNT.DynamicLayoutDefaultValueHelper dv14 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Country__c',grantObj.InternalOrganization__r.BillingCountry,true);
            GNT.DynamicLayoutDefaultValueHelper dv15 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Zip4__c',grantObj.InternalOrganization__r.BillingPostalCode,true);
            listDefaultValues.add(dv11);
            listDefaultValues.add(dv12);
            listDefaultValues.add(dv13);
            listDefaultValues.add(dv14);
            listDefaultValues.add(dv15); 
            GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'GrantAwardName__c',grantObj.ProjectTitle__c,true);
            listDefaultValues.add(dv4);
            GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'AwardIssueDate__c',grantObj.IssueDate__c,true);
            listDefaultValues.add(dv5); 
            GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'Application__c',grantObj.Application__c,true);
            listDefaultValues.add(dv6);
        }
        if(BudgetPeriodid != null){
         GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper(AppUtils.getNamespacePrefix()+'BudgetPeriod__c',BudgetPeriodid,true);
            listDefaultValues.add(dv4);
        }
        
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        if (awd != null) {
            keyValueMap.put('grantId', awd.Grant__c);
            keyValueMap.put('AccountId', awd.Grant__r.InternalOrganization__c);
            keyValueMap.put('programId', awd.Grant__r.Program__c);            
        }
        else {
            keyValueMap.put('grantId',grantId);
            keyValueMap.put('AccountId', grantObj.InternalOrganization__c);
            KeyValueMap.put('programId', grantObj.Program__c);
        }
        keyValueMap.put('UserId',UserInfo.getUserId());  
        keyValueMap.put('budgetGrantId',budgetGrantId);
        keyValueMap.put('orgId',orgId);
        keyValueMap.put('applicationId',applicationId);
        if(recordId != null){
            keyValueMap.put('awardId',recordId);
        }
        return JSON.serialize(keyValueMap);
    }
}