public with sharing class AdditionalUserEditCtrl {
    public ID recordId {get; set;}
    public String recordTypeId {get; set;}
    public ID userID {get; set;}
    public PageReference savePage {get; set;}
    public PageReference cancelPage {get; set;}
    public String pageTemplateName {get; set;}
    public List<GNT.DynamicLayoutDefaultValueHelper> listDefaultValues {get; set;}
    public class KeyPOCException extends Exception {}

    public AdditionalUserEditCtrl(ApexPages.StandardController stdController) {
        try {
            /*
            Contact con = (Contact) stdController.getRecord();
            System.debug('LEON HERE123============>>>>>>>>>' + con);
            if (con.Id != null) {
                Contact contact = [Select id, keycontact__c from contact where id = :con.id];
            }
            */
            recordId = ApexPages.CurrentPage().getParameters().get('Id');
            Id orgId = ApexPages.CurrentPage().getParameters().get('orgId');
            if (orgId == null && recordId!=null)
            {
                Contact contact = [Select id,AccountId, keycontact__c from contact where id = :recordId];
                orgId = contact.AccountId;
                System.debug('orgidnull');
            }
            System.debug('LEON HERE============>>>>>>>>>' + orgId);
            String retURL = ApexPages.CurrentPage().getParameters().get('retURL');
            system.debug('recordId>>>' + recordId );
            listDefaultValues = new List<GNT.DynamicLayoutDefaultValueHelper>();
            pageTemplateName = 'AdditionalUser'; //TODO get template dynamically from sObjectConfig
            if (!String.isEmpty(recordId)) {
                System.debug('LEON 1==========>');
                //savePage = Page.SMEReviewerView;
                //savePage.getParameters().put('Id', recordId);
                /* savePage = Page.FlexTableView;
                savePage.getParameters().put('flexTableName', 'Additional User');
                cancelPage = Page.FlexTableView;
                cancelPage.getParameters().put('flexTableName', 'Additional User'); */
                //if (contact.KeyContact__c){
                //    throw new KeyPOCException();
                //}
                savepage = Page.AdditionalUserView;
                savepage.getParameters().put('id', recordId);
                cancelpage = Page.organizationview;
                cancelPage.getParameters().put('id', orgId);
            } else if (orgId != null) {
                System.debug('LEON 2==========>');
                List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE id = : orgId]);
                GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AccountId', acc[0].Id, true);
                listDefaultValues.add(dv);
                savePage = Page.AdditionalUserView;
                savePage.getParameters().put('id', recordId);
                cancelpage = Page.organizationview;
                cancelpage.getParameters().put('id', orgId);
            } else {
                System.debug('LEON 3==========>');
                system.debug('yyyyyy>>>' + userID);
                recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Recipient').getRecordTypeId();
                userID = UserInfo.getUserId();
                system.debug('userID>>>' + userID);
                if (!String.isEmpty(userID)) {
                    List<User> user = new List<User>([SELECT id , AccountId FROM User WHERE Id = : userID]);
                    List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE id = : user[0].AccountId]);
                    //List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE RecordTypeId =: recordTypeId]);
                    GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AccountId', acc[0].Id, true);
                    GNT.DynamicLayoutDefaultValueHelper dv1 = new GNT.DynamicLayoutDefaultValueHelper('ReviewerStatus__c ', 'New', true);
                    listDefaultValues.add(dv);
                    listDefaultValues.add(dv1);
                    savePage = Page.AdditionalUserView;
                    savePage.getParameters().put('id', recordId);
                    cancelpage = Page.organizationview;
                    cancelpage.getParameters().put('id', recordId);
                }

                /* if(!String.isEmpty(recordTypeId)){
                     List<Account> acc = new List<Account>([SELECT Id FROM Account WHERE RecordTypeId =: recordTypeId]);
                     GNT.DynamicLayoutDefaultValueHelper dv = new GNT.DynamicLayoutDefaultValueHelper('AccountId', acc[0].Id, true);
                     listDefaultValues.add(dv);
                 } */
                //savePage = Page.SMEReviewerView;
                /* savePage = Page.FlexTableView;
                 savePage.getParameters().put('flexTableName', 'Additional User');
                 cancelPage = Page.FlexTableView;
                 cancelPage.getParameters().put('flexTableName', 'Additional User'); */
                 System.debug('lastrecordid '+recordId);
                savePage = Page.AdditionalUserView;
                savePage.getParameters().put('id', recordId);
                cancelpage = Page.organizationview;
                cancelpage.getParameters().put('id', orgId);

            }
        } catch (KeyPOCException e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot change the role of Key POC. '));
        }
    }

    public string getKeyValueMap() {
        Map<String, String> keyValueMap = new Map<String, String>();
        keyValueMap.put('recordId', recordId);

        return JSON.serialize(keyValueMap);
    }

}