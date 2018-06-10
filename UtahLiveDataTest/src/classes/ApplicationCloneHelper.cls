global without sharing class ApplicationCloneHelper {

    public ApplicationCloneHelper( ) {
    }

    global String cloneApplication(String recordId, Id annId) {
        ApplicationTriggerHelper.skipTrigger = true;
        ApplicationTriggerHelperUSBE.skipTrigger = true;
        ApplicationTriggerHelperUOVC.skipTrigger = true;
        ApplicationBudgetCategoryTriggerHelper.skipTrigger = true;
        Application__c currentRecord;
        Application__c newRecord;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        String SobjectApiName = 'Application__c';
        String uniqueIdAPIName = 'InternalUniqueID__c';
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String commaSeparatedFields = '';
        for (String fieldName : fieldMap.keyset()) {
            if (!fieldName.equalsIgnorecase(uniqueIdAPIName) && !fieldName.equalsIgnoreCase('FormsValidated__c')) {
                if (commaSeparatedFields == null || commaSeparatedFields == '') {
                    commaSeparatedFields = fieldName;
                } else {
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        String query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Id = \'' + recordId + '\'';
        currentRecord = Database.query(query);



        currentRecord.Cloned__c = true;
        update currentRecord;
        newRecord = currentRecord.clone();
        newRecord.ClonedFrom__c = currentRecord.Name;
        newRecord.Status__c = 'Created';
        newRecord.Title__c = newRecord.Title__c + ' (Copy)';
        newRecord.ProjectPeriodStartDate__c = null;
        newRecord.ProjectPeriodEndDate__c = null;
        newRecord.OwnerId = UserInfo.getUserId();
        newRecord.SubmittedOn__c = null;
        newRecord.SubmittedBy__c = null;
        if (annId != null) {
            OpportunityQualification__c selectedOpp = [select id , name, FundingOpportunity__c, FundingOpportunity__r.AwardCeiling__c, FundingOpportunity__r.ApplicationDeadlineWithDateTime__c,
                                        FundingOpportunity__r.AwardFloor__c from OpportunityQualification__c where id = : annId limit 1];
            newRecord.Announcement__c = selectedOpp.FundingOpportunity__c;
            newRecord.AwardCeiling__c = selectedOpp.FundingOpportunity__r.AwardCeiling__c;
            newRecord.AwardFloor__c = selectedOpp.FundingOpportunity__r.AwardFloor__c;
            newRecord.ApplicationDeadlineWithDateTime__c = selectedOpp.FundingOpportunity__r.ApplicationDeadlineWithDateTime__c;
        }
        insert newRecord;

        SobjectApiName = 'BudgetPeriod__c';
        fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        commaSeparatedFields = '';
        for (String fieldName : fieldMap.keyset()) {
            if (!fieldName.equalsIgnorecase(uniqueIdAPIName)) {
                if (commaSeparatedFields == null || commaSeparatedFields == '') {
                    commaSeparatedFields = fieldName;
                } else {
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Application__c = \'' + recordId + '\'';
        List<BudgetPeriod__c> bplist = Database.query(query);

        SobjectApiName = 'ApplicationBudgetCategory2__c';
        fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        commaSeparatedFields = '';
        for (String fieldName : fieldMap.keyset()) {
            if (!fieldName.equalsIgnorecase(uniqueIdAPIName) && !fieldName.equalsIgnoreCase('Federal__c') && !fieldName.equalsIgnoreCase('InKind__c') && !fieldName.equalsIgnoreCase('CashMatch__c') && !fieldName.equalsIgnoreCase('Amount__c')) {
                if (commaSeparatedFields == null || commaSeparatedFields == '') {
                    commaSeparatedFields = fieldName;
                } else {
                    commaSeparatedFields = commaSeparatedFields + ', ' + fieldName;
                }
            }
        }
        query = 'select ' + commaSeparatedFields + ' from ' + SobjectApiName + ' where Application__c = \'' + recordId + '\'';
        List<ApplicationBudgetCategory2__c> abclist = Database.query(query);

        Map<Id, List<ApplicationBudgetCategory2__c>> abcmap = new Map<Id, List<ApplicationBudgetCategory2__c>>();
        for (ApplicationBudgetCategory2__c abc : abclist) {
            List<ApplicationBudgetCategory2__c> tmp = abcmap.get(abc.BudgetPeriod__c);
            if (tmp == null) {
                tmp = new List<ApplicationBudgetCategory2__c>();
            }
            tmp.add(abc);
            abcmap.put(abc.BudgetPeriod__c, tmp);
        }

        List<GNT__AttachmentExtension__c> newattachmentlist = new List<GNT__AttachmentExtension__c>();
        List<BudgetPeriod__c> newbplist = new List<BudgetPeriod__c>();
        List<ApplicationBudgetCategory2__c> newabclist = new List<ApplicationBudgetCategory2__c>();

        for (GNT__AttachmentExtension__c attachment : [SELECT Name, GNT__Attachment__c, GNT__Classification__c,
                GNT__HistoryReason__c, GNT__ParentId__c FROM GNT__AttachmentExtension__c where GNT__ParentId__c = :recordId]) {
            GNT__AttachmentExtension__c newawdatt = attachment.clone();
            newawdatt.GNT__ParentId__c = newRecord.id;
            newattachmentlist.add(newawdatt);
        }

        for (BudgetPeriod__c bp : bplist) {
            BudgetPeriod__c newbp = bp.clone();
            newbp.Application__c = newRecord.Id;
            newbplist.add(newbp);
        }
        insert newattachmentlist;
        insert newbplist;

        Map<Id, BudgetPeriod__c> bptobpmap = new Map<Id, BudgetPeriod__c>();
        for (BudgetPeriod__c bp : bplist) {
            for (BudgetPeriod__c newbp : newbplist) {
                if (bp.BudgetPeriod__c == newbp.BudgetPeriod__c) {
                    bptobpmap.put(bp.Id, newbp);
                }
            }
        }

        for (BudgetPeriod__c bp : bplist) {
            BudgetPeriod__c newbp = bptobpmap.get(bp.Id);
            List<ApplicationBudgetCategory2__c> abcs = abcmap.get(bp.Id);
            for (ApplicationBudgetCategory2__c abc : abcs) {
                ApplicationBudgetCategory2__c newabc = abc.clone();
                newabc.Application__c = newbp.Application__c;
                newabc.BudgetPeriod__c = newbp.Id;
                newabc.BudgetAmountUSBE__c = 0;
                newabc.AdminCostValue__c = 0;
                newabclist.add(newabc);
            }
        }
        insert newabclist;

        return newRecord.Id;
    }
}