public with sharing class ReviewerEditCtrl {
    public ID recordId{get;set;}
    public String recordTypeId {get;set;}
    public PageReference savePage {get;set;}
    public PageReference cancelPage {get;set;}
    public String pageTemplateName {get;set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get;set;}
    
    public ReviewerEditCtrl(ApexPages.StandardController stdController){
        Contact con = (Contact) stdController.getRecord();
        recordId = ApexPages.CurrentPage().getParameters().get('Id');
        listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
        pageTemplateName = 'SMEReviewerTemplate'; //TODO get template dynamically from sObjectConfig
        if (!String.isEmpty(recordId)) {
            //savePage = Page.SMEReviewerView;
            //savePage.getParameters().put('Id', recordId); 
            savePage = Page.FlexTableView;
            savePage.getParameters().put('flexTableName', 'Reviewers');
            cancelPage = Page.FlexTableView;
            cancelPage.getParameters().put('flexTableName', 'Reviewers');
        }
        else {        
            recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reviewers').getRecordTypeId();
            
            if(!String.isEmpty(recordTypeId)){
                List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE RecordTypeId =: recordTypeId]);
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AccountId', acc[0].Id, true);
                listDefaultValues.add(dv);
            }
            //savePage = Page.SMEReviewerView; 
            savePage = Page.FlexTableView;
            savePage.getParameters().put('flexTableName', 'Reviewers');
            cancelPage = Page.FlexTableView;
            cancelPage.getParameters().put('flexTableName', 'Reviewers');
        }
    }

    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        keyValueMap.put('ContactId', ApexPages.currentPage().getParameters().get('Id'));
        return JSON.serialize(keyValueMap);
    }
}