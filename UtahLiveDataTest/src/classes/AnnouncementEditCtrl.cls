/**
* Class to handle the Announcement Edit page
* 
* CHANGE HISTORY
* =============================================================================
* Date          Name            Description
* 03/10/2015    William Moore   Merged SOQL statements
* =============================================================================
*/
public with sharing class AnnouncementEditCtrl extends GNT.MasterCtrl {
    
    //Properties
    public ID recordId{get;set;}
    public PageReference savePage {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    public ID programId{get;set;}
    private Boolean rfaParameter;
    public PageReference cancelPage {get;set;}
    private String annType ;
    public String pageTemplateName {get;set;}
    public Boolean createMode {get;set;}
    public AnnouncementEditCtrl(ApexPages.StandardController stdController){
        recordId = ApexPages.CurrentPage().getParameters().get('id');   
        savePage = Page.AnnouncementView;
        savePage.getParameters().put('id', recordId);        
        Id programId = ApexPages.CurrentPage().getParameters().get('programid');
        createMode = (programId != null) ? false : true;
          System.debug('***cancelPage1****'+cancelPage);
        if (cancelPage == null && recordId != null) {
            cancelPage = Page.AnnouncementView;  
            cancelPage.getParameters().put('id', recordId); 
        }
        else {
            String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            if(retURL != null) {
                cancelPage = new PageReference(retURL);    
            }
        }
        User u = [SELECT Id,Organization__c, AccountNameFormulaField__c FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug('***cancelPage****'+cancelPage);
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        if (programId != null){           
            Program__c programObj = [select OrganizationName__c,AttachmentsRequired__c from Program__c where Id =: programId limit 1];
            GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('Program__c',programId,true);
            listDefaultValues.add(dv);
        }
          // Pre populating date fields
           Date todaysDate = Date.today();
           GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('FOAPublicationDate__c',todaysDate.adddays(14),true);
           GNT.DynamicLayoutDefaultValueHelper dv2 = new GNT.DynamicLayoutDefaultValueHelper('RFAReleaseDate__c',todaysDate.adddays(28),true);
           //GNT.DynamicLayoutDefaultValueHelper dv3 = new GNT.DynamicLayoutDefaultValueHelper('ApplicationDeadlineWithDateTime__c',System.now().adddays(42),true);
           GNT.DynamicLayoutDefaultValueHelper dv4 = new GNT.DynamicLayoutDefaultValueHelper('EstimatedBudgetPeriodStartDate__c',todaysDate.adddays(56),true);
           GNT.DynamicLayoutDefaultValueHelper dv5 = new GNT.DynamicLayoutDefaultValueHelper('EstimatedBudgetPeriodEndDate__c',todaysDate.adddays(421),true);
           //GNT.DynamicLayoutDefaultValueHelper dv6 = new GNT.DynamicLayoutDefaultValueHelper('EstimatedProjectPeriodStartDate__c',todaysDate.adddays(56),true);
           //GNT.DynamicLayoutDefaultValueHelper dv7 = new GNT.DynamicLayoutDefaultValueHelper('EstimatedProjectPeriodEndDate__c',todaysDate.adddays(421),true);
           GNT.DynamicLayoutDefaultValueHelper dv8 = new GNT.DynamicLayoutDefaultValueHelper('MaximumnumberofProjectyears__c',1,true);
           GNT.DynamicLayoutDefaultValueHelper dv9 = new GNT.DynamicLayoutDefaultValueHelper('Organization__c',u.Organization__c,true);
           listDefaultValues.add(dv9);
           
       
            listDefaultValues.add(dv1);
            listDefaultValues.add(dv2);
            //listDefaultValues.add(dv3);
            listDefaultValues.add(dv4);
            listDefaultValues.add(dv5);
            //listDefaultValues.add(dv6);
            //listDefaultValues.add(dv7);

        List<EmailTemplate> templates = [SELECT Id, Name FROM EmailTemplate WHERE Name =: GNT.KeyValueStoreHelper.getTextValue('AwardApprovalEmailTemplate',true) 
                                            OR Name =: GNT.KeyValueStoreHelper.getTextValue('AwardRejectionEmailTemplate',true)];
        GNT.DynamicLayoutDefaultValueHelper helper;
        for (EmailTemplate template: templates) {
            if (template.Name == GNT.KeyValueStoreHelper.getTextValue('AwardApprovalEmailTemplate',true))  {
                helper = new GNT.DynamicLayoutDefaultValueHelper('AwardApprovalEmailTemplate__c',template.id,false);
            } else if (template.Name == GNT.KeyValueStoreHelper.getTextValue('AwardRejectionEmailTemplate',true)) {
                helper = new GNT.DynamicLayoutDefaultValueHelper('AwardRejectionEmailTemplate__c',template.id,false);
            }
            listDefaultValues.add(helper);
        }
      
        String appName = GNT.UserPreferenceHelper.getStringValue('ActiveAppName__c');
        if(appName != null && appName == 'StateAsGrantee'){
          pageTemplateName = 'AnnouncementGrantee';
        } else {
            //   pageTemplateName = 'Announcement-Internal Grantor';
            Announcement__c ann = null;
            Id pageDataHolder = ApexPages.CurrentPage().getParameters().get('pageDataHolder');
            if(pageDataHolder != null) {
                ann = (Announcement__c)AppUtils.getSObjectFromJSON();   
            } else {
                List<Announcement__c> annList = [select RFARequired__c, Program__c,AnnouncementType__c from Announcement__c where id=:recordId limit 1];
                if(annList.size () > 0){
                    ann = annList[0];
                }
            }
            if(ann != null) {
               rfaParameter=ann.RFARequired__c;
               annType=ann.AnnouncementType__c;           
            }
            System.debug('***pageDataHolder****'+pageDataHolder);
            if(u.AccountNameFormulaField__c == 'USBE' || u.AccountNameFormulaField__c == 'SYSTEM'){
                pageTemplateName = 'USBE Announcement';
            }else{
                if(pageDataHolder == null && recordId == null && appName != null && appName == 'StateasGrantor'){
                    pageTemplateName = 'AnnouncementIntermediateLayout';
                }
                else if(annType!=null && annType=='Sole Source/Directed'){
                    pageTemplateName = 'Announcement-Internal Grantor-Sole Source';
                }
                else if(rfaParameter!=null && !rfaParameter){  // If RFA does not need to be shown
                    pageTemplateName = 'Announcement-Internal Grantor-FOA';
                }
                else{
                    pageTemplateName = 'Announcement-Internal Grantor';
          
                }
            }
           System.debug('--pageTemplateName--'+pageTemplateName);
        }
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('announcementId',recordId);
        keyValueMap.put('programId',programId); 
        keyValueMap.put('UserId',UserInfo.getUserId());
        Id recTypeIdApp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Application').getRecordTypeId();
        keyValueMap.put('recTypeAppId',(String)recTypeIdApp);
        Id recTypeIdPreapp = Schema.SObjectType.ReviewStepTemplate__c.getRecordTypeInfosByName().get('Pre-Application').getRecordTypeId();
        keyValueMap.put('recTypePreAppId',(String)recTypeIdPreapp );
        return JSON.serialize(keyValueMap);
    }   
}