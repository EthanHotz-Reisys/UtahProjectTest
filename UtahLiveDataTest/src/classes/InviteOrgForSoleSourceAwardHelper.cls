global with sharing class InviteOrgForSoleSourceAwardHelper extends GNT.FlexTableActionHandler {
    
    global override Map<String,Object> clickHandler(){
        List<Id> orgIdList = new List<Id>();
        Map<Id, Set<Id>> foIdToContactIdMap = new Map<Id, Set<Id>>();
        String ns = GNT.AppUtils.getNamespacePrefix();
        Map<String,Object> resultMap = new Map<String,Object>();
        List<SoleSourceAwardRecipient__c> lstSar = new List<SoleSourceAwardRecipient__c>();
        Id foId = urlParams.get('id');  
        List<Account> lstAcc = [Select id from Account where id IN :selectedRecordIds];
        for(Account acc : lstAcc){
            SoleSourceAwardRecipient__c sar = new SoleSourceAwardRecipient__c();
            sar.Account__c = acc.Id;
            sar.FundingOpportunity__c = foId;
            lstSar.add(sar);
        }
        if(lstSar.size() > 0){
            insert lstSar;
            List<Announcement__c> annList = [Select Id, AnnouncementType__c, Status__c From Announcement__c Where Id = :foId LIMIT 1];
            if(annList.size() > 0 && !String.isempty(annList[0].AnnouncementType__c) && String.valueOf(annList[0].AnnouncementType__c).equalsIgnoreCase('sole source') && !String.isempty(annList[0].Status__c) && String.valueOf(annList[0].Status__c).equalsIgnoreCase('active') ){
                for(SoleSourceAwardRecipient__c sar : lstSar){
                    orgIdList.add(sar.Account__c);
                }
                List<User> applicantList = [Select id, ContactId from User Where IsActive = true AND IsApplicant__c = true AND AccountId IN :orgIdList];
                Set<Id> contId = new Set<Id>();
                for(User usr : applicantList){
                    contId.add(usr.ContactId);
                }
                foIdToContactIdMap.put(foId, contId);
                List<EmailTemplate> emailTemplate = [select Id From EmailTemplate Where DeveloperName = 'NotifyApplicantsOnSoleSourceFOPublish' Limit 1];
                if(emailTemplate.size() > 0){
                    GNT.AppUtils.sendEmailUsingTemplate(emailTemplate[0].Id, foIdToContactIdMap, false);
                }
            }
            
            resultMap.put('PageReference', '/apex/InviteOrgForSoleSourceAward?id='+foId);
        }
        return resultMap;
    }
    
    public string getKeyValueMap(){
        Map<String,String> keyValueMap = new Map<String,String>();
        String announcementid = ApexPages.currentPage().getParameters().get('id');
        keyValueMap.put('announcementId',announcementid); 
        return JSON.serialize(keyValueMap);
    }
    
    public string getListParams(){
        Map<String,List<String>> listParams = new Map<String,List<String>>();
        String announcementid = ApexPages.currentPage().getParameters().get('id');
        // Sole source award
        List<Id> orgIdList = new List<Id>();
        List<SoleSourceAwardRecipient__c> lst = [Select FundingOpportunity__c, Account__c 
            from SoleSourceAwardRecipient__c Where FundingOpportunity__c = :announcementId];
        for(SoleSourceAwardRecipient__c sar : lst){
            orgIdList.add(sar.Account__c);
        }
        system.debug('orgIdList ---'+orgIdList);
        listParams.put('externalOrgIds',orgIdList);

        return JSON.serialize(listParams);
    }
}